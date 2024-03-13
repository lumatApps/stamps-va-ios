//
//  RewardProgressView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/9/24.
//

import SwiftUI

struct RewardProgressView: View {
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    @State private var isShowingRewardDetails = false
    
    var status: Bool {
        stampsAppViewModel.ambassadorLevel.status >= stampsAppViewModel.selectedRewardLevel.ambassadorLevel
    }
    
    var body: some View {
        @Bindable var stampsAppViewModel = stampsAppViewModel
        
        VStack {
            HStack {
                Text("Ambassador Level:")
                
                HStack(spacing: 0) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(stampsAppViewModel.selectedRewardLevel.ambassadorLevel.color)
                        .overlay(alignment: .leading) {
                            Image(systemName: status ? "checkmark.seal.fill" : "xmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(status ? .green : .red)
                                .offset(x: -10, y: -10)
                        }
                    
                    Picker(selection: $stampsAppViewModel.selectedRewardLevel, label:
                            Text(stampsAppViewModel.selectedRewardLevel.name)
                    ) {
                        ForEach(stampsAppViewModel.rewardLevels, id: \.self) { rewardLevel in
                            Text(rewardLevel.name)
                                .foregroundStyle(Color.primary)
                                .tag(rewardLevel)
                        }
                    }
                }
                .padding(.leading)
            }
            .font(.headline)
            
            HStack {
                Spacer()
                
                RewardProgressItemView(
                    image: "✈️",
                    stampType: StampType.airport,
                    count: stampsAppViewModel.collectedStampTypeCount.airport,
                    reward: stampsAppViewModel.selectedRewardLevel.airports
                )
                
                Spacer()
                
                RewardProgressItemView(
                    image: "🏛️",
                    stampType: StampType.museum,
                    count: stampsAppViewModel.collectedStampTypeCount.museum,
                    reward: stampsAppViewModel.selectedRewardLevel.museums
                )
                
                Spacer()
                
                RewardProgressItemView(
                    image: "🦺",
                    stampType: StampType.seminar,
                    count: stampsAppViewModel.collectedStampTypeCount.seminar,
                    reward: stampsAppViewModel.selectedRewardLevel.seminars
                )
                
                Spacer()
                
                RewardProgressItemView(
                    image: "🛫",
                    stampType: StampType.flyIn,
                    count: stampsAppViewModel.collectedStampTypeCount.flyIn,
                    reward: stampsAppViewModel.selectedRewardLevel.flyIns,
                    extraMuseumCount: stampsAppViewModel.collectedStampTypeCount.museum - stampsAppViewModel.selectedRewardLevel.museums
                )
                
                Spacer()
            }
        }
        .padding(.bottom)
        .background(Material.ultraThickMaterial)
        .sheet(isPresented: $isShowingRewardDetails) {
            RewardDetailPagesView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isShowingRewardDetails.toggle()
                } label: {
                    Image(systemName: "trophy.fill")
                }
            }
        }
    }
}


struct RewardProgressItemView: View {
    var image: String
    var stampType: StampType
    var count: Int
    var reward: Int
    var extraMuseumCount: Int = 0
    
    var goalMet: Bool {
        if stampType == .flyIn {
            return count >= reward || extraMuseumCount >= 1
        } else {            
            return count >= reward
        }
    }
    
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
            
            VStack  {
                Text(stampType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.accent)
                
                Text("\(count) / \(reward)")
            }
            .overlay(alignment: .leading) {
                Image(systemName: goalMet ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .foregroundStyle(goalMet ? .green : .red)
                    .offset(x: -22)
            }
        }
    }
}
