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
    @Environment(MapViewModel.self) var mapViewModel
    @State private var isShowingScanner = false
    var mapScope: Namespace.ID
    
    var body: some View {
        Group {
            MapButtonView(systemName: "mappin.circle", primaryColor: Color.primary, secondaryColor: .red) {
                //mapViewModel.toggleMapButtonVisibility(.adaParkingSpot)
            }
            
            MapButtonView(systemName: "mappin.circle", primaryColor: Color.primary, secondaryColor: .green) {
                //mapViewModel.toggleMapButtonVisibility(.adaParkingSpot)
            }
            
            
            MapButtonView(systemName: "qrcode.viewfinder") {
                isShowingScanner = true
            }
            
            MapUserLocationButton(scope: mapScope)
            MapCompass(scope: mapScope)
        }
        .buttonBorderShape(.roundedRectangle)
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], showViewfinder: true, completion: handleScan)
                .ignoresSafeArea()
        }
    }
    
    
    func handleScan(result: Result<ScanResult, ScanError>) {
       isShowingScanner = false
       
        switch result {
        case .success(let result):
            let code = result.string

            if mapViewModel.stamps.contains { $0.id == code } {
                print("Success \(code)")
            }
            
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}
