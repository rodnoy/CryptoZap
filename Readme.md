# CryptoZap

CryptoZap is a minimalist macOS app for securely encrypting and decrypting files using Apple's CryptoKit and SwiftUI. Designed for simplicity and speed, with a modern drag-and-drop interface.

## Features

- Encrypt multiple files with a password
- Automatically ZIP files before encryption
- Drag-and-drop UI for easy file selection
- Custom `.encrypted` file format
- Decrypt with password and restore original files and folders
- Built entirely with native SwiftUI and CryptoKit

## Requirements

- macOS 12.0+
- Apple Silicon (M1, M2, etc.)

## Installation

Download the latest `.zip` file from the [Releases](https://github.com/rodnoy/CryptoZap/releases) section.

### 🔐 Encryption Standard

CryptoZap uses AES-GCM encryption with a symmetric key derived via HKDF using SHA-256. This method is chosen for its balance of strong security and high performance. The salt ensures that the derived key is unique for every encryption.

### 🧰 Command-Line Interface (CLI)

In addition to the SwiftUI GUI app, CryptoZap provides a fully featured CLI tool: `cryptozap-cli`.

Install via Homebrew:

```bash
brew install cryptozap-cli
```

Examples:

```bash
cryptozap-cli encrypt ~/Secrets/file.txt -o ~/Desktop
cryptozap-cli encrypt ~/Documents/FolderToEncrypt --output ~/Desktop
cryptozap-cli decrypt ~/Desktop/EncryptedFile.encrypted
```

You can use short aliases for arguments:

- `--output` → `-o`
- `--help`   → `-h`

### 🕹 Suggested Aliases

To make typing easier, you can add the following aliases to your shell configuration:

#### For zsh or bash:
```bash
alias cz="cryptozap-cli"
alias czenc="cryptozap-cli encrypt"
alias czdec="cryptozap-cli decrypt"
```

#### For fish:
```fish
alias cz "cryptozap-cli"
alias czenc "cryptozap-cli encrypt"
alias czdec "cryptozap-cli decrypt"
```

This allows commands like:
```bash
czenc ~/file.txt -o ~/Desktop
czdec ~/file.encrypted
```

### 🔁 Autocompletion

Cryptozap CLI supports autocompletion for:

- `zsh`
- `bash`
- `fish`

When installed via `install.sh`, completions are automatically added to your shell profile.

If installed via Homebrew, run this manually:

```bash
sudo cryptozap-cli --generate-completion-script zsh | sudo tee /usr/local/share/zsh/site-functions/_cryptozap-cli > /dev/null
```
> Note: Redirection (`>`) happens outside of `sudo`, so we use `tee` to write with elevated permissions.

Restart your terminal and type:

```bash
cryptozap-cli <TAB>
```

To see available subcommands and flags.

### 💡 Developer Tools

For developers, CryptoZap includes an install script `install.sh` and a release helper `release.sh`. These scripts allow local installation and packaging of the CLI with man pages and autocompletion support for bash, zsh, and fish.

- Autocompletion and man pages are installed to proper system paths
- SHA256 is auto-calculated
- Archive is `.tar.gz`-ready for GitHub Releases

## Finder Extension
To enable CryptoZap in Finder:
1. Open System Settings > Privacy & Security > Extensions > Finder Extensions.
2. Enable "CryptoZapFinderSync".
---

## License

MIT or Custom — _add your license here_
