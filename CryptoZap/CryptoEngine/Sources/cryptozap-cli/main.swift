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
        discussion: "", version: "1.0.0", subcommands: [Encrypt.self, Decrypt.self],
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
            print("✅ File encrypted to:", outputURL.path)
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
            let password = readSecureInput(prompt: String(localized: "CLIPasswordPrompt"))
            let inputURL = URL(fileURLWithPath: inputPath)
            let encryptedData = try Data(contentsOf: inputURL)
            let decrypted = try CryptoService.decryptFile(encryptedData: encryptedData, password: password)

            // Save to temp .zip
            let tempZipURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
            try decrypted.write(to: tempZipURL)

            let outputURL: URL
            if let outPath = outputPath {
                outputURL = URL(fileURLWithPath: outPath)
            } else {
                outputURL = inputURL.deletingPathExtension()
            }

            try ArchiveService.unzip(data: decrypted, to: outputURL)
            try FileManager.default.removeItem(at: tempZipURL)

            print(String(localized: "CLIDecryptionSuccess"), outputURL.path)
        }
    }
}

CryptoZapCLI.main()
