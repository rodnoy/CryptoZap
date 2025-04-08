//
//  ContentView.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import CryptoKit
struct ContentView: View {
    @State private var isDragging = false
    @State private var droppedFiles: [URL] = []
    @State private var showPasswordPrompt = false
    @State private var filesToEncrypt: [URL] = []
    @State private var encryptedFileToDecrypt: URL?
    @State private var showDecryptPrompt = false
    var body: some View {
        VStack(spacing: 20) {
            Button("Расшифровать файл") {
                let openPanel = NSOpenPanel()
                openPanel.allowedContentTypes = [UTType(filenameExtension: "encrypted")!]
                openPanel.begin { result in
                    if result == .OK, let url = openPanel.url {
                        showDecryptPrompt(for: url)
                    }
                }
            }
            Image(systemName: "lock.doc")
                .font(.system(size: 72))
                .foregroundColor(isDragging ? .blue : .secondary)
            
            Text("Перетащите файлы для шифрования")
                .font(.title2)
                .foregroundColor(.secondary)
            
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
            self.droppedFiles = loadedFiles
            self.filesToEncrypt = loadedFiles
            self.showPasswordPrompt = true
        }
        
        return true
    }
    
    private func encryptAndSave(files: [URL], password: String) {
        do {
            let zipURL = try ArchiveManager.createArchive(from: files)
            let archiveURLWithoutExtension = zipURL.deletingPathExtension()
            try FileManager.default.moveItem(at: zipURL, to: archiveURLWithoutExtension)
            
            let encryptedData = try CryptoManager.encryptFile(inputURL: archiveURLWithoutExtension, password: password)
            
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [UTType(filenameExtension: "encrypted")!]
            savePanel.nameFieldStringValue = "Archive.encrypted"
            savePanel.begin { result in
                if result == .OK, let url = savePanel.url {
                    do {
                        try encryptedData.write(to: url)
                        print("Файл успешно зашифрован и сохранён:", url.path)
                    } catch {
                        print("Ошибка сохранения:", error.localizedDescription)
                    }
                }
                try? FileManager.default.removeItem(at: archiveURLWithoutExtension)
            }
        } catch {
            print("Ошибка при шифровании:", error.localizedDescription)
        }
    }
    func showDecryptPrompt(for url: URL) {
        encryptedFileToDecrypt = url
        showDecryptPrompt = true
    }
    private func decryptAndUnzip(file: URL, password: String) {
        do {
            let encryptedData = try Data(contentsOf: file)
            print("🧪 Encrypted file size: \(encryptedData.count)")
            print("🔐 Trying to decrypt with password: \(password)")
            
            let decryptedData: Data
            do {
                decryptedData = try CryptoManager.decryptFile(encryptedData: encryptedData, password: password)
            } catch let error as CryptoKitError {
                switch error {
                case .authenticationFailure:
                    print("❌ Ошибка: Неверный пароль или повреждённые данные (authentication failure).")
                default:
                    print("❌ CryptoKit ошибка:", error)
                }
                return
            }
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories = true
            openPanel.canChooseFiles = false
            openPanel.prompt = "Выбрать папку для распаковки"
            openPanel.begin { result in
                if result == .OK, let chosenFolder = openPanel.url {
                    do {
                        let fileNameWithoutExtension = file.deletingPathExtension().lastPathComponent
                        let targetFolder = chosenFolder.appendingPathComponent("Decrypted-\(fileNameWithoutExtension)")
                        var finalTargetFolder = targetFolder
                        var counter = 1
                        while FileManager.default.fileExists(atPath: finalTargetFolder.path) {
                            finalTargetFolder = chosenFolder.appendingPathComponent("Decrypted-\(fileNameWithoutExtension)-\(counter)")
                            counter += 1
                        }
                        try FileManager.default.createDirectory(at: finalTargetFolder, withIntermediateDirectories: true)
                        try ArchiveManager.unzip(data: decryptedData, to: finalTargetFolder)
                        print("✅ Распаковано в:", finalTargetFolder.path)
                    } catch {
                        print("❌ Ошибка при распаковке:", error.localizedDescription)
                    }
                } else {
                    print("🚫 Пользователь отменил выбор папки")
                }
            }
        } catch {
            print("❌ Ошибка при расшифровке:", error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
