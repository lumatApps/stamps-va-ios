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
    @State private var email = ""
    @State private var password = ""
    @State private var isCreatingNewAccount = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
//            TextField("Email", text: $email)
//                .textFieldStyle(.roundedBorder)
//                .padding(.horizontal)
//                .autocapitalization(.none)
//                .keyboardType(.emailAddress)
//                
//            SecureField("Password", text: $password)
//                .textFieldStyle(.roundedBorder)
//                .padding(.horizontal)
//            
//            Button("Sign In") {
//                Task {
//                    await signInOrCreateAccount()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            
//            Button("Create Account") {
//                Task {
//                    await signInOrCreateAccount()
//                }
//            }
//            
//            Spacer()

            // MARK: - Apple
            SignInWithAppleButton(
                onRequest: { request in
                    AppleSignInManager.shared.requestAppleAuthorization(request)
                },
                onCompletion: { result in
                    handleAppleID(result)
                }
            )
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
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
                        .font(.body.bold())
                        .frame(width: 280, height: 45, alignment: .center)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
//    func signInOrCreateAccount() async {
//        do {
//            let result = try await authManager.emailPasswordAuth(email: email, password: password, createUser: isCreatingNewAccount)
//            print("Authentication success: \(result?.user.email ?? "No Email")")
//            dismiss()
//        } catch {
//            print("Authentication error: \(error.localizedDescription)")
//            // Handle errors, e.g., show an alert to the user
//        }
//    }

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
