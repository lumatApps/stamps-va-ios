//
//  MapFilterView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/7/24.
//

import SwiftUI

struct MapFilterView: View {
    @Environment(MapViewModel.self) var mapViewModel
    
    var body: some View {
        Menu {
            ForEach(StampVisibility.allCases, id: \.self) { stampType in
                FilterImageButtonView(stampType: stampType)
            }
        } label: {
            HStack {
                FilterImageView(stampType: mapViewModel.stampVisibility)
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }
}

struct FilterImageButtonView: View {
    @Environment(MapViewModel.self) var mapViewModel
    var stampType: StampVisibility
    
    var body: some View {
        Button {
            mapViewModel.setStampVisibility(to: stampType)
        } label: {
            FilterImageView(stampType: stampType)
            Text(stampType.rawValue)
        }
    }
}

struct FilterImageView: View {
    var stampType: StampVisibility
    
    var body: some View {
        switch stampType {
        case .all:
            Image(systemName: "mappin.circle")
                .foregroundStyle(Color.primary)
            
        case .collected:
            Image(systemName: "mappin.circle")
                .foregroundStyle(Color.primary, .green)
        case .uncollected:
            Image(systemName: "mappin.circle")
                .foregroundStyle(Color.primary, .red)
        }
    }
}


#Preview {
    MapFilterView()
}
