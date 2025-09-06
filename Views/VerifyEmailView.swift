//
//  VerifyEmailView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/30/25.
//

import SwiftUI
import FirebaseAuth

struct VerifyEmailView: View {
    @Binding var isSignedIn: Bool
    @State private var isLoading: Bool = false
    @State private var message: String? = nil
    @State private var messageColor: Color = .red
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Email")
                .font(.largeTitle.bold())
                .foregroundColor(.brown)
            
            Text("We sent a verification email to your account. Please check your inbox and click the link to verify your email before proceeding.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
            
            if let message {
                Text(message)
                    .foregroundColor(messageColor)
                    .font(.footnote)
            }

            // MARK: Buttons
            VStack(spacing: 12) {
                Button(action: checkVerification) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.brown)
                            .cornerRadius(10)
                    } else {
                        Text("I Verified My Email")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.brown)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)
                
                Button(action: resendEmail) {
                    Text("Resend Verification Email")
                        .font(.subheadline)
                        .foregroundColor(.brown)
                }
                .disabled(isLoading)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: - Functions

    private func checkVerification() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        user.reload { error in
            isLoading = false
            if let error {
                message = "Error: \(error.localizedDescription)"
                messageColor = .red
                return
            }
            
            if user.isEmailVerified {
                // ✅ Email verified
                message = "Email verified! Welcome!"
                messageColor = .green
                // Give user a brief moment to see the message, then proceed
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isSignedIn = true
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                message = "Email not verified yet. Please check your inbox."
                messageColor = .red
            }
        }
    }
    
    private func resendEmail() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        user.sendEmailVerification { error in
            isLoading = false
            if let error {
                message = "Failed to resend email: \(error.localizedDescription)"
                messageColor = .red
            } else {
                message = "Verification email resent!"
                messageColor = .green
            }
        }
    }
}
