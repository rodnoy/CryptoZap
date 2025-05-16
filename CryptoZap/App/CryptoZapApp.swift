//
//  CryptoZapApp.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//


import SwiftUI
import os
private let logger = Logger(subsystem: "com.orange.labs.immersive.CryptoZap", category: "AppDelegate")

@main
struct CryptoZapApp: App {
    @State private var openedFileURL: URL?
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView(openedFileURL: $openedFileURL)
                .environmentObject(delegate.appState)
                .onOpenURL { url in
                    logger.info("🌐 Received URL: \(url.absoluteString, privacy: .public)")
                    guard url.scheme == "cryptozap" else {
                        logger.info("❌ Unknown URL scheme")
                        return
                    }
                    guard let action = url.host else {
                        logger.info("❌ No action (host) in URL")
                        return
                    }
                    // Получаем путь к файлу из query (например, ?path=/Users/...)
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let path = components.queryItems?.first(where: { $0.name == "path" })?.value {
                        logger.info("✅ URL scheme action: \(action), path: \(path)")
                        delegate.appState.action = action
                        delegate.appState.filesToProcess = [URL(fileURLWithPath: path)]
                    } else {
                        logger.info("❌ No 'path' parameter in URL")
                    }
                }
        }
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit CryptoZap") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
    }
}
// Для управления состоянием UI из аргументов
class AppState: ObservableObject {
    @Published var filesToProcess: [URL] = []
    @Published var action: String? = nil // "encrypt" или "decrypt"
}

// AppDelegate для обработки запуска с аргументами
class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let args = CommandLine.arguments.dropFirst() // Убираем первый (путь к бинарнику)
        logger.info("🧪 Finder arguments: \(String(describing: Array(args)), privacy: .public)")

        guard args.count >= 2 else {
            logger.info("⚠️ Insufficient arguments (\(args.count)).")
            return
        }

        let action = args.first!
        let filePaths = Array(args.dropFirst())
        let urls = filePaths.map { URL(fileURLWithPath: $0) }

        if action == "encrypt" || action == "decrypt" {
            logger.info("✅ Action: \(action, privacy: .public), Files: \(String(describing: urls), privacy: .public)")
            appState.action = action
            appState.filesToProcess = urls
        }
    }
}
