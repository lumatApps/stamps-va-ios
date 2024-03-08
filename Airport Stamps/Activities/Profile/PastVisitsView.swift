//
//  PastVisitsView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/8/24.
//

import SwiftUI

struct PastVisitsView: View {
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(MapViewModel.self) var mapViewModel
    
    var body: some View {
        List(profileViewModel.stamps) { stamp in
            if let stampDetail = mapViewModel.stamps.first(where: { $0.id == stamp.id }) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: stampDetail.icon)
                            .foregroundStyle(Color.accentColor)
                        
                        Text(stamp.id)
                            .bold()
                    }
                    
                    Text(stampDetail.name)
                    
                    Text(stamp.dateCollected.formatted())
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Past Visits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PastVisitsView()
        .environment(ProfileViewModel())
        .environment(MapViewModel())
}
