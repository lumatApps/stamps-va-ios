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
            Image(.doavLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
   
            
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
