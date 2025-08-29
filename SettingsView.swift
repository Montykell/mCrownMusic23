//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var showLogoutConfirmation: Bool
    
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
                    }
                }
                .navigationTitle("Settings")
                .listStyle(GroupedListStyle())
            }
            .navigationViewStyle(.stack) // 👈 consistent on iPad
            
            // Banner Ad at Bottom
            AdBannerView(adUnitID: "ca-app-pub-3827921422149204/6770605361")
                .frame(width: 320, height: 50)
                .padding(.bottom, 8)
        }
    }
}
