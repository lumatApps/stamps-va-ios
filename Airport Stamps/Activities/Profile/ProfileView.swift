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
    @State private var isSaveDisabled = true
    // Alert
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        @Bindable var profileViewModel = profileViewModel
        
        NavigationStack {
            List {
                if authManager.authState == .signedIn {
                    // PERSONAL INFORMATION
                    Section("Personal Information") {
                        TextField("Enter First Name", text: Binding(
                            get: { self.profileViewModel.firstName },
                            set: {
                                if $0 != self.profileViewModel.firstName {
                                    self.profileViewModel.firstName = $0
                                    self.isSaveDisabled = false
                                }
                            }
                        ))
                        
                        TextField("Enter Last Name", text: Binding(
                            get: { self.profileViewModel.lastName },
                            set: {
                                if $0 != self.profileViewModel.lastName {
                                    self.profileViewModel.lastName = $0
                                    self.isSaveDisabled = false
                                }
                            }
                        ))
                    }
                    
                    Section {
                        Button("Save") {
                            Task {
                                await profileViewModel.save(authManager: authManager)
                            }
                            alertTitle = "Profile Updated"
                            alertMessage = "Your profile information was saved."
                            showingAlert = true
                            isSaveDisabled = true
                        }
                        .frame(maxWidth: .infinity)
                        .disabled($isSaveDisabled.wrappedValue)
                    }
                    
                    
                    // PROGRAM PROGRESS
                    Section("Program Progress") {
                        NavigationLink("Past Visits") {
                            PastVisitsView()
                        }
                        
                        HStack {
                            Text("Ambassador Level:")
                            
                            Spacer()
                            
                            Text("N/A")
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    
                    Section {
                        Button("Verify") {

                        }
                        .frame(maxWidth: .infinity)
                        //.disabled($isSaveDisabled.wrappedValue)
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
                                await profileViewModel.signOut(authManager: authManager)
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
                        await profileViewModel.loadCollector(authManager: authManager)
                    }
                }
            }
//            .onAppear {
//                Task {
//                    guard let isAnonymous = authManager.user?.isAnonymous else {
//                        return
//                    }
//                            
//                    if profileViewModel.collector == nil && !isAnonymous {
//                        print("Load Collector - Profile")
//                        await profileViewModel.loadCollector(authManager: authManager)
//                    }
//                }
//            }
            .navigationTitle(AppConstants.profile.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthManager())
        .environment(ProfileViewModel())
}
