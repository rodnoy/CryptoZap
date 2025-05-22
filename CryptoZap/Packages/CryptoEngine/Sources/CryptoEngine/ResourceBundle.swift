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

        // Universal detection for Homebrew Cellar path (arm64 or x86_64)
        let possibleCellarPaths = [
            "/opt/homebrew/Cellar",     // Apple Silicon
            "/usr/local/Cellar"         // Intel
        ]

        for cellarRoot in possibleCellarPaths {
            let cryptozapPath = "\(cellarRoot)/cryptozap-cli"
            if let versions = try? fm.contentsOfDirectory(atPath: cryptozapPath).sorted(by: >) {
                for version in versions {
                    let bundlePath = "\(cryptozapPath)/\(version)/CryptoEngine_CryptoEngine.bundle"
                    if fm.fileExists(atPath: bundlePath), let bundle = Bundle(path: bundlePath) {
                        return bundle
                    }
                }
            }
        }

        // Local execution: next to binary
        let localPath = Bundle.main.bundleURL.deletingLastPathComponent()
            .appendingPathComponent("CryptoEngine_CryptoEngine.bundle").path
        if fm.fileExists(atPath: localPath), let bundle = Bundle(path: localPath) {
            return bundle
        }

        fatalError("⚠️ Resource bundle not found in expected paths")
    }()
}
