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
                MenuButtonView(stampType: stampType)
            }
        } label: {
            HStack {
                FilterImageView(stampType: mapViewModel.stampVisibility)
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }
}

struct MenuButtonView: View {
    @Environment(MapViewModel.self) var mapViewModel
    var stampType: StampVisibility
    
    var body: some View {
        Button {
            mapViewModel.setStampVisibility(to: stampType)
        } label: {
            Text(stampType.rawValue)
        }
    }
}

struct FilterImageView: View {
    var stampType: StampVisibility
    
    var body: some View {
        switch stampType {
        case .all:
            HStack(spacing: 0) {
                Image(systemName: "mappin")
                    .foregroundStyle(.green)
                Image(systemName: "mappin")
                    .foregroundStyle(.red)
            }
        case .collected:
            Image(systemName: "mappin")
                .foregroundStyle(.green)
        case .uncollected:
            Image(systemName: "mappin")
                .foregroundStyle(.red)
        }
    }
}


#Preview {
    MapFilterView()
}
