//
//  MapPanelView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import CodeScanner
import SwiftUI
import MapKit

struct MapPanelView: View {
    @Binding var selectedItem: Stamp.ID?
    var mapScope: Namespace.ID
    
    var body: some View {
        ViewThatFits {
            VStack {
                PanelView(selectedItem: $selectedItem, mapScope: mapScope)
            }
            
            HStack {
                PanelView(selectedItem: $selectedItem, mapScope: mapScope)
            }
        }
        .padding(8)
    }
}


struct PanelView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(LocationManager.self) var locationManager
    @Environment(MapViewModel.self) var mapViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    @State private var isShowingScanner = false
    @Binding var selectedItem: Stamp.ID?
    var mapScope: Namespace.ID
    
    var body: some View {
        Group {
//            MapButtonView(systemName: "qrcode.viewfinder") {
//                isShowingScanner = true
//            }
            
            if let item = mapViewModel.stamps.first(where: { $0.id == selectedItem }) {
                MapButtonView(systemName: "square.badge.plus") {
                    verifyStamp(stamp: item)
                }
            }
            
            MapUserLocationButton(scope: mapScope)
            MapCompass(scope: mapScope)
        }
        .buttonBorderShape(.roundedRectangle)
//        .sheet(isPresented: $isShowingScanner) {
//            CodeScannerView(codeTypes: [.qr], showViewfinder: true, completion: handleScan)
//                .ignoresSafeArea()
//        }
    }
    
    
    func verifyStamp(stamp: Stamp) {
        let verified = mapViewModel.verifyUserLocation(locationManager: locationManager, stamp: stamp)
        
        if verified {
            let added = profileViewModel.addStamp(id: stamp.id)
            
            if added {
                Task {
                    await profileViewModel.save(authManager: authManager)
                }
            } else {
                print("Stamp not saved: Added = \(added)")
            }
        } else {
            print("Stamp not saved: Verified = \(verified)")
        }
    }
    
    
//    func handleScan(result: Result<ScanResult, ScanError>) {
//       isShowingScanner = false
//       
//        switch result {
//        case .success(let result):
//            let code = result.string
//
//            if mapViewModel.stamps.contains { $0.id == code } {
//                print("Success \(code)")
//                profileViewModel.addStamp(id: code)
//                
//                Task {
//                    await profileViewModel.save(authManager: authManager)
//                }
//            }
//            
//            
//        case .failure(let error):
//            print("Scanning failed: \(error.localizedDescription)")
//        }
//    }
}
