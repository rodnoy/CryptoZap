//
//  ContentView.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//

import SwiftUI
import UniformTypeIdentifiers
struct ContentView: View {
    @State private var isDragging = false
    @State private var droppedFiles: [URL] = []

       var body: some View {
           VStack(spacing: 20) {
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
               
               do {
                   // 1. Создание архива
                   let zipURL = try ArchiveManager.createArchive(from: loadedFiles)
                   
                   // 2. Удаление расширения
                   let archiveURLWithoutExtension = zipURL.deletingPathExtension()
                   try FileManager.default.moveItem(at: zipURL, to: archiveURLWithoutExtension)
                   
                   // 3. Шифрование файла (с паролем пока что статичным)
                   let password = "TestPassword123" // Для теста, потом заменим вводом из UI
                   let encryptedData = try CryptoManager.encryptFile(inputURL: archiveURLWithoutExtension, password: password)
                   
                   // 4. Сохранение с кастомным расширением (.encrypted)
                   let savePanel = NSSavePanel()
//                   savePanel.allowedFileTypes = ["encrypted"]
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
                       // Удаляем временный архив
                       try? FileManager.default.removeItem(at: archiveURLWithoutExtension)
                   }
                   
               } catch {
                   print("Ошибка при шифровании:", error.localizedDescription)
               }
           }

               return true
       }
}

#Preview {
    ContentView()
}
