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
                        let rotation = Double.random(in: -10..<10)
                        
                        AsyncImage(url: URL(string: "https://storage.googleapis.com/stamps-va/stamp-images/\(stamp.id).png")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .overlay(alignment: .bottom) {
                                        Text(stamp.id)
                                            .font(.title3)
                                            .fontWeight(.heavy)
                                            .foregroundStyle(.red)
                                            .background(.ultraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                                    }
                            } else if phase.error != nil {
                                Image(systemName: stamp.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.secondary)
                                    .overlay(alignment: .bottom) {
                                        Text(stamp.id)
                                            .font(.title3)
                                            .fontWeight(.heavy)
                                            .foregroundStyle(.red)
                                            .background(.ultraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                                    }
                            } else {
                                ProgressView()
                            }
                        }
                        .rotationEffect(.degrees(rotation))
                        .padding()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(.passport)
    }
}

//#Preview {
//    StampsGridView()
//        .environment(ProfileViewModel())
//        .environment(MapViewModel())
//}
