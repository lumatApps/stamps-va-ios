//
//  MapViewModel.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit

@Observable class MapViewModel {
    var position: MapCameraPosition = .automatic
    var locations: [StampLocation] = []
    
    init() {
        Task {
            await loadData()
        }
    }
 
    func loadData() async {
        await fetchStampLocationsCloud()
    }
    
    func fetchStampLocationsCloud() async {
        do {
            locations = try await FirebaseService.fetchAllDocuments(from: "airports")
        } catch {
            print("Error fetching document: \(error)")
        }
    }
    
    
    // Navigates user to specified coordinate in the map view
    func goTo(item: MKMapItem) {
        withAnimation {
            position = .item(item)
        }
    }

}
