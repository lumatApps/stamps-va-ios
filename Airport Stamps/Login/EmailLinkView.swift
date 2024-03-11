//
//  EmailLinkView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/10/24.
//

import SwiftUI

struct EmailLinkView: View {
    @Environment(AuthManager.self) var authManager
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: sendSignInLink) {
                Text("Send Sign-In Link")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(email.isEmpty || isLoading)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if isLoading {
                ProgressView()
                    .padding()
            }
        }
        .padding()
    }
    
    private func sendSignInLink() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
//                try await authManager.sendSignInLink(to: email)
            } catch {
                errorMessage = "Failed to send sign-in link. Please try again."
            }
            isLoading = false
        }
    }
}

#Preview {
    EmailLinkView()
}
