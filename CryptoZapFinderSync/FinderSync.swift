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

        let itemPaths = items.map { $0.path }

        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.orange.labs.immersive.CryptoZap") else {
            
            print("❌ CryptoZap app not found")
            return
        }
//        let appURL = URL(fileURLWithPath: "/Applications/CryptoZap.app", isDirectory: true)
        print("📦 Launching CryptoZap at:", appURL.path)
        print("🗂️ With arguments:", [action] + itemPaths)

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = [action] + itemPaths

        print("🚀 Attempting to launch with configuration:", configuration.arguments ?? [])

        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration, completionHandler: { app, error in
            if let error = error {
                print("❌ Error launching CryptoZap: \(error.localizedDescription)")
            } else {
                print("🚀 CryptoZap launched successfully")
            }
        })
    }
}
