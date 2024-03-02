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
    @State private var searchText = ""
    @State private var dismissSearch = false
    @Namespace var mapScope
    
    var body: some View {
        @Bindable var mapViewModel = mapViewModel
        
        NavigationStack {
            ZStack {
                Map(position: $mapViewModel.position, selection: $selectedItem, scope: mapScope) {
                    UserAnnotation()
                    
                    ForEach($mapViewModel.stamps) { $stamp in
                        Marker(stamp.name, systemImage: stamp.icon, coordinate: stamp.coordinates)
                            .tint(profileViewModel.stamps.contains { $0.id == stamp.id } ? .green : .red)
                    }
                }
                
                MapSearchView(dismiss: $dismissSearch)
            }
            .overlay(alignment: .topTrailing) {
                ViewThatFits {
                    VStack {
                        MapPanelView(mapScope: mapScope)
                    }
                    
                    HStack {
                        MapPanelView(mapScope: mapScope)
                    }
                }
                .padding(8)
            }
            .mapScope(mapScope)
            .mapControls {
                MapScaleView(scope: mapScope)
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .onMapCameraChange { camera in
                //
            }
//            .onChange(of: selectedItem) {
//                if let selectedItem {
//                    if let item = mapViewModel.annotationItems.first(where: { $0.id == selectedItem }) {
//                        mapViewModel.goTo(item: MKMapItem(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude))
//                    }
//                }
//            }
//            .safeAreaInset(edge: .bottom) {
//                HStack {
//                    Spacer()
//                }
//                .background(.thinMaterial)
//            }
//            .searchable(text: $searchText, prompt: Constants.searchPrompt) {
//                ForEach(searchResults) { result in
//                    Text(result.title).searchCompletion(result.title)
//                }
//            }
//            .onSubmit(of: .search, search)
            .onAppear {
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestPermission()
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
//            mapViewModel.goTo(item: MKMapItem(latitude: item.coordinates.latitude, longitude: item.coordinates.longitude))
        } else {
            //hapticViewModel.playFailureHapticFeedback()
        }
    }

    
    private struct Constants {
        static let searchPrompt = "Search for an airport..."
    }
}


#Preview {
    MapView()
        .environment(LocationManager())
        .environment(MapViewModel())
}
