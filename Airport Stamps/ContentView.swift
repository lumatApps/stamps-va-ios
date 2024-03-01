//
//  ContentView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) var authManager
    
    var body: some View {
        if authManager.authState != .signedOut {
            StampsAppView()
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
}
