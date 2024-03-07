//
//  MapSheetDetailView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/7/24.
//

import SwiftUI

struct MapSheetDetailView: View {
    var stamp: Stamp
    
    var body: some View {
        VStack {
            Text(stamp.name)
            Text("\(stamp.elevation)'")
        }
        .frame(height: 200)
    }
}
