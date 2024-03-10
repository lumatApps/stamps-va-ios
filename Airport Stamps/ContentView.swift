//
//  ContentView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var body: some View {
        if authManager.authState != .signedOut {
            StampsAppView()
                .onAppear {
                    Task {
                        if authManager.authState == .signedIn {
                            await profileViewModel.loadCollector(authManager: authManager)
                        }
                    }
                }
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
        .environment(LocationManager())
        .environment(MapViewModel())
        .environment(PassportViewModel())
        .environment(ProfileViewModel())
}
