//
//  MapView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    static let tag = AppConstants.map.tab
    
    // Services and ViewModels
    @Environment(AuthManager.self) var authManager
    @Environment(LocationManager.self) var locationManager
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    
    @State private var selectedItem: Stamp.ID?
    @State private var isShowingSheet = false
    
    // Search
    @State private var searchText = ""
    @State private var dismissSearch = false
    
    // Alert
    @State var showingAlert = false
    @State var showingAuthAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var hapticFeedbackTrigger: HapticFeedbackTrigger?

    @Namespace var mapScope
    
    @State private var devMode = true
    
    var selectedStamp: Stamp? {
        stampsAppViewModel.stamps.first(where: { $0.id == selectedItem })
    }
    
    var body: some View {
        @Bindable var stampsAppViewModel = stampsAppViewModel
        
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $stampsAppViewModel.position, selection: $selectedItem, scope: mapScope) {
                    UserAnnotation()
                    
                    ForEach(stampsAppViewModel.filteredStamps) { stamp in
                        Marker(stamp.name, systemImage: stamp.icon, coordinate: stamp.coordinates)
                            .tint(stampsAppViewModel.checkCollected(stamp: stamp) ? .green : .red)
                    }
                }
                
                MapSearchView(dismiss: $dismissSearch)
                
                if devMode {
                    Text("Dev Mode (location/date verification off)")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(10)
                        .background(.thickMaterial)
                        .clipShape(Capsule())
                        .padding(.vertical)
                }
            }
            .overlay(alignment: .topTrailing) {
                MapPanelView(mapScope: mapScope, findNearbyStamp: findNearbyStamp, devMode: $devMode)
            }
            .mapScope(mapScope)
            .mapControls {
                MapScaleView(scope: mapScope)
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .onChange(of: selectedItem) {
                if let item = selectedStamp {
                    stampsAppViewModel.goTo(item: MKMapItem(latitude: item.coordinates.latitude, longitude: item.coordinates.longitude))
                    isShowingSheet.toggle()
                }
            }
            .searchable(text: $searchText, prompt: "Search..") {
                ForEach(searchResults) { result in
                    HStack {
                        Text(result.id)
                            .bold()
                            .frame(width: 50, alignment: .leading)
                        Text(result.name)
                    }
                    .foregroundStyle(Color.primary)
                    .searchCompletion(result.name)
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
            .alert(alertTitle, isPresented: $showingAuthAlert) {
                Button("Cancel", role: .destructive) { locationManager.requestPermission() }
                Button("Request", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sensoryFeedback(trigger: hapticFeedbackTrigger) { _, newTrigger in
                switch newTrigger?.type {
                case .stampSavedSuccessfully:
                    return .success
                case .invalidDate, .invalidLocation, .stampAlreadyCollected, .stampNotLocated:
                    return .error
                case .signInRequired, .userLocationRequired:
                    return .warning
                default:
                    return nil
                }
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
        stampsAppViewModel.stamps.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.id.lowercased().contains(searchText.lowercased())
        }
    }

    // Dismisses the keyboard and focuses map on the searched building
    func search() {
        withAnimation {
            dismissSearch.toggle()
        }

        if let item = searchResults.first {
            stampsAppViewModel.goTo(item: MKMapItem(latitude: item.coordinates.latitude, longitude: item.coordinates.longitude))
        }
    }

    @MainActor
    func verifyStamp(stamp: Stamp) {
        if devMode {
            if authManager.authState == .signedIn {
                addStamp(stamp: stamp)
            } else {
                showAlert(for: .signInRequired)
            }
        } else {
            if authManager.authState == .signedIn {
                if !locationManager.isAuthorized {
                    showAlert(for: .userLocationRequired)
                } else {
                    let verifiedLocation = stampsAppViewModel.verifyUserLocation(locationManager: locationManager, stamp: stamp)
                    
                    if verifiedLocation {
                        let isDateValid = stampsAppViewModel.verifyStampDate(stamp: stamp)
                        
                        if isDateValid != false {
                            addStamp(stamp: stamp)
                        } else {
                            showAlert(for: .invalidDate)
                        }
                    } else {
                        showAlert(for: .invalidLocation)
                    }
                }
            } else {
                showAlert(for: .signInRequired)
            }
        }
    }

    @MainActor
    func findNearbyStamp() {
        if authManager.authState == .signedIn {
            let stamp = stampsAppViewModel.findNearbyStamp(locationManager: locationManager)
            
            if let stamp = stamp {
                selectedItem = stamp.id
            } else {
                showAlert(for: .stampNotLocated)
            }
        } else {
            showAlert(for: .signInRequired)
        }
    }
    
    func addStamp(stamp: Stamp) {
        let oldLevel = stampsAppViewModel.ambassadorLevel.status
        let added = stampsAppViewModel.addStamp(id: stamp.id)
        let newLevel = stampsAppViewModel.ambassadorLevel.status
        
        if added {
            Task {
                await stampsAppViewModel.save(authManager: authManager)
            }
            
            if oldLevel == newLevel {
                showAlert(for: .stampSavedSuccessfully(stampName: stamp.name))
            } else {
                showAlert(for: .ambassaadorLevelAchieved(level: newLevel))
            }
        } else {
            showAlert(for: .stampAlreadyCollected)
        }
    }
}


#Preview {
    MapView()
        .environment(AuthManager())
        .environment(LocationManager())
        .environment(StampsAppViewModel())
}
