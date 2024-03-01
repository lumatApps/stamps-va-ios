//
//  ProfileView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct ProfileView: View {
    static let tag = Constants.profile.tab
    
    @Environment(AuthManager.self) var authManager
    @State private var showLoginSheet = false
    
    var body: some View {
        VStack {
            Button {
                if authManager.authState != .signedIn {
                    showLoginSheet = true
                } else {
                    signOut()
                }
            } label: {
                Text(authManager.authState != .signedIn ? "Sign-in" :"Sign out")
                    .font(.body.bold())
                    .frame(width: 120, height: 45, alignment: .center)
                    .foregroundStyle(.yellow)
                    .background(.blue)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
    
    
    func signOut() {
        Task {
            do {
                try await authManager.signOut()
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
}

#Preview {
    ProfileView()
}
