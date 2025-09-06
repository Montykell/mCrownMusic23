//
//  DeleteAccountView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 9/2/25.
//

import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isDeleting = false
    @State private var showConfirmation = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Delete Account")
                .font(.title)
                .bold()
                .padding(.top)
            
            Text("This action cannot be undone. All your data will be permanently deleted.")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if isDeleting {
                ProgressView("Deleting...")
                    .padding()
            }
            
            Spacer()
            
            Button(role: .destructive) {
                showConfirmation = true
            } label: {
                Text("Delete My Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(isDeleting)
            .confirmationDialog("Are you sure?", isPresented: $showConfirmation, titleVisibility: .visible) {
                Button("Yes, delete my account", role: .destructive) {
                    isDeleting = true
                    Task {
                        let success = await authViewModel.deleteAccountAsync()
                        await MainActor.run {
                            isDeleting = false
                            alertTitle = success ? "Account Deleted" : "Error"
                            alertMessage = success
                                ? "Your account and all data have been permanently deleted."
                                : (authViewModel.errorMessage ?? "Failed to delete account.")
                            showAlert = true
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }

            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.bottom)
        }
        .padding()
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if alertTitle == "Account Deleted" {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
}
