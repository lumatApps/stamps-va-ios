//
//  Airport_StampsApp.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI
import Firebase

@main
struct Airport_StampsApp: App {
    // Services & Managers
    @State private var authManager: AuthManager
    @State private var locationManager = LocationManager()
    @State private var stampsAppViewModel: StampsAppViewModel

    init() {
        FirebaseApp.configure()
        authManager = AuthManager()
        stampsAppViewModel = StampsAppViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(locationManager)
                .environment(stampsAppViewModel)
        }
    }
}
