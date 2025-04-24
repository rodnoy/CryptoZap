//
//  ResourceBundle.swift
//  CryptoEngine
//
//  Created by KIRILL SIMAGIN on 24/04/2025.
//


import Foundation

public enum ResourceBundle {
    public static let bundle: Bundle = {
        // Поддержка Homebrew — путь к .bundle рядом с бинарём
        let baseURL = Bundle.main.bundleURL.deletingLastPathComponent()
        let bundleURL = baseURL.appendingPathComponent("CryptoEngine_CryptoEngine.bundle")

        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("⚠️ Could not load resource bundle at \(bundleURL.path)")
        }

        return bundle
    }()
}