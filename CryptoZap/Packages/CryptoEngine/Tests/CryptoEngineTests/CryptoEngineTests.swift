import Testing
import Foundation
@testable import CryptoEngine

@Test
func testEncryptionAndDecryption() throws {
    let password = "testPassword123"
    let originalText = "Sensitive data here!"
    let originalData = Data(originalText.utf8)

    let inputURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.txt")
    try originalData.write(to: inputURL)

    let encrypted = try CryptoService.encryptFile(inputURL: inputURL, password: password)
    #expect(!encrypted.isEmpty)

    let decrypted = try CryptoService.decryptFile(encryptedData: encrypted, password: password)
    let decryptedText = String(data: decrypted, encoding: .utf8)

    #expect(decryptedText == originalText)

    try? FileManager.default.removeItem(at: inputURL)
}
