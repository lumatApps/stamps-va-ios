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
    var stamps: [Stamp] = []
    var stampVisibility: StampVisibility = .all

    
    init() {
        Task {
            await loadData()
        }
    }
 
    func loadData() async {
        print("❌ stamps from cloud")
        await fetchStampLocationsCloud()
    }
    
    func fetchStampLocationsCloud() async {
        do {
            stamps = try await FirebaseService.fetchAllDocuments(from: "stamps")
        } catch {
            print("Error fetching document: \(error)")
        }
    }
    
    
    func verifyUserLocation(locationManager: LocationManager, stamp: Stamp) -> Bool {
        let stampLocation = CLLocation(latitude: stamp.coordinates.latitude, longitude: stamp.coordinates.longitude)
        
        if let userLocation = locationManager.location {
            let distance = userLocation.distance(from: stampLocation)
            return distance < 2500
        }
        
        return false
    }

    func findNearbyStamp(locationManager: LocationManager) -> Stamp? {
        guard let userLocation = locationManager.location else { return nil }
        
        for stamp in stamps {
            let stampLocation = CLLocation(latitude: stamp.coordinates.latitude, longitude: stamp.coordinates.longitude)
            let distance = userLocation.distance(from: stampLocation)
            
            if distance < 2500 {
                return stamp
            }
        }
        
        // If no stamp is within 2500 meters, return nil
        return nil
    }
    
    // Navigates user to specified coordinate in the map view
    func goTo(item: MKMapItem) {
        withAnimation {
            position = .item(item)
        }
    }
    
    func setStampVisibility(to stampVisibility: StampVisibility) {
        self.stampVisibility = stampVisibility
    }
}

enum StampVisibility: String, CaseIterable {
    case all = "All Stamps"
    case collected = "Collected Stamps"
    case uncollected = "Uncollected Stamps"
}
