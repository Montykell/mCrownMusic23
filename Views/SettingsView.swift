//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var showLogoutConfirmation: Bool
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            NavigationView {
                List {
                    Section(header: Text("General")) {
                        NavigationLink(destination: PrivacyStatementView()) {
                            Text("Privacy Statement")
                        }
                        NavigationLink(destination: TermsOfServiceView()) {
                            Text("Terms of Service")
                        }
                        NavigationLink(destination: GuidelinesView()) {
                            Text("Community Standards")
                        }
                    }
                    
                    Section(header: Text("Account")) {
                        NavigationLink(destination: DeleteAccountView()
                            .environmentObject(authViewModel)) {
                                Text("Delete Account")
                                    .foregroundColor(.red) // 🔴 red to emphasize danger
                            }
                    }
                }
                .navigationTitle("Settings")
                .listStyle(GroupedListStyle())
            }
            .navigationViewStyle(.stack) // 👈 consistent on iPad
            
            // Banner Ad at Bottom
            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(width: 320, height: 50)
                .padding(.bottom, 8)
        }
    }
}

