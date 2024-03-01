//
//  StampsView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct StampsView: View {
    static let tag = Constants.stamps.tab
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 110, maximum: 110))]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(0..<12) { index in
                        Button {
                            // no action yet
                        } label: {
                            Image(systemName: "airplane")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 110, height: 110)
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                    }
                }
            }
            .navigationTitle(Constants.stamps.title)
        }
    }
}

#Preview {
    StampsView()
}
