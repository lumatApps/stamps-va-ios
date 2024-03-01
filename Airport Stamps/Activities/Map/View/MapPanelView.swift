//
//  MapPanelView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI
import MapKit

struct MapPanelView: View {
    @Bindable var mapViewModel: MapViewModel
    
    var mapScope: Namespace.ID
    
    var body: some View {
        Group {
            MapButtonView(systemName: "airplane", color: Color.secondary) {
                //mapViewModel.toggleMapButtonVisibility(.adaParkingSpot)
            }
            
            MapUserLocationButton(scope: mapScope)
            MapCompass(scope: mapScope)
        }
        .buttonBorderShape(.roundedRectangle)
    }
}


//#Preview {
//    MapPanelView()
//}
