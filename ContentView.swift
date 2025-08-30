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
                    authViewModel.logout { _ in }
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
