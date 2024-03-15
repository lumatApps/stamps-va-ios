//
//  StampImageView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/14/24.
//

import SwiftUI

struct StampImageView: View {
    var stamp: Stamp
    var isGridZoomed: Bool
    var selectedStampReference: CollectedStamp?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "https://storage.googleapis.com/stamps-va/stamp-images/\(stamp.id).png")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            if selectedStampReference == nil {
                                if isGridZoomed {
                                    Text(stamp.id)
                                        .font(.title3)
                                        .fontWeight(.heavy)
                                        .foregroundStyle(.red)
                                        .padding(3)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                                        .offset(y: 15.0)
                                }
                            } else {
                                Text(stamp.id)
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.red)
                                    .padding(3)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                                    .offset(y: 50.0)
                            }
                        }
                } else if phase.error != nil {
                    Image(systemName: stamp.icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                        .overlay {
                            if selectedStampReference == nil {
                                if isGridZoomed {
                                    Text(stamp.id)
                                        .font(.title3)
                                        .fontWeight(.heavy)
                                        .foregroundStyle(.red)
                                        .padding(3)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                                        .offset(y: 15.0)
                                }
                            } else {
                                Text(stamp.id)
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.red)
                                    .padding(3)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                                    .offset(y: 50.0)
                            }
                        }
                } else {
                    ProgressView()
                }
            }
        }
    }
}
