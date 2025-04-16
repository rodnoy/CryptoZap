//
//  CryptoManager.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//


import CryptoKit
import Foundation

struct CryptoService
 {
    
    private static func deriveKey(password: String, salt: Data) -> SymmetricKey {
        let passwordData = Data(password.utf8)
        let key = HKDF<SHA256>.deriveKey(inputKeyMaterial: SymmetricKey(data: passwordData),
                                         salt: salt,
                                         info: Data(),
                                         outputByteCount: 32)
        return key
    }

    static func encryptFile(inputURL: URL, password: String) throws -> Data {
        let fileData = try Data(contentsOf: inputURL)
        let salt = Data((0..<32).map { _ in UInt8.random(in: UInt8.min...UInt8.max) })
        let key = deriveKey(password: password, salt: salt)
        
        let sealedBox = try AES.GCM.seal(fileData, using: key)
        
        return salt + Data(sealedBox.nonce) + sealedBox.ciphertext + sealedBox.tag
    }
    
    static func decryptFile(encryptedData: Data, password: String) throws -> Data {
        let salt = encryptedData.prefix(32)
        let nonceData = encryptedData[32..<44]
        let tagRange = (encryptedData.count - 16)..<encryptedData.count
        let ciphertextRange = 44..<(encryptedData.count - 16)

        let ciphertext = encryptedData[ciphertextRange]
        let tag = encryptedData[tagRange]

        let key = deriveKey(password: password, salt: salt)

        let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonceData),
                                              ciphertext: ciphertext,
                                              tag: tag)

        return try AES.GCM.open(sealedBox, using: key)
    }
}
