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
    @Environment(LocationManager.self) var locationManager
    @Environment(MapViewModel.self) var mapViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    @State private var selectedItem: Stamp.ID?
    @State private var isSheetPresented = false
    @State private var searchText = ""
    @State private var dismissSearch = false
    @Namespace var mapScope
    
    var filteredStamps: [Stamp] {
        switch mapViewModel.stampVisibility {
        case .all:
            return mapViewModel.stamps
        case .collected:
            // Filter stamps that are contained within profileViewModel.stamps
            return mapViewModel.stamps.filter { stamp in
                profileViewModel.stamps.contains(where: { profileStamp in
                    profileStamp.id == stamp.id
                })
            }
        case .uncollected:
            // Assuming there's a need to check against profileViewModel.stamps to determine if uncollected
            return mapViewModel.stamps.filter { stamp in
                !profileViewModel.stamps.contains(where: { profileStamp in
                    profileStamp.id == stamp.id
                })
            }
        }
    }

    
    var body: some View {
        @Bindable var mapViewModel = mapViewModel
        
        NavigationStack {
            ZStack {
                Map(position: $mapViewModel.position, selection: $selectedItem, scope: mapScope) {
                    UserAnnotation()
                    
                    ForEach(filteredStamps) { stamp in
                        Marker(stamp.name, systemImage: stamp.icon, coordinate: stamp.coordinates)
                            .tint(profileViewModel.stamps.contains { $0.id == stamp.id } ? .green : .red)
                    }
                }
                
                MapSearchView(dismiss: $dismissSearch)
            }
            .overlay(alignment: .topTrailing) {
                MapPanelView(selectedItem: $selectedItem, mapScope: mapScope)
            }
            .mapScope(mapScope)
            .mapControls {
                MapScaleView(scope: mapScope)
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .onChange(of: selectedItem) {
                if let selectedItem {
                    if let item = mapViewModel.stamps.first(where: { $0.id == selectedItem }) {
                        isSheetPresented.toggle()
                        mapViewModel.goTo(item: MKMapItem(latitude: item.coordinates.latitude, longitude: item.coordinates.longitude))
                    }
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                if let item = mapViewModel.stamps.first(where: { $0.id == selectedItem }) {
                    MapSheetDetailView(stamp: item)
                }
            }
            .searchable(text: $searchText, prompt: Constants.searchPrompt) {
                ForEach(searchResults) { result in
                    Text(result.name).searchCompletion(result.name)
                }
            }
            .onSubmit(of: .search, search)
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
        } else {
            //hapticViewModel.playFailureHapticFeedback()
        }
    }

    
    private struct Constants {
        static let searchPrompt = "Search for stamp locations..."
    }
}


#Preview {
    MapView()
        .environment(LocationManager())
        .environment(MapViewModel())
}
