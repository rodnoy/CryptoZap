//
//  ContentView.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//

import SwiftUI
import os
private let logger = Logger(subsystem: "com.orange.labs.immersive.CryptoZap", category: "UI")
import UniformTypeIdentifiers
import CryptoKit
import CryptoEngine

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var isDragging = false
    @State private var droppedFiles: [URL] = []
    @State private var showPasswordPrompt = false
    @State private var filesToEncrypt: [URL] = []
    @State private var encryptedFileToDecrypt: URL?
    @State private var showDecryptPrompt = false
    @State private var error: CryptoError?
    @Binding var openedFileURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.doc")
                .font(.system(size: 72))
                .foregroundColor(isDragging ? .blue : .secondary)
            
            Text(String(localized: "DragFilesToEncrypt"))
                .font(.title2)
                .foregroundColor(error != nil ? .red : .secondary)
                .animation(.easeInOut(duration: 0.3), value: error)
            
            if !droppedFiles.isEmpty {
                List(droppedFiles, id: \URL.self) { url in
                    Text(url.lastPathComponent)
                }
                .frame(height: 150)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        .background(RoundedRectangle(cornerRadius: 20)
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
            .foregroundColor(isDragging ? .blue : .secondary))
        .padding()
        .onDrop(of: [.fileURL], isTargeted: $isDragging, perform: handleDrop)
        .sheet(isPresented: $showPasswordPrompt) {
            PasswordPrompt { enteredPassword in
                encryptAndSave(files: filesToEncrypt, password: enteredPassword)
            }
        }
        .sheet(isPresented: $showDecryptPrompt) {
            PasswordPrompt { password in
                decryptAndUnzip(file: encryptedFileToDecrypt!, password: password)
            }
        }
        .onReceive(appState.$action.combineLatest(appState.$filesToProcess)) { action, filesToProcess in
            guard let action = action, !filesToProcess.isEmpty else { return }

            logger.info("📦 Received action via onReceive: \(action, privacy: .public), files: \(String(describing: filesToProcess), privacy: .public)")

            if action == "encrypt" {
                filesToEncrypt = filesToProcess
                showPasswordPrompt = true
                logger.info("🔐 Triggering password prompt via onReceive.")
            } else if action == "decrypt" {
                encryptedFileToDecrypt = filesToProcess.first!
                showDecryptPrompt = true
                logger.info("🔓 Triggering decrypt prompt via onReceive.")
            }

            // Сброс
            appState.action = nil
            appState.filesToProcess = []
        }
        .alert("Error", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button(String(localized: "OK"), role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "")
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        droppedFiles.removeAll()
        
        var loadedFiles: [URL] = []
        let group = DispatchGroup()
        
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                group.enter()
                _ = provider.loadObject(ofClass: URL.self) { object, _ in
                    defer { group.leave() }
                    if let url = object {
                        loadedFiles.append(url)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            guard let firstFile = loadedFiles.first else { return }
            
            if firstFile.pathExtension == "encrypted" {
                // Расшифровка
                self.showDecryptPrompt(for: firstFile)
            } else {
                // Шифрование
                self.droppedFiles = loadedFiles
                self.filesToEncrypt = loadedFiles
                self.showPasswordPrompt = true
            }
        }
        
        return true
    }
    
    private func encryptAndSave(files: [URL], password: String) {
        do {
            let zipURL = try ArchiveService.createArchive(from: files)
            let archiveURLWithoutExtension = zipURL.deletingPathExtension()
            try FileManager.default.moveItem(at: zipURL, to: archiveURLWithoutExtension)
            
            let encryptedData = try CryptoService.encryptFile(inputURL: archiveURLWithoutExtension, password: password)
            
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [UTType(filenameExtension: "encrypted")!]
            savePanel.nameFieldStringValue = "Archive.encrypted"
            savePanel.begin { result in
                if result == .OK, let url = savePanel.url {
                    do {
                        try encryptedData.write(to: url)
                        print(String(localized: "PrintEncryptionSuccess"), url.path)
                    } catch {
                        self.error = .permissionDenied
                    }
                }
                try? FileManager.default.removeItem(at: archiveURLWithoutExtension)
            }
        } catch {
            self.error = .encryptionFailure
        }
    }
    
    func showDecryptPrompt(for url: URL) {
        encryptedFileToDecrypt = url
        showDecryptPrompt = true
    }
    
    private func decryptAndUnzip(file: URL, password: String) {
        do {
            let encryptedData = try Data(contentsOf: file)
            let decryptedData = try CryptoService.decryptFile(encryptedData: encryptedData, password: password)

            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = false
            openPanel.prompt = String(localized: "SelectFolderToUnpack")
            openPanel.begin { result in
                if result == .OK, let chosenFolder = openPanel.url {
                    do {
                        let destination = chosenFolder
                        try ArchiveService.unzip(data: decryptedData, to: destination)
                        print(String(localized: "PrintDecompressionSuccess"), destination.path)
                    } catch {
                        self.error = .archiveFailure
                    }
                } else {
                    self.error = .userCancelled
                }
            }
        } catch {
            self.error = .decryptionFailure
        }
    }
}

#Preview {
    ContentView(openedFileURL: .constant(nil))
}
