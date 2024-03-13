//
//  PassportView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct PassportView: View {
    static let tag = AppConstants.passport.tab

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                RewardProgressView()
                StampsGridView()
            }
            .navigationTitle(AppConstants.passport.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PassportView()
}
