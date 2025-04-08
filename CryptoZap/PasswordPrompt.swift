//
//  PasswordPrompt.swift
//  CryptoZap
//
//  Created by KIRILL SIMAGIN on 08/04/2025.
//


import SwiftUI

struct PasswordPrompt: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var password: String = ""
    
    var onComplete: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            SecureField("Введите пароль", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                }
                Button("OK") {
                    presentationMode.wrappedValue.dismiss()
                    onComplete(password)
                }
                .disabled(password.isEmpty)
            }
            .padding(.bottom)
        }
        .frame(width: 300)
        .padding()
    }
}