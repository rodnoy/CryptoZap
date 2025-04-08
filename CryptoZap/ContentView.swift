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

           for provider in providers {
               if provider.canLoadObject(ofClass: URL.self) {
                   _ = provider.loadObject(ofClass: URL.self) { object, _ in
                       if let url = object {
                           DispatchQueue.main.async {
                               self.droppedFiles.append(url)
                           }
                       }
                   }
               }
           }

           return true
       }
}

#Preview {
    ContentView()
}
