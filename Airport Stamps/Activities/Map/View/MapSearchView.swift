//
//  MapSearchView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct MapSearchView: View {
    @Environment(\.dismissSearch) var dismissSearch
    @Binding var dismiss: Bool

    var body: some View {
        EmptyView()
            .onChange(of: dismiss) {
                dismissSearch()
            }
    }
}
