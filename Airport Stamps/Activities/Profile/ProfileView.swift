//
//  ProfileView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct ProfileView: View {
    static let tag = AppConstants.profile.tab
    @Environment(AuthManager.self) var authManager
    @Environment(ProfileViewModel.self) var profileViewModel
    @State private var showLoginSheet = false
    
    var body: some View {
        @Bindable var profileViewModel = profileViewModel
        
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $profileViewModel.firstName)
                    TextField("Last Name", text: $profileViewModel.lastName)
                    TextField("Email", text: $profileViewModel.email)
                }
                
                
                Button("Save") {
                    Task {
                        await profileViewModel.save(authManager: authManager)
                    }
                }
                
                HStack{
                    
                    Text("3 Stamps collected")
                }
                
                Button(authManager.authState != .signedIn ? "Sign-in" : "Sign out") {
                    if authManager.authState != .signedIn {
                        showLoginSheet = true
                    } else {
                        Task {
                            await profileViewModel.signOut(authManager: authManager)
                        }
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthManager())
        .environment(ProfileViewModel())
}
