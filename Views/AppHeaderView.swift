//
//  AppHeaderView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/12/25.
//

import SwiftUI

struct AppHeaderView: View {
    // Generic: no @ObservedObject here
    var musicVM: MusicPlayerViewModel? = nil
    @Binding var searchText: String
    @Binding var showLogoutConfirmation: Bool
    @Binding var navigateToProfile: Bool
    @Binding var navigateToSettings: Bool

    // MusicPlayer initializer
    init(viewModel: MusicPlayerViewModel,
         showLogoutConfirmation: Binding<Bool>,
         navigateToProfile: Binding<Bool>,
         navigateToSettings: Binding<Bool>) {
        self.musicVM = viewModel
        self._searchText = Binding(
            get: { viewModel.searchText },
            set: { viewModel.searchText = $0 }
        )
        self._showLogoutConfirmation = showLogoutConfirmation
        self._navigateToProfile = navigateToProfile
        self._navigateToSettings = navigateToSettings
    }

    // Generic initializer
    init(searchText: Binding<String>,
         showLogoutConfirmation: Binding<Bool>,
         navigateToProfile: Binding<Bool>,
         navigateToSettings: Binding<Bool>) {
        self._searchText = searchText
        self._showLogoutConfirmation = showLogoutConfirmation
        self._navigateToProfile = navigateToProfile
        self._navigateToSettings = navigateToSettings
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "crown.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(-45))

                Spacer()

                Image("SeeThru")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100, maxHeight: 100)

                Spacer()

                Menu {
                    Button("Profile") { navigateToProfile = true }
                    Button("Settings") { navigateToSettings = true }
                    Button("Logout") { showLogoutConfirmation = true }
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                        .foregroundColor(.yellow)
                        .padding()
                }
            }
            .padding(.horizontal)

            // Search bar
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }
}
