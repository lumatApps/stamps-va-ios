//
//  MapPanelView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI
import MapKit

struct MapPanelView: View {
    @Environment(LocationManager.self) var locationManager
    var mapScope: Namespace.ID
    var findNearbyStamp: () -> Void
    var showLocationPermissionsAlert: () -> Void
    @Binding var devMode: Bool
    
    var body: some View {
        VStack {
            MapButtonView(systemName: "hammer.fill", primaryColor: devMode ? .red : .accent) {
                devMode.toggle()
            }
            
            MapButtonView(systemName: "square.badge.plus") {
                findNearbyStamp()
            }
            
            if locationManager.isAuthorized {
                MapUserLocationButton(scope: mapScope)
            } else {
                MapButtonView(systemName: "location.fill.viewfinder") {
                    showLocationPermissionsAlert()
                }
            }
            
            MapCompass(scope: mapScope)
        }
        .buttonBorderShape(.roundedRectangle)
        .padding(8)
    }
}
