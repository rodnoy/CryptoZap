//
//  AppError.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 16/04/2025.
//


import Foundation

enum AppError: LocalizedError, Identifiable {
    case wrongPassword
    case archiveFailure
    case decryptionFailure
    case encryptionFailure
    case permissionDenied
    case userCancelled

    var id: String {
        self.localizedDescription
    }

    var errorDescription: String? {
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
