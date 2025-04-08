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
    static func unzip(data: Data, to destination: URL) throws {
        let tempZipURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".zip")
        try data.write(to: tempZipURL)

        // Используем throwing-инициализатор вместо устаревшего guard-let
        let archive = try Archive(url: tempZipURL, accessMode: .read)

        // Добавляем пропущенный аргумент (skipCRC32: true)
        for entry in archive {
            _ = try archive.extract(entry, to: destination, skipCRC32: true)
        }

        try FileManager.default.removeItem(at: tempZipURL)
    }
}
