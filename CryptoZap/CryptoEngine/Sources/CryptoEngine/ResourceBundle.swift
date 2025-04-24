//
//  ResourceBundle.swift
//  CryptoEngine
//
//  Created by KIRILL SIMAGIN on 24/04/2025.
//


import Foundation

public enum ResourceBundle {
    public static let bundle: Bundle = {
        let fm = FileManager.default

        // Homebrew installation path (include Cellar/cryptozap-cli/<version>)
        let cellarPath = "/opt/homebrew/Cellar/cryptozap-cli"
        if let versions = try? fm.contentsOfDirectory(atPath: cellarPath).sorted(by: >) {
            for version in versions {
                let bundlePath = "\(cellarPath)/\(version)/CryptoEngine_CryptoEngine.bundle"
                if fm.fileExists(atPath: bundlePath), let bundle = Bundle(path: bundlePath) {
                    return bundle
                }
            }
        }

        // local launch: with binary
        let localPath = Bundle.main.bundleURL.deletingLastPathComponent()
            .appendingPathComponent("CryptoEngine_CryptoEngine.bundle").path
        if fm.fileExists(atPath: localPath), let bundle = Bundle(path: localPath) {
            return bundle
        }

        fatalError("⚠️ Resource bundle not found in expected paths")
    }()
}
