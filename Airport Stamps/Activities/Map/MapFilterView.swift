//
//  MapFilterView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/7/24.
//

import SwiftUI

struct MapFilterView: View {
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    
    var body: some View {
        Menu {
            ForEach(StampVisibility.allCases, id: \.self) { stampVisibility in
                MenuButtonView(stampVisibility: stampVisibility)
            }
        } label: {
            HStack {
                FilterImageView(stampVisibility: stampsAppViewModel.stampVisibility)
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }
}

struct MenuButtonView: View {
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    var stampVisibility: StampVisibility
    
    var body: some View {
        switch stampVisibility {
        case .all:
            button(for: stampVisibility, count: stampsAppViewModel.stamps.count)
        case .collected:
            button(for: stampVisibility, count: stampsAppViewModel.collectedStamps.count)
        case .uncollected:
            button(for: stampVisibility, count: stampsAppViewModel.stamps.count - stampsAppViewModel.collectedStamps.count)
        case .airports:
            button(for: stampVisibility, count: stampsAppViewModel.stampTypeCount.airport)
        case .museums:
            button(for: stampVisibility, count: stampsAppViewModel.stampTypeCount.museum)
        case .seminars:
            button(for: stampVisibility, count: stampsAppViewModel.stampTypeCount.seminar)
        case .flyIns:
            button(for: stampVisibility, count: stampsAppViewModel.stampTypeCount.flyIn)
        }
    }
    
    func button(for visibility: StampVisibility, count: Int) -> some View {
        Button {
            stampsAppViewModel.setStampVisibility(to: visibility)
            stampsAppViewModel.position = .automatic
        } label: {
            Text("\(visibility.rawValue) (\(count))")
        }
    }
}

struct FilterImageView: View {
    var stampVisibility: StampVisibility
    
    var body: some View {
        switch stampVisibility {
        case .all:
            HStack(spacing: 0) {
                Image(systemName: stampVisibility.icon.systemName)
                    .foregroundStyle(.green)
                Image(systemName: stampVisibility.icon.systemName)
                    .foregroundStyle(.red)
            }
        case .collected, .uncollected:
            Image(systemName: stampVisibility.icon.systemName)
                .foregroundStyle(stampVisibility.icon.color)
        case .airports, .museums, .seminars, .flyIns:
            Image(systemName: stampVisibility.icon.systemName)
                .foregroundStyle(stampVisibility.icon.color)
        }
    }
}


#Preview {
    MapFilterView()
        .environment(StampsAppViewModel())
}
