//
//  PassportView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct PassportView: View {
    static let tag = AppConstants.passport.tab
    @State private var isShowingRewardDetails = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                RewardProgressView()
                StampsGridView()
            }
            .sheet(isPresented: $isShowingRewardDetails) {
                RewardDetailPagesView()
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
}
