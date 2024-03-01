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
                    Label(Constants.map.tab, systemImage: Constants.map.icon)
                }
            
            StampsView()
                .tag(StampsView.tag)
                .tabItem {
                    Label(Constants.stamps.tab, systemImage: Constants.stamps.icon)
                }
            
            ProfileView()
                .tag(ProfileView.tag)
                .tabItem {
                    Label(Constants.profile.tab, systemImage: Constants.profile.icon)
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
