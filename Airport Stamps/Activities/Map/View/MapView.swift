//
//  MapView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    static let tag = AppConstants.map.tab
    
    // Services and ViewModels
    @Environment(AuthManager.self) var authManager
    @Environment(LocationManager.self) var locationManager
    @Environment(MapViewModel.self) var mapViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    
    @State private var selectedItem: Stamp.ID?
    @State private var isShowingSheet = false
    
    // Search
    @State private var searchText = ""
    @State private var dismissSearch = false
    
    // Alert
    @State private var showingAuthAlert = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Namespace var mapScope
    
    var selectedStamp: Stamp? {
        mapViewModel.stamps.first(where: { $0.id == selectedItem })
    }
    
    var filteredStamps: [Stamp] {
        switch mapViewModel.stampVisibility {
        case .all:
            return mapViewModel.stamps
        case .collected:
            return mapViewModel.stamps.filter { stamp in
                profileViewModel.stamps.contains(where: { profileStamp in
                    profileStamp.id == stamp.id
                })
            }
        case .uncollected:
            return mapViewModel.stamps.filter { stamp in
                !profileViewModel.stamps.contains(where: { profileStamp in
                    profileStamp.id == stamp.id
                })
            }
        }
    }

    var body: some View {
        @Bindable var mapViewModel = mapViewModel
        @Bindable var profileViewModel = profileViewModel
        
        NavigationStack {
            ZStack {
                Map(position: $mapViewModel.position, selection: $selectedItem, scope: mapScope) {
                    UserAnnotation()
                    
                    ForEach(filteredStamps) { stamp in
                        Marker(stamp.name, systemImage: stamp.icon, coordinate: stamp.coordinates)
                            .tint($profileViewModel.stamps.contains { $0.id == stamp.id } ? .green : .red)
                    }
                }
                
                MapSearchView(dismiss: $dismissSearch)
            }
            .overlay(alignment: .topTrailing) {
                MapPanelView(mapScope: mapScope, findNearbyStamp: findNearbyStamp)
            }
            .mapScope(mapScope)
            .mapControls {
                MapScaleView(scope: mapScope)
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .onChange(of: selectedItem) {
                if let item = selectedStamp {
                    mapViewModel.goTo(item: MKMapItem(latitude: item.coordinates.latitude, longitude: item.coordinates.longitude))
                    isShowingSheet.toggle()
                }
            }
            .searchable(text: $searchText, prompt: "Search..") {
                ForEach(searchResults) { result in
                    Text(result.name).searchCompletion(result.name)
                }
            }
            .onSubmit(of: .search, search)
            .sheet(isPresented: $isShowingSheet, onDismiss: {
                withAnimation {
                    selectedItem = nil
                }
            }) {
                if let stamp = selectedStamp {
                    MapSheetView(stamp: stamp, verifyStampAction: verifyStamp)
                }
            }
            // Add Stamp Alert
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            // User Location Permissions Alert
            .alert("Authorization Needed", isPresented: $showingAuthAlert) {
                Button("Cancel", role: .destructive) { locationManager.requestPermission() }
                Button("Request", role: .cancel) { }
            } message: {
                Text("User location is required to verify and approve stamp.")
            }
            .onAppear {
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestPermission()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    MapFilterView()
                }
            }
            .navigationTitle(AppConstants.map.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Returns the building results when a user enters text in the search field
    var searchResults: [Stamp] {
        mapViewModel.stamps.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    // Dismisses the keyboard and focuses map on the searched building
    func search() {
        withAnimation {
            dismissSearch.toggle()
        }

        if let item = searchResults.first {
            mapViewModel.goTo(item: MKMapItem(latitude: item.coordinates.latitude, longitude: item.coordinates.longitude))
        }
    }

    func verifyStamp(stamp: Stamp) {
        let added = profileViewModel.addStamp(id: stamp.id)

        if added {
            Task {
                await profileViewModel.save(authManager: authManager)
                alertTitle = "You Collected a Stamp!"
                alertMessage = "Thanks for visiting \(stamp.name). Go check out your new stamp in the next tab."
                showingAlert = true
            }
        } else {
            alertTitle = "Stamp Not Saved"
            alertMessage = "You have already collected this stamp!"
            showingAlert = true
        }
        
//        if !locationManager.isAuthorized {
//            showingAuthAlert.toggle()
//        } else {
//            let verified = mapViewModel.verifyUserLocation(locationManager: locationManager, stamp: stamp)
//            
//            if verified {
//                let added = profileViewModel.addStamp(id: stamp.id)
//                
//                if added {
//                    Task {
//                        await profileViewModel.save(authManager: authManager)
//                    }
//                    alertTitle = "You Collected a Stamp!"
//                    alertMessage = "Thanks for visiting \(stamp.name). Go check out your new stamp in the next tab."
//                    showingAlert = true
//                } else {
//                    alertTitle = "Stamp Not Saved"
//                    alertMessage = "You have already collected this stamp!"
//                    showingAlert = true
//                }
//            } else {
//                alertTitle = "Stamp Not Saved"
//                alertMessage = "We could not verify your location. Please make sure you a nearby a location shown on the map and check you location permissions in settings."
//                showingAlert = true
//            }
//        }
    }
    
    func findNearbyStamp() {
        let stamp = mapViewModel.findNearbyStamp(locationManager: locationManager)
        
        if let stamp = stamp {
            selectedItem = stamp.id
        }
    }
}


#Preview {
    MapView()
        .environment(AuthManager())
        .environment(LocationManager())
        .environment(MapViewModel())
        .environment(ProfileViewModel())
}
