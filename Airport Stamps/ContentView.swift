//
//  ContentView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    
    var body: some View {
        Group {
            if authManager.authState != .signedOut {
                StampsAppView()
                    .onAppear {
                        Task {
                            await stampsAppViewModel.attachListeners(authManager: authManager)
                        }
                    }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
        .environment(LocationManager())
        .environment(StampsAppViewModel())
}
