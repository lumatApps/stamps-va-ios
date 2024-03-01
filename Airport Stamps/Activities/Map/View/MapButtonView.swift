//
//  MapButtonView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import SwiftUI

struct MapButtonView: View {
    var systemName: String?
    var imageName: String?
    var color: Color = Color.accentColor
    var action: () -> Void
    
    var body: some View {
        Button(action: withAnimation { action }) {
            if let systemName = systemName {
                Image(systemName: systemName)
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(color)
                    .padding(5)
                    .frame(width: 42, height: 42)
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    MapButtonView(systemName: "airplane") {
        // Click
    }
}
