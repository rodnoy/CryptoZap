//
//  CryptoZapApp.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//

import SwiftUI

@main
struct CryptoZapApp: App {
    @State private var openedFileURL: URL?
    var body: some Scene {
        WindowGroup {
            ContentView(openedFileURL: $openedFileURL)
                .onOpenURL { url in
                    openedFileURL = url
                }
        }
    }
}
