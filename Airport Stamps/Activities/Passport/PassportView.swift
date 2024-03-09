//
//  PassportView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct PassportView: View {
    static let tag = AppConstants.passport.tab
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(MapViewModel.self) var mapViewModel
    @State private var isShowingRewardDetails = false

    var collectedStamps: [Stamp] {
        mapViewModel.stamps.filter { stamp in
            profileViewModel.stamps.contains(where: { $0.id == stamp.id })
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                RewardProgressView(collectedStamps: collectedStamps)
                StampsGridView(collectedStamps: collectedStamps)
            }
            .sheet(isPresented: $isShowingRewardDetails) {
                RewardDetailView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingRewardDetails.toggle()
                    } label: {
                        Image(systemName: "trophy")
                    }
                }
            }
            .navigationTitle(AppConstants.passport.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PassportView()
        .environment(ProfileViewModel())
        .environment(MapViewModel())
}
