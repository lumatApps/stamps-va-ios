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
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    
    @State private var showLoginSheet = false
    @State private var isSaveDisabled = true
    @FocusState private var focusedField: PersonalInformationSection.Field?
    
    // Alert
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var hapticFeedbackTrigger: HapticFeedbackTrigger?
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        @Bindable var stampsAppViewModel = stampsAppViewModel
        
        NavigationStack {
            List {
                if authManager.authState == .signedIn {
                    PersonalInformationSection(
                        firstName: $stampsAppViewModel.firstName,
                        lastName: $stampsAppViewModel.lastName,
                        isSaveDisabled: $isSaveDisabled
                    )

                    ProgressSectionView(ambassadorLevel: stampsAppViewModel.ambassadorLevel.status)

                    Section {
                        Button("Verify") {
                            showAlert(for: .verificationSubmitted)
                        }
                        .frame(maxWidth: .infinity)
                        //.disabled($isSaveDisabled.wrappedValue)
                        .alert(
                            alertTitle,
                            isPresented: $showingAlert
                        ) {
                            Button("OK") {
                                showingAlert = false
                            }
                        } message: {
                            Text(alertMessage)
                        }
                    } footer: {
                        Text("Once you complete a level, please click the verify button to begin the verification process and claim your prize!")
                    }
                }
                
                ProgramInformationSection()
                    
                AuthenticationSection(
                    showLoginSheet: $showLoginSheet,
                    authState: authManager.authState,
                    signInOrOutAction: {
                        if authManager.authState != .signedIn {
                            showLoginSheet = true
                        } else {
                            Task {
                                await stampsAppViewModel.signOut(authManager: authManager)
                            }
                        }
                    }
                )
                
                if authManager.authState == .signedIn {
                    Section {
                        Button("Delete account") {
                            showDeleteAccountAlert.toggle()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.red)
                    }
                }
            }
            .listSectionSpacing(16)
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            .alert(
                alertTitle,
                isPresented: $showingAlert
            ) {
                Button("OK") {
                    showingAlert = false
                }
            } message: {
                Text(alertMessage)
            }
            .confirmationDialog("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Yes, Delete", role: .destructive) {
                    Task {
                        await stampsAppViewModel.deleteAccount(authManager: authManager)
                    }
                }
            } message: {
                Text("Deleting account is permanent. Are you sure you want to delete your account?")
            }
            .onChange(of: authManager.authState) {
                if authManager.authState == .signedIn {
                    Task {
                        print("sign in load")
                        await stampsAppViewModel.attachListeners(authManager: authManager)
                    }
                }
            }
            .navigationTitle(AppConstants.profile.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthManager())
        .environment(StampsAppViewModel())
}
