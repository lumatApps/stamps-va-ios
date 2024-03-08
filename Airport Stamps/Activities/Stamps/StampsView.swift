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
    @Environment(\.horizontalSizeClass) var sizeClass

    var columns: [GridItem] {
        switch sizeClass {
        case .compact:
            // 3 columns in compact environments
            return Array(repeating: GridItem(.flexible(minimum: 100, maximum: 200)), count: 3)
        default:
            // 5 columns in non-compact environments
            return Array(repeating: GridItem(.flexible(minimum: 100, maximum: 200)), count: 5)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(profileViewModel.stamps) { stamp in
                        let stampDetail = mapViewModel.stamps.first(where: { $0.id == stamp.id })
                        
                        Button {
                            // no action yet
                        } label: {
                            AsyncImage(url: URL(string: "https://storage.googleapis.com/stamps-va/stamp-images/\(stamp.id).png")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Image(systemName: stampDetail?.icon ?? "airplane")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .padding()
                        }
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
}
