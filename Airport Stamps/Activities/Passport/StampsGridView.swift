//
//  StampsGridView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/7/24.
//

import SwiftUI

struct StampsGridView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    @State private var gridBig = false

    var columns: [GridItem] {
        switch sizeClass {
        case .compact:
            if gridBig {
                return Array(repeating: GridItem(.flexible(minimum: 100, maximum: 200)), count: 3)
            } else {
                return Array(repeating: GridItem(.flexible(minimum: 40, maximum: 60)), count: 8)
            }
        default:
            return Array(repeating: GridItem(.flexible(minimum: 50, maximum: 100)), count: 10)
        }
    }
    
    var body: some View {
        @Bindable var stampsAppViewModel = stampsAppViewModel
        
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(stampsAppViewModel.collectedStamps) { stampReference in
                    if let stamp = stampsAppViewModel.collectedStampsDictionary[stampReference.id] {
                        Button {
                            // no action yet
                        } label: {
                            let rotation = Double.random(in: -10..<10)
                            
                            AsyncImage(url: URL(string: "https://storage.googleapis.com/stamps-va/stamp-images/\(stamp.id).png")) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
//                                        .overlay(alignment: .bottom) {
//                                            Text(stamp.id)
//                                                .font(.title3)
//                                                .fontWeight(.heavy)
//                                                .foregroundStyle(.red)
//                                                .padding(3)
//                                                .background(.ultraThinMaterial)
//                                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
//                                                .padding(.bottom, 5)
//                                        }
                                } else if phase.error != nil {
                                    Image(systemName: stamp.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.secondary)
//                                        .overlay(alignment: .bottom) {
//                                            Text(stamp.id)
//                                                .font(.title3)
//                                                .fontWeight(.heavy)
//                                                .foregroundStyle(.red)
//                                                .padding(3)
//                                                .background(.ultraThinMaterial)
//                                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
//                                                .padding(.bottom, 5)
//                                        }
                                } else {
                                    ProgressView()
                                }
                            }
                            .rotationEffect(.degrees(rotation))
//                            .padding()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
            .padding()
        }
        .background(.passport)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    gridBig.toggle()
                } label: {
                    Image(systemName: "line.horizontal.3.decrease")
                }
            }
        }
    }
}


#Preview {
    StampsGridView()
        .environment(StampsAppViewModel())
}
