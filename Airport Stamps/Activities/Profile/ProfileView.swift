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
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                if authManager.authState == .signedIn {
                    // PERSONAL INFORMATION
                    Section("Personal Information") {
                        TextField("Enter First Name", text: Binding(
                            get: { self.stampsAppViewModel.firstName },
                            set: {
                                if $0 != self.stampsAppViewModel.firstName {
                                    self.stampsAppViewModel.firstName = $0
                                    self.isSaveDisabled = false
                                }
                            }
                        ))
                        
                        TextField("Enter Last Name", text: Binding(
                            get: { self.stampsAppViewModel.lastName },
                            set: {
                                if $0 != self.stampsAppViewModel.lastName {
                                    self.stampsAppViewModel.lastName = $0
                                    self.isSaveDisabled = false
                                }
                            }
                        ))
                    }
                    
                    Section {
                        Button("Save") {
                            Task {
                                await stampsAppViewModel.save(authManager: authManager)
                            }
                            alertTitle = "Profile Updated"
                            alertMessage = "Your profile information was saved."
                            showingAlert = true
                            isSaveDisabled = true
                        }
                        .frame(maxWidth: .infinity)
                        .disabled($isSaveDisabled.wrappedValue)
                    }
                    
                    Section("Progress") {
                        // Content
                        NavigationLink("Past Visits") {
                            PastVisitsView()
                        }

                        HStack {
                            Text("Ambassador Level:")
                            
                            Spacer()
                            
                            Text(stampsAppViewModel.ambassadorLevel.status.title)
                                .foregroundStyle(Color.secondary)
                        }
                    }


                    Section {
                        Button("Verify") {

                        }
                        .frame(maxWidth: .infinity)
                        //.disabled($isSaveDisabled.wrappedValue)
                    } footer: {
                        // Footer content
                        Text("Once you complete a level, please click the verify button to begin the verification process and claim your prize!")
                    }
                }
                
                // PROGRAM INFORMATION
                Section("Program Information") {
                    Link("Ambassadors Program", 
                         destination: URL(string: "https://doav.virginia.gov/programs-and-services/ambassadors-program/")!
                    )
                    
                    Link("Virginia Department of Aviation", 
                         destination: URL(string: "https://doav.virginia.gov/")!
                    )
                    
                    Link(destination: URL(string: "telprompt://8042363624")!) {
                        Label("Contact Us", systemImage: "phone.fill")
                    }
                }
                    
                Section {
                    Button(authManager.authState != .signedIn ? "Sign in" : "Sign out") {
                        if authManager.authState != .signedIn {
                            showLoginSheet = true
                        } else {
                            Task {
                                await stampsAppViewModel.signOut(authManager: authManager)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(authManager.authState != .signedIn ? Color.accentColor : .red)
                }
            }
            .listSectionSpacing(16)
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            // Add Alert
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
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
