//
//  MapPanelView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI
import MapKit

struct MapPanelView: View {
    var mapScope: Namespace.ID
    var findNearbyStamp: () -> Void
    
    var body: some View {
        VStack {
            MapButtonView(systemName: "square.badge.plus") {
                findNearbyStamp()
            }
            
            MapUserLocationButton(scope: mapScope)
            MapCompass(scope: mapScope)
        }
        .buttonBorderShape(.roundedRectangle)
        .padding(8)
    }
}
