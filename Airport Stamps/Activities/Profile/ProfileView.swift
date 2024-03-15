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
    
    // Alert
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var hapticFeedbackTrigger: HapticFeedbackTrigger?
    
    var body: some View {
        @Bindable var stampsAppViewModel = stampsAppViewModel
        
        NavigationStack {
            List {
                if authManager.authState == .signedIn {
                    if authManager.authState == .signedIn {
                        PersonalInformationSection(
                            firstName: $stampsAppViewModel.firstName,
                            lastName: $stampsAppViewModel.lastName,
                            isSaveDisabled: $isSaveDisabled
                        )
                    }
                    
                    Section {
                        Button("Save") {
                            var saveSuccessful = false
                            
                            Task {
                                saveSuccessful = await stampsAppViewModel.save(authManager: authManager)
                            }
                            
                            if saveSuccessful {
                                showAlert(for: .profileSaved)
                            } else {
                                showAlert(for: .profileNotSaved)
                            }
                            
                            isSaveDisabled = true
                        }
                        .frame(maxWidth: .infinity)
                        .disabled($isSaveDisabled.wrappedValue)
                    }

                    ProgressSectionView(ambassadorLevel: stampsAppViewModel.ambassadorLevel.status)

                    Section {
                        Button("Verify") {
                            showAlert(for: .verificationSubmitted)
                        }
                        .frame(maxWidth: .infinity)
                        //.disabled($isSaveDisabled.wrappedValue)
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
                            Task {
                                await stampsAppViewModel.deleteAccount(authManager: authManager)
                            }
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
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
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
