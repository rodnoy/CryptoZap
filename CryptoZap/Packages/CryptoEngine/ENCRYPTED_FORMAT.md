CryptoZap Encrypted File Format Specification

This document describes the structure of the .encrypted file format used by the CryptoZap application for secure cross-platform encryption and decryption.

Overview

The .encrypted file format is a binary container that wraps encrypted data and metadata using modern cryptographic primitives. It is designed to be:
	•	Secure (confidentiality + integrity)
	•	Compatible across platforms (macOS, iOS, Android)
	•	Simple to parse and implement in any language

File Structure

+----------------+----------------------+---------------------------------------+
| Section        | Size (bytes)         | Description                           |
+----------------+----------------------+---------------------------------------+
| Magic Header   | 8                    | "CRYPTZAP" (ASCII)                    |
| Version        | 1                    | Format version (e.g., 0x01)           |
| Nonce          | 12                   | AES-GCM nonce                         |
| Salt           | 16                   | Salt for HKDF-SHA256 key derivation  |
| Filename Len   | 2                    | Length of encrypted filename          |
| Encrypted Name | Variable             | Encrypted filename (AES-GCM)          |
| Name Tag       | 16                   | Authentication tag for filename       |
| Data Length    | 4                    | Length of encrypted data              |
| Encrypted Data | Variable             | Encrypted data (AES-GCM)              |
| Data Tag       | 16                   | Authentication tag for data           |
+----------------+----------------------+---------------------------------------+

Cryptography
	•	Encryption Algorithm: AES-GCM 256-bit
	•	Key Derivation: HKDF-SHA256
	•	Salt: 16 random bytes, stored in clear
	•	Nonce: 12 random bytes, stored in clear
	•	Tags: 16 bytes per section (as defined by AES-GCM)

Key Derivation

key = HKDF(password: userPassword, salt: randomSalt, info: "CryptoZap", outputLength: 32 bytes)

Implementation Notes
	•	Both filename and content are encrypted using the same key and nonce, but in separate AES-GCM operations.
	•	The filename is UTF-8 encoded before encryption.
	•	It is recommended to validate tags and reject any file if the tags don’t match (i.e., authentication failure).
	•	Decryption must be strict: any tampering with headers, lengths, or tags should be detected and rejected.

Advantages
	•	✅ Simple and minimal format
	•	✅ Authenticated encryption
	•	✅ Compatible with CryptoKit, Android Keystore, and other AES-GCM capable libraries

⸻

This format ensures interoperability between the CryptoZap GUI/CLI apps on macOS and future mobile apps on iOS and Android.

⸻

For implementation examples, see the CryptoEngine Swift package.

⸻

© 2025 CryptoZap Authors. Licensed under MIT.
