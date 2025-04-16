//
//  FileManager+Extensions.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//

import Foundation

extension FileManager {
    func directoryExists(atPath path: String) -> Bool {
        var isDir: ObjCBool = false
        return self.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }
}
