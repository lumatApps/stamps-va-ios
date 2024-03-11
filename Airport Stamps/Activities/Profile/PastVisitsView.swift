//
//  PastVisitsView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/8/24.
//

import SwiftUI

struct PastVisitsView: View {
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    
    var body: some View {
        List(stampsAppViewModel.collectedStampReferences) { stampReference in
            if let stampDetail = stampsAppViewModel.collectedStampsDictionary[stampReference.id] {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: stampDetail.icon)
                            .foregroundStyle(Color.accentColor)
                        
                        Text(stampReference.id)
                            .bold()
                    }
                    
                    Text(stampDetail.name)
                    
                    Text(stampReference.dateCollected.formatted())
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
        .environment(StampsAppViewModel())
}
