//
//  CryptoError.swift
//  CryptoEngine
//
//  Created by KIRILL SIMAGIN on 18/04/2025.
//

import Foundation

public enum CryptoError: LocalizedError, Identifiable {
    case wrongPassword
    case archiveFailure
    case decryptionFailure
    case encryptionFailure
    case permissionDenied
    case userCancelled

    public var id: String {
        self.localizedDescription
    }

    public var errorDescription: String? {
        switch self {
        case .wrongPassword:
            return String(localized: "WrongPassword")
        case .archiveFailure:
            return String(localized: "ArchiveFailure")
        case .decryptionFailure:
            return String(localized: "DecryptionFailure")
        case .encryptionFailure:
            return String(localized: "EncryptionFailure")
        case .permissionDenied:
            return String(localized: "PermissionDenied")
        case .userCancelled:
            return String(localized: "UserCancelledFolderSelection")
        }
    }
}
