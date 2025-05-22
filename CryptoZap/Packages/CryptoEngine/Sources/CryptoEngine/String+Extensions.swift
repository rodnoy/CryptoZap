//
//  String+Extensions.swift
//  CryptoEngine
//
//  Created by KIRILL SIMAGIN on 22/04/2025.
//
import Foundation
public extension String {
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, bundle: ResourceBundle.bundle, comment: "")
    }
}
