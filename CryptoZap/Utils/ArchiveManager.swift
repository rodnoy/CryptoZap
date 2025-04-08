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
            if FileManager.default.directoryExists(atPath: fileURL.path) {
                let enumerator = FileManager.default.enumerator(at: fileURL, includingPropertiesForKeys: nil)!
                for case let file as URL in enumerator {
                    if FileManager.default.directoryExists(atPath: file.path) { continue }
                    let relativePath = file.path.replacingOccurrences(of: fileURL.path + "/", with: "")
                    try archive.addEntry(with: fileURL.lastPathComponent + "/" + relativePath, fileURL: file)
                }
            } else {
                try archive.addEntry(with: fileURL.lastPathComponent, fileURL: fileURL)
            }
        }
        
        return zipURL
    }
    static func unzip(data: Data, to destination: URL) throws {
        let tempZipURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".zip")
        try data.write(to: tempZipURL)

        let archive = try Archive(url: tempZipURL, accessMode: .read)

        for entry in archive {
            let outputURL = destination.appendingPathComponent(entry.path)
            let outputDir = outputURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

            if FileManager.default.fileExists(atPath: outputURL.path) {
                if FileManager.default.isDeletableFile(atPath: outputURL.path) {
                    try FileManager.default.removeItem(at: outputURL)
                } else {
                    print("🚫 Нельзя удалить файл: \(outputURL.lastPathComponent)")
                    continue
                }
            }

            _ = try archive.extract(entry, to: outputURL, skipCRC32: true)
        }

        try FileManager.default.removeItem(at: tempZipURL)
    }
}
