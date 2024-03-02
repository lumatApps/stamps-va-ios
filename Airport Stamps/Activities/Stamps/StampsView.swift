//
//  StampsView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct StampsView: View {
    static let tag = AppConstants.stamps.tab
    
    @Environment(ProfileViewModel.self) var profileViewModel
    
    
    
    
    var columns: [GridItem] {
        [GridItem(.flexible(minimum: 100, maximum: 150)),
         GridItem(.flexible(minimum: 100, maximum: 150)),
         GridItem(.flexible(minimum: 100, maximum: 150))]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(profileViewModel.stamps) { index in
                        Button {
                            // no action yet
                        } label: {
                            Image(systemName: "airplane")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                    }
                }
            }
            .navigationTitle(AppConstants.stamps.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StampsView()
        .environment(ProfileViewModel())
}
