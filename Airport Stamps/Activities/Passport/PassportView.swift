//
//  PassportView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct PassportView: View {
    static let tag = AppConstants.passport.tab
    @Environment(StampsAppViewModel.self) var stampsAppViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                RewardProgressView()
                StampsGridView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(stampsAppViewModel.firstName.isEmpty ? "My Passport" : "\(stampsAppViewModel.firstName)'s Passport")
                        .font(.custom("Bradley Hand", size: 24))
                        .bold()
                        .padding(5)
                }
            }
        }
    }
}

#Preview {
    PassportView()
}
