//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct MainTabView: View {
    @Binding var showLogoutConfirmation: Bool

    var body: some View {
        TabView {
            HomeView(showLogoutConfirmation: $showLogoutConfirmation, viewModel: HomeViewModel())
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ProfileView(viewModel: ProfileViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }

            MusicPlayerView(viewModel: MusicPlayerViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
                .tabItem {
                    Label("Music", systemImage: "music.quarternote.3")
                }

            PodcastPlayerView(viewModel: PodcastPlayerViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
                .tabItem {
                    Label("Podcast", systemImage: "mic.circle")
                }


            SettingsView(showLogoutConfirmation: $showLogoutConfirmation)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.brown)
    }
}
