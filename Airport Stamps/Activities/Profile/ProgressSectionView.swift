//
//  ProgressSectionView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/14/24.
//

import SwiftUI

struct ProgressSectionView: View {
    var ambassadorLevel: AmbassadorLevel

    var body: some View {
        Section("Progress") {
            NavigationLink("Past Visits") {
                PastVisitsView()
            }

            HStack {
                Text("Ambassador Level:")
                
                Spacer()
                
                Text(ambassadorLevel.title)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

