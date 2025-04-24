//
//  main.swift
//  CryptoEngine
//
//  Created by KIRILL SIMAGIN on 18/04/2025.
//

import ArgumentParser
import CryptoEngine
import Foundation

struct CryptoZapCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Encrypt or decrypt files using CryptoZap",
        discussion: "", version: "1.0.3", subcommands: [Encrypt.self, Decrypt.self],
        defaultSubcommand: nil,
        helpNames: [.short, .long]
    )

    struct Encrypt: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "encrypt",
            abstract: "Encrypt a file"
        )
        
        @Argument(help: .init(String.localized("CLIHelpInputPath")))
        var inputPath: String

        @Option(name: [.customLong("output"), .short], help: .init(String.localized("CLIHelpOutputPath")))
        var outputPath: String?
        
        func run() throws {
            func readSecureInput(prompt: String) -> String {
                print(prompt, terminator: ": ")
                fflush(stdout)
                let cstr = getpass("")
                return cstr.map { String(cString: $0) } ?? ""
            }
            do {
                let password = readSecureInput(prompt: String(localized: "CLIPasswordPrompt"))
                let inputURL = URL(fileURLWithPath: inputPath)
                var archiveURL = inputURL
                if FileManager.default.directoryExists(atPath: inputURL.path) {
                    let tempZip = try ArchiveService.createArchive(from: [inputURL])
                    archiveURL = tempZip
                }
                let data = try CryptoService.encryptFile(inputURL: archiveURL, password: password)
                let outputURL: URL
                if let outPath = outputPath {
                    var destURL = URL(fileURLWithPath: outPath)
                    if FileManager.default.directoryExists(atPath: outPath) {
                        destURL = destURL
                            .appendingPathComponent(inputURL.deletingPathExtension().lastPathComponent)
                            .appendingPathExtension("encrypted")
                    }
                    outputURL = destURL
                } else {
                    outputURL = inputURL.deletingPathExtension().appendingPathExtension("encrypted")
                }
                try data.write(to: outputURL)
                print("\u{001B}[0;32m✅ \(String(localized: "CLIEncryptionSuccess")): \(outputURL.path)\u{001B}[0m")
            } catch {
                printError(error)
            }
        }
    }

    struct Decrypt: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "decrypt",
            abstract: "Decrypt a file"
        )
        
        @Argument(help: .init(String.localized("CLIHelpInputPath")))
        var inputPath: String

        // Removed: password from arguments

        @Option(name: [.customLong("output"), .short], help: .init(String.localized("CLIHelpOutputPath")))
        var outputPath: String?

        func run() throws {
            func readSecureInput(prompt: String) -> String {
                print(prompt, terminator: ": ")
                fflush(stdout)
                let cstr = getpass("")
                return cstr.map { String(cString: $0) } ?? ""
            }
            do {
                let password = readSecureInput(prompt: String(localized: "CLIPasswordPrompt"))
                let inputURL = URL(fileURLWithPath: inputPath)
                let encryptedData = try Data(contentsOf: inputURL)
                let decrypted = try CryptoService.decryptFile(encryptedData: encryptedData, password: password)

                // Save to temp .zip
                let tempZipURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
                try decrypted.write(to: tempZipURL)

                let destination: URL
                if let outPath = outputPath {
                    destination = URL(fileURLWithPath: outPath)
                } else {
                    destination = inputURL.deletingLastPathComponent()
                }

                try ArchiveService.unzip(data: decrypted, to: destination)
                try FileManager.default.removeItem(at: tempZipURL)

                print("\u{001B}[0;32m\(String(localized: "CLIDecryptionSuccess")): \(destination.path)\u{001B}[0m")
            } catch {
                printError(error)
            }
        }
    }
}

CryptoZapCLI.main()


// MARK: - Error Printing Helper

func printError(_ error: Error) {
    let errorMessage: String
    if let cryptoError = error as? CryptoError {
        errorMessage = cryptoError.localizedDescription
    } else {
        errorMessage = error.localizedDescription
    }
    print("\u{001B}[0;31m❌ \(errorMessage)\u{001B}[0m")
}
