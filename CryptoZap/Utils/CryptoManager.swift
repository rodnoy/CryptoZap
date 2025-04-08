import CryptoKit
import Foundation

struct CryptoManager {
    
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
        
        return salt + sealedBox.nonce.data + sealedBox.ciphertext + sealedBox.tag
    }
}