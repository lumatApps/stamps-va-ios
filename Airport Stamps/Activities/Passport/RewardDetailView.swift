//
//  RewardDetailView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/9/24.
//

import SwiftUI

struct RewardDetailPagesView: View {
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    
    var body: some View {
        TabView {
            ForEach(stampsAppViewModel.rewardLevels, id: \.name) { level in
                RewardDetailView(rewardLevel: level)
                    .tabItem {
                        Label(level.name, systemImage: "trophy.fill")
                    }
                    .tag(level)
            }
        }
        .background(.thinMaterial)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

// Detailed view for a single reward level.
struct RewardDetailView: View {
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    var rewardLevel: Reward
    
    var airports: Bool {
        stampsAppViewModel.collectedStampTypeCount.airport >= rewardLevel.airports
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            prizeView
            levelHeader
            rewardCriteria
            additionalNotes
        }
        .padding()
    }
    
    @ViewBuilder
    private var levelHeader: some View {
        HStack {
            Image(systemName: "trophy.fill")
                .foregroundStyle(rewardLevel.ambassadorLevel.color)
            
            Text("\(rewardLevel.name)")
        }
        .font(.title)
    }
    
    @ViewBuilder
    private var rewardCriteria: some View {
        VStack(alignment: .leading, spacing: 8) {
            criteriaView(
                airports ? "checkmark.seal.fill" : "xmark.seal.fill",
                color: airports ? .green : .secondary,
                text: rewardLevel.airportsDescription)
            
            criteriaView(
                stampsAppViewModel.ambassadorLevel.museums ?  "checkmark.seal.fill" : "xmark.seal.fill", 
                color: stampsAppViewModel.ambassadorLevel.museums ? .green : .secondary,
                text: "Visit \(rewardLevel.museums) aviation museums in Virginia.")
            
            criteriaView(
                stampsAppViewModel.ambassadorLevel.seminars ?  "checkmark.seal.fill" : "xmark.seal.fill",
                color: stampsAppViewModel.ambassadorLevel.seminars ? .green : .secondary,
                text: "Attend \(rewardLevel.seminars) safety seminar in Virginia.")
            
            criteriaView(
                stampsAppViewModel.ambassadorLevel.flyIns ?  "checkmark.seal.fill" : "xmark.seal.fill",
                color: stampsAppViewModel.ambassadorLevel.flyIns ? .green : .secondary,
                text: "Attend \(rewardLevel.flyIns) designated fly-in.")
            
            criteriaView(
                stampsAppViewModel.ambassadorLevel.regions ?  "checkmark.seal.fill" : "xmark.seal.fill",
                color: stampsAppViewModel.ambassadorLevel.regions ? .green : .secondary,
                text: "At least one airport from each of the 7 regions.")
        }
    }
    
    @ViewBuilder
    private var additionalNotes: some View {
        Text("May substitute an additional museum visit in place of a designated fly-in.")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
    
    private func criteriaView(_ imageName: String, color: Color, text: String) -> some View {
        
        HStack {
            Image(systemName: imageName)
                .foregroundStyle(color)
            
            Text(text)
        }
    }
    
    @ViewBuilder
    private var prizeView: some View {
        VStack {
            AsyncImage(url: URL(string: "https://storage.googleapis.com/stamps-va/rewards/\(rewardLevel.name).jpg")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else if phase.error != nil {
                    Image(systemName: "gift.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 125, height: 125)
                        .foregroundStyle(rewardLevel.ambassadorLevel.color)
                } else {
                    ProgressView()
                }
            }
            
            Text(rewardLevel.prize)
                .font(.caption)
                .frame(width: 150)
                .multilineTextAlignment(.leading)

        }
        .frame(maxWidth: .infinity)
    }
}


// Extension to add a description property to 'Reward' for the special case of airports.
extension Reward {
    var airportsDescription: String {
        name == "Gold" ? "Visit all of Virginia's Public-Use Airports." : "Visit \(airports) of Virginia's Public-Use Airports."
    }
}
