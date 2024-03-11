//
//  RewardProgressView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/9/24.
//

import SwiftUI

struct RewardProgressView: View {
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    
    var body: some View {
        HStack {
            Spacer()
            RewardProgressItemView(image: "✈️", stampType: StampType.airport, count: stampsAppViewModel.collectedStampTypeCount.airport)
            Spacer()
            RewardProgressItemView(image: "🏛️", stampType: StampType.museum, count: stampsAppViewModel.collectedStampTypeCount.museum)
            Spacer()
            RewardProgressItemView(image: "🦺", stampType: StampType.seminar, count: stampsAppViewModel.collectedStampTypeCount.seminar)
            Spacer()
            RewardProgressItemView(image: "🛫", stampType: StampType.flyIn, count: stampsAppViewModel.collectedStampTypeCount.flyIn)
            Spacer()
        }
        .padding()
        .background(Material.ultraThickMaterial)
    }
}

struct RewardProgressItemView: View {
    var image: String
    var stampType: StampType
    var count: Int
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "https://storage.googleapis.com/stamps-va/stamp-logos/\(stampType.key).png")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                } else if phase.error != nil {
                    Text(image)
                        .font(.title)
                } else {
                    ProgressView()
                }
            }
            
            Text(stampType.rawValue)
                .font(.caption)
            
            Text("\(count)")
                .font(.headline)
        }
    }
}


//#Preview {
//    ProgressView()
//}
