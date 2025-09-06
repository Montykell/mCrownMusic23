//
//  ReactivateAccountView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 9/2/25.
//

import SwiftUI
import LocalAuthentication

struct ReactivateAccountView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isProcessing: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reactivate Account")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            Text("Enter your email and password to reactivate your account.")
                .font(.callout)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 32)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 32)
                .disableAutocorrection(true)
            
            // Reactivate Button
            Button(action: handleReactivate) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 200, height: 45)
                } else {
                    Text("Reactivate")
                        .font(.headline)
                        .frame(width: 200, height: 45)
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                }
            }
            .disabled(isProcessing)
            .padding(.top, 10)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authenticateDeviceBiometrics()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Success" {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Device Biometric Authentication
    private func authenticateDeviceBiometrics() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Verify your identity to reactivate your account."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if !success {
                        alertTitle = "Error"
                        alertMessage = "Authentication failed. Cannot proceed."
                        showAlert = true
                        isProcessing = true // Disable the reactivate button
                    }
                }
            }
        }
    }
    
    // MARK: - Handle Reactivate
    private func handleReactivate() {
        guard !isProcessing else { return }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@") else {
            alertTitle = "Error"
            alertMessage = "Please enter a valid email."
            showAlert = true
            return
        }
        
        guard !trimmedPassword.isEmpty else {
            alertTitle = "Error"
            alertMessage = "Please enter your password."
            showAlert = true
            return
        }
        
        isProcessing = true
        
        Task { @MainActor in
            let success = await authViewModel.reactivateAccountAsync(email: trimmedEmail, password: trimmedPassword)
            isProcessing = false
            
            if success {
                alertTitle = "Success"
                alertMessage = "Your account has been reactivated. You can now log in."
            } else {
                alertTitle = "Error"
                alertMessage = authViewModel.errorMessage ?? "Failed to reactivate account."
            }
            
            showAlert = true
        }
    }
}
