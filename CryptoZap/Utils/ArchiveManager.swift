//
//  ArchiveManager.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//


import Foundation
import ZIPFoundation

struct ArchiveManager {
    static func createArchive(from files: [URL]) throws -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let zipURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
        

        let archive = try Archive(url: zipURL, accessMode: .create)
        for fileURL in files {
            try archive.addEntry(with: fileURL.lastPathComponent, fileURL: fileURL)
        }
        
        return zipURL
    }
}
