//
//  FinderSync.swift
//  CryptoZapFinderSync
//
//  Created by KIRILL SIMAGIN on 03/05/2025.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    override init() {
        super.init()
        // Set up the directory we are syncing.
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override var toolbarItemName: String {
        "CryptoZap"
    }

    override var toolbarItemImage: NSImage {
        NSImage(named: NSImage.lockLockedTemplateName)!
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let menu = NSMenu(title: "")
        menu.addItem(withTitle: "Encrypt with CryptoZap", action: #selector(encryptSelected(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Decrypt with CryptoZap", action: #selector(decryptSelected(_:)), keyEquivalent: "")
        return menu
    }

    @objc func encryptSelected(_ sender: Any?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs(), !items.isEmpty else { return }
        print("🔍 Finder URLs:", items)
        openCryptoZap(withAction: "encrypt")
    }

    @objc func decryptSelected(_ sender: Any?) {
        openCryptoZap(withAction: "decrypt")
    }
    
    func openCryptoZap(withAction action: String) {
        print("✅ openCryptoZap executed")
        guard let items = FIFinderSyncController.default().selectedItemURLs(),
              !items.isEmpty else { return }

        let fileURL = items.first!.path
        let encodedPath = fileURL.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileURL

        // Grabbing the scheme from Info.plist (CFBundleURLSchemes)
        let scheme = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes")
            .flatMap { $0 as? [[String: Any]] }?
            .first?["CFBundleURLSchemes"]
            .flatMap { $0 as? [String] }?
            .first ?? "cryptozap"

        let urlString = "\(scheme)://\(action)?path=\(encodedPath)"
        guard let url = URL(string: urlString) else {
            print("❌ Failed to create URL scheme")
            return
        }
        print("🌐 Opening CryptoZap via URL scheme:", url.absoluteString)
        NSWorkspace.shared.open(url)
    }
}
