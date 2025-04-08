import Foundation
import ZIPFoundation

struct ArchiveManager {
    static func createArchive(from files: [URL]) throws -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let zipURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
        
        guard let archive = Archive(url: zipURL, accessMode: .create) else {
            throw NSError(domain: "ArchiveError", code: 0, userInfo: nil)
        }
        
        for fileURL in files {
            try archive.addEntry(with: fileURL.lastPathComponent, fileURL: fileURL)
        }
        
        return zipURL
    }
}