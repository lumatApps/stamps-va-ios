//
//  StampsView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct StampsView: View {
    static let tag = AppConstants.stamps.tab
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(MapViewModel.self) var mapViewModel
    @State private var isShowingGrid = true

    var body: some View {
        NavigationStack {
            Group {
                if isShowingGrid {
                    StampsGridView()
                } else {
                    RewardProgressView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(profileViewModel.stamps.count) / \(mapViewModel.stamps.count)")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingGrid.toggle()
                    } label: {
                        Image(systemName: isShowingGrid ? "trophy" : "square.grid.3x3")
                    }
                }
            }
            .navigationTitle(AppConstants.stamps.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StampsView()
        .environment(ProfileViewModel())
        .environment(MapViewModel())
}
