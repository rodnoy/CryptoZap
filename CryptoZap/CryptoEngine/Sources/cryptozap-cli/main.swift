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
        subcommands: [Encrypt.self, Decrypt.self]
    )

    struct Encrypt: ParsableCommand {
        @Argument(help: "Path to input file")
        var inputPath: String

        @Argument(help: "Password")
        var password: String

        func run() throws {
            let inputURL = URL(fileURLWithPath: inputPath)
            let data = try CryptoService.encryptFile(inputURL: inputURL, password: password)
            let outputURL = inputURL.deletingPathExtension().appendingPathExtension("encrypted")
            try data.write(to: outputURL)
            print("✅ File encrypted to:", outputURL.path)
        }
    }

    struct Decrypt: ParsableCommand {
        @Argument(help: "Path to .encrypted file")
        var inputPath: String

        @Argument(help: "Password")
        var password: String

        func run() throws {
            let inputURL = URL(fileURLWithPath: inputPath)
            let encryptedData = try Data(contentsOf: inputURL)
            let decrypted = try CryptoService.decryptFile(encryptedData: encryptedData, password: password)
            let outputURL = inputURL.deletingPathExtension().appendingPathExtension("decrypted")
            try decrypted.write(to: outputURL)
            print("✅ File decrypted to:", outputURL.path)
        }
    }
}

CryptoZapCLI.main()
