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
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct RewardDetailView: View {
    var rewardLevel: RewardLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "trophy.fill")
                
                Text("\(rewardLevel.name) Level")
            }
            .font(.headline)
            
            HStack {
                Image(systemName: "xmark")
                
                if rewardLevel.name == "Gold" {
                    Text("Visit all of Virginia's Public-Use Airports.")
                } else {
                    Text("Visit \(rewardLevel.airports) of Virginia's Public-Use Airports.")
                }
            }
            
            HStack {
                Image(systemName: "xmark")
                Text("Visit \(rewardLevel.museums) aviation museums in Virginia.")
            }
            
            HStack {
                Image(systemName: "xmark")
                Text("Attend \(rewardLevel.seminars) safety seminar in Virginia.")
            }
            
            HStack {
                Image(systemName: "xmark")
                Text("Attend a designated fly-in.")
            }
            
            Group {
                Text("At least one airport from each of the 7 regions.")
                Text("May substitute an additional museum visit in place of a designated fly-in.")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }
}


//#Preview {
//    RewardDetailView()
//        .environment(StampsAppViewModel())
//}
