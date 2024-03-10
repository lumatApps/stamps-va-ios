//
//  LogoView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/9/24.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("va-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(lineWidth: 10)
                        .foregroundStyle(.accent)
                    )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 15, dash: [15]))
                        .foregroundStyle(.accent)
                )
            
            Text("AMBASSADORS PROGRAM")
                .foregroundStyle(Color.primary)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    LogoView()
}
