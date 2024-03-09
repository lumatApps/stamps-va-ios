//
//  StampsGridView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/7/24.
//

import SwiftUI

struct StampsGridView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(MapViewModel.self) var mapViewModel
    var collectedStamps: [Stamp]

    var columns: [GridItem] {
        switch sizeClass {
        case .compact:
            return Array(repeating: GridItem(.flexible(minimum: 100, maximum: 200)), count: 3)
        default:
            return Array(repeating: GridItem(.flexible(minimum: 100, maximum: 200)), count: 5)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(collectedStamps) { stamp in
                    Button {
                        // no action yet
                    } label: {
                        AsyncImage(url: URL(string: "https://storage.googleapis.com/stamps-va/stamp-images/\(stamp.id).png")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Text("✈️")
                                .font(.system(size: 80))
//                            Image(systemName: stampDetail?.icon ?? "airplane")
//                                .resizable()
//                                .scaledToFit()
                        }
                        .padding()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

//#Preview {
//    StampsGridView()
//        .environment(ProfileViewModel())
//        .environment(MapViewModel())
//}