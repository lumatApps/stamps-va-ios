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
    
    // ViewModels
    @State private var mapViewModel: MapViewModel
    @State private var passportViewModel: PassportViewModel
    @State private var profileViewModel: ProfileViewModel

    init() {
        FirebaseApp.configure()
        authManager = AuthManager()
        mapViewModel = MapViewModel()
        passportViewModel = PassportViewModel()
        profileViewModel = ProfileViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(locationManager)
                .environment(mapViewModel)
                .environment(passportViewModel)
                .environment(profileViewModel)
        }
    }
}
