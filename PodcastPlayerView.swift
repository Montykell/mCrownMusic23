//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI

struct PodcastPlayerView: View {
    @ObservedObject var viewModel: PodcastPlayerViewModel
    
    // State for header controls
    @State private var searchText: String = ""
    @State private var navigateToProfile: Bool = false
    @State private var navigateToSettings: Bool = false
    @Binding var showLogoutConfirmation: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Shared header view at the top
            AppHeaderView(
                searchText: $searchText,
                showLogoutConfirmation: $showLogoutConfirmation,
                navigateToProfile: $navigateToProfile,
                navigateToSettings: $navigateToSettings
            )
            
            // Main content below header
            VStack {
                if let episode = viewModel.currentEpisode {
                    Text(episode.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text(episode.description)
                        .font(.body)
                        .padding()
                }
                
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.yellow)
                }
                .padding(.bottom, 20)
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.setupPlayer()
        }
        .alert(isPresented: $showLogoutConfirmation) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Logout")) {
                    // Your logout logic here or delegate out
                },
                secondaryButton: .cancel()
            )
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(viewModel: ProfileViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView(showLogoutConfirmation: $showLogoutConfirmation)
        }
    }
}

