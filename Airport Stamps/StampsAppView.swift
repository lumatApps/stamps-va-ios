//
//  StampsAppView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//

import SwiftUI

struct StampsAppView: View {
    var body: some View {
        TabView {
            MapView()
                .tag(MapView.tag)
                .tabItem {
                    Label(AppConstants.map.tab, systemImage: AppConstants.map.icon)
                }
            
            StampsView()
                .tag(StampsView.tag)
                .tabItem {
                    Label(AppConstants.stamps.tab, systemImage: AppConstants.stamps.icon)
                }
            
            ProfileView()
                .tag(ProfileView.tag)
                .tabItem {
                    Label(AppConstants.profile.tab, systemImage: AppConstants.profile.icon)
                }
        }
    }
}


#Preview {
    StampsAppView()
        .environment(AuthManager())
        .environment(LocationManager())
        .environment(MapViewModel())
}
