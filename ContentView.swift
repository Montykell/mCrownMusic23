//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var isShowingSignUp: Bool = false
    @State private var showLogoutConfirmation: Bool = false
    @State private var isLoggingOut: Bool = false

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView(showLogoutConfirmation: $showLogoutConfirmation)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        .sheet(isPresented: $isShowingSignUp) {
            SignUpView(
                viewModel: SignUpViewModel(),
                isSignedIn: $authViewModel.isLoggedIn
            )
        }
        .alert(isPresented: $showLogoutConfirmation) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Logout")) {
                    Task {
                        isLoggingOut = true
                        let success = await authViewModel.logoutAsync()
                        await MainActor.run {
                            isLoggingOut = false
                            if !success {
                                // Optionally show an alert for failure
                                print(authViewModel.errorMessage ?? "Logout failed")
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: authViewModel.shouldResetNavigation) { shouldReset in
            if shouldReset {
                authViewModel.shouldResetNavigation = false
            }
        }
    }
}
