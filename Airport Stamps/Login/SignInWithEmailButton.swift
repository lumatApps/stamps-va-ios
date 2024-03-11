//
//  SignInWithEmailButton.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/10/24.
//

import SwiftUI

struct SignInWithEmailButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(Color.accentColor)
                
                Text("Sign in with email")
                    .foregroundStyle(.black)
                    .font(.headline)
            }
            .frame(width: 280, height: 45, alignment: .center)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(radius: 3)
        }
    }
}

#Preview {
    SignInWithEmailButton {
        
    }
}
