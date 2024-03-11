//
//  LoginView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//

import AuthenticationServices
import GoogleSignInSwift
import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(AuthManager.self) var authManager
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            LogoView()
            Spacer()
            
            // MARK: - Apple
            SignInWithAppleButton(
                onRequest: { request in
                    AppleSignInManager.shared.requestAppleAuthorization(request)
                },
                onCompletion: { result in
                    handleAppleID(result)
                }
            )
            .signInWithAppleButtonStyle(.white)
            .frame(width: 280, height: 45, alignment: .center)

            // MARK: - Google
            GoogleSignInButton {
                signInWithGoogle()
            }
            .frame(width: 280, height: 45, alignment: .center)

            // MARK: - Anonymous
            // Hide `Skip` button if user is anonymous.
            if authManager.authState == .signedOut {
                Button {
                    signAnonymously()
                } label: {
                    Text("Skip")
                        .foregroundStyle(Color.primary)
                        .bold()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accentColor.opacity(0.25))
    }

    /// Sign in with `Google`, and authenticate with `Firebase`.
    func signInWithGoogle() {
        GoogleSignInManager.shared.signInWithGoogle { user, error in
            if let error = error {
                print("GoogleSignInError: failed to sign in with Google, \(error))")
                // Here you can show error message to user.
                return
            }

            guard let user = user else { return }
            
            Task {
                do {
                    let result = try await authManager.googleAuth(user)
                    if let result = result {
                        print("GoogleSignInSuccess: \(result.user.uid)")
                        dismiss()
                    }
                }
                catch {
                    print("GoogleSignInError: failed to authenticate with Google, \(error))")
                    // Here you can show error message to user.
                }
            }
        }
    }

    func handleAppleID(_ result: Result<ASAuthorization, Error>) {
        if case let .success(auth) = result {
            guard let appleIDCredentials = auth.credential as? ASAuthorizationAppleIDCredential else {
                print("AppleAuthorization failed: AppleID credential not available")
                return
            }

            Task {
                do {
                    let result = try await authManager.appleAuth(
                        appleIDCredentials,
                        nonce: AppleSignInManager.nonce
                    )
                    if result != nil {
                        dismiss()
                    }
                } catch {
                    print("AppleAuthorization failed: \(error)")
                    // Here you can show error message to user.
                }
            }
        }
        else if case let .failure(error) = result {
            print("AppleAuthorization failed: \(error)")
            // Here you can show error message to user.
        }
    }

    /// Sign-in anonymously
    func signAnonymously() {
        Task {
            do {
                let result = try await authManager.signInAnonymously()
                print("SignInAnonymouslySuccess: \(result?.user.uid ?? "N/A")")
            }
            catch {
                print("SignInAnonymouslyError: \(error)")
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
