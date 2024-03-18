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
    @State private var isGridZoomed = false
    @State private var selectedStampReference: CollectedStamp?
    
    var columns: [GridItem] {
        switch sizeClass {
        case .compact:
            if isGridZoomed {
                return Array(repeating: GridItem(.flexible(minimum: 100, maximum: 200)), count: 3)
            } else {
                return Array(repeating: GridItem(.flexible(minimum: 30, maximum: 60)), count: 8)
            }
        default:
            if isGridZoomed {
                return Array(repeating: GridItem(.flexible(minimum: 100, maximum: 200)), count: 6)
            } else {
                return Array(repeating: GridItem(.flexible(minimum: 50, maximum: 100)), count: 14)
            }
        }
    }
    
    var body: some View {
        @Bindable var stampsAppViewModel = stampsAppViewModel
        
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(stampsAppViewModel.collectedStampReferences) { stampReference in
                    if let stamp = stampsAppViewModel.collectedStampsDictionary[stampReference.id] {
                        Button {
                            withAnimation {
                                selectedStampReference = stampReference
                            }
                        } label: {
                            let rotation = Double.random(in: -10..<10)
                            
                            StampImageView(stamp: stamp, isGridZoomed: isGridZoomed)
                                .rotationEffect(.degrees(rotation))
                        }
                        .buttonStyle(.plain)
                        .padding(isGridZoomed ? 5 : 1)
                    }
                }
            }
            .padding()
        }
        .overlay {
            if let stampReference = selectedStampReference {
                if let stamp = stampsAppViewModel.collectedStampsDictionary[stampReference.id] {
                    Button {
                        withAnimation {
                            selectedStampReference = nil
                        }
                    } label: {
                        VStack {
                            StampImageView(stamp: stamp, isGridZoomed: isGridZoomed, selectedStampReference: selectedStampReference)
                                .padding(.horizontal)
                                .padding()
                            
                            Text(stamp.name)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            if stamp.secondaryIdentifier != .unknown {
                                Text("Region \(stamp.secondaryIdentifier.detail.region)")
                            }
                            
                            Text(stampReference.dateCollected.formatted())
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.passport)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                    .padding()
                    .shadow(radius: 5)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0).combined(with: .opacity),
                        removal: .scale(scale: 0).combined(with: .opacity)
                    ))
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(.passport)
        .onAppear {
            if stampsAppViewModel.collectedStamps.count <= 12 {
                isGridZoomed = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isGridZoomed.toggle()
                } label: {
                    Image(systemName: isGridZoomed ? "minus.magnifyingglass" : "plus.magnifyingglass")
                }
            }
        }
    }
}


#Preview {
    StampsGridView()
        .environment(StampsAppViewModel())
}
