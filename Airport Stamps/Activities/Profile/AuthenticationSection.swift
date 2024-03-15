//
//  AuthenticationSection.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/14/24.
//

import SwiftUI

struct AuthenticationSection: View {
    @Binding var showLoginSheet: Bool
    var authState: AuthState
    var signInOrOutAction: () -> Void

    var body: some View {
        Section {
            Button(authState != .signedIn ? "Sign in" : "Sign out") {
                signInOrOutAction()
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(authState != .signedIn ? Color.accentColor : .red)
        }
    }
}
