//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import AVKit

struct MusicPlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var showLogoutConfirmation: Bool
    
    @State private var searchText: String = ""
    @State private var navigateToProfile: Bool = false
    @State private var navigateToSettings: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            AppHeaderView(
                searchText: $searchText,
                showLogoutConfirmation: $showLogoutConfirmation,
                navigateToProfile: $navigateToProfile,
                navigateToSettings: $navigateToSettings
            )

            // MARK: Album Cover & Controls
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    if let track = viewModel.currentTrack {
                        MusicDetailView(
                            viewModel: MusicDetailViewModel(musicItem: track),
                            playerViewModel: viewModel
                        )
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange.opacity(0.85), Color.yellow.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .brown.opacity(0.3), radius: 15, x: 0, y: 5)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.brown.opacity(0.6))
                            Text("No track selected")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.brown)
                        }
                        .padding(.top, 40)
                    }

                    // Player Controls
                    PlayerControlsView(viewModel: viewModel)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .brown.opacity(0.25), radius: 10, x: 0, y: 5)
                }
                .padding([.horizontal, .top])
            }
            .background(Color(UIColor.systemGroupedBackground))

            // MARK: Music List
            MusicListView(viewModel: viewModel)
                .frame(maxHeight: .infinity)
                .background(Color(UIColor.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            viewModel.setupPlayer()
            viewModel.loadAllTracks()
        }
        .onDisappear {
            viewModel.stopPlayer()
        }

        // MARK: Logout Alert
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

        // MARK: Navigation Destinations
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(viewModel: ProfileViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView(showLogoutConfirmation: $showLogoutConfirmation)
        }
    }
}

// MARK: - Player Controls Subview
struct PlayerControlsView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel

    var body: some View {
        HStack(spacing: 30) {
            Button(action: { viewModel.playPreviousTrack() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 30))
            }
            
            Button(action: { viewModel.toggleRepeatMode() }) {
                Image(systemName: repeatModeIcon())
                    .font(.system(size: 30))
                    .foregroundColor(repeatButtonColor())
            }
            
            Button(action: { viewModel.togglePlayPause() }) {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 70))
            }
            
            Button(action: { viewModel.toggleShuffle() }) {
                Image(systemName: viewModel.isShuffling ? "shuffle.circle.fill" : "shuffle")
                    .font(.system(size: 30))
                    .foregroundColor(viewModel.isShuffling ? .brown : .brown)
            }
            
            Button(action: { viewModel.playNextTrack() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 30))
            }
        }
        .foregroundColor(.brown)
        .padding()
    }

    private func repeatModeIcon() -> String {
        switch viewModel.repeatMode {
        case .none: return "repeat"
        case .track: return "repeat.1"
        case .album: return "repeat"
        }
    }
    
    private func repeatButtonColor() -> Color {
        switch viewModel.repeatMode {
        case .none: return .brown          // repeat off
        case .track: return .orange        // repeat track
        case .album: return .yellow        // repeat all
        }
    }
}
