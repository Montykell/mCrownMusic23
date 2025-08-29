//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import FirebaseDatabase

struct HomeView: View {
    @State private var newStatusText: String = ""
    @State private var searchText: String = ""
    @Binding var showLogoutConfirmation: Bool
    @State private var isShowingLoginView: Bool = false
    @State private var navigateToProfile: Bool = false
    @State private var navigateToSettings: Bool = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeaderView(
                    searchText: $searchText,
                    showLogoutConfirmation: $showLogoutConfirmation,
                    navigateToProfile: $navigateToProfile,
                    navigateToSettings: $navigateToSettings
                )
                
                ZStack {
                    // Background
                    Image("SeeThru")
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.1)
                        .zIndex(0)
                    
                    VStack {
                        // Quick widget section
                        WidgetButtonsSection(showLogoutConfirmation: $showLogoutConfirmation)
                        
                        // MARK: - Feed
                        ScrollView {
                            LazyVStack {
                                ForEach(viewModel.updates.filter {
                                    searchText.isEmpty ? true : $0.description.localizedCaseInsensitiveContains(searchText)
                                }) { update in
                                    NewsFeedItem(
                                        update: update,
                                        onLike: { toggleLike(update: update) },
                                        onDislike: { toggleDislike(update: update) },
                                        onDelete: { delete(update: update) }
                                    )
                                    .environmentObject(authViewModel)
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        Spacer()
                        
                        // MARK: - Status input bar
                        StatusPostBar(newStatusText: $newStatusText, onPost: postStatus)
                    }
                }
            }
            .onAppear {
                viewModel.fetchAllUpdates()
            }
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Logout")) { logout() },
                    secondaryButton: .cancel()
                )
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.clear)
            .fullScreenCover(isPresented: $isShowingLoginView) {
                LoginView().environmentObject(authViewModel)
            }
            .onChange(of: authViewModel.shouldResetNavigation) { shouldReset in
                if shouldReset {
                    authViewModel.shouldResetNavigation = false
                    isShowingLoginView = true
                }
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                ProfileView(viewModel: ProfileViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView(showLogoutConfirmation: $showLogoutConfirmation)
            }
        }
    }
    
    // MARK: - Actions
    
    private func sanitizeInput(_ text: String) -> String {
        var sanitized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove HTML/JS tags
        sanitized = sanitized.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        // Limit length
        sanitized = String(sanitized.prefix(500))
        return sanitized
    }
    
    private func postStatus() {
        let cleanedText = sanitizeInput(newStatusText)
        guard !cleanedText.isEmpty else { return }
        
        viewModel.addUpdate(description: cleanedText) { success in
            if success {
                newStatusText = ""
            } else {
                print("Failed to add update")
            }
        }
    }
    
    private func toggleLike(update: Update) {
        guard let currentUserId = authViewModel.currentUser?.uid else { return }
        let ref = Database.database().reference()
            .child("updates")
            .child(update.id)
            .child("likes")
            .child(currentUserId)
        
        if update.didLike(currentUserId: currentUserId) {
            ref.removeValue()
        } else {
            ref.setValue(true)
            Database.database().reference()
                .child("updates")
                .child(update.id)
                .child("dislikes")
                .child(currentUserId)
                .removeValue()
        }
    }
    
    private func toggleDislike(update: Update) {
        guard let currentUserId = authViewModel.currentUser?.uid else { return }
        let ref = Database.database().reference()
            .child("updates")
            .child(update.id)
            .child("dislikes")
            .child(currentUserId)
        
        if update.didDislike(currentUserId: currentUserId) {
            ref.removeValue()
        } else {
            ref.setValue(true)
            Database.database().reference()
                .child("updates")
                .child(update.id)
                .child("likes")
                .child(currentUserId)
                .removeValue()
        }
    }
    
    private func delete(update: Update) {
        viewModel.deleteUpdate(updateId: update.id) { success in
            if success {
                viewModel.fetchAllUpdates()
            } else {
                print("Failed to delete update")
            }
        }
    }
    
    private func logout() {
        authViewModel.logout { success in
            if success { isShowingLoginView = true }
        }
    }
}
// MARK: - StatusPostBar
struct StatusPostBar: View {
    @Binding var newStatusText: String
    let onPost: () -> Void
    
    var body: some View {
        HStack {
            TextField("Talk to Me!", text: $newStatusText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
                .onChange(of: newStatusText) { newValue in
                    if newValue.count > 500 {
                        newStatusText = String(newValue.prefix(500))
                    }
                }
            
            Button(action: onPost) {
                Text("Post")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.brown)
                    .cornerRadius(10)
            }
            .disabled(newStatusText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .shadow(radius: 5)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - WidgetButtonsSection
struct WidgetButtonsSection: View {
    @Binding var showLogoutConfirmation: Bool

    @State private var showLivestream = false
    @State private var showVideoPlayer = false
    @State private var showMusicPlayer = false
    @State private var showPodcastPlayer = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                WidgetButton(title: "Music", color: .orange) {
                    showMusicPlayer.toggle()
                }
                .sheet(isPresented: $showMusicPlayer) {
                    MusicPlayerView(viewModel: MusicPlayerViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
                }

                WidgetButton(title: "Podcasts", color: .green) {
                    showPodcastPlayer.toggle()
                }
                .sheet(isPresented: $showPodcastPlayer) {
                    PodcastPlayerView(viewModel: PodcastPlayerViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
                }

                WidgetButton(title: "Livestream", color: .purple) {
                    showLivestream.toggle()
                }
                .sheet(isPresented: $showLivestream) {
                    LivestreamPlayerView(livestreamEvent: sampleLivestreamEvent)
                }

                WidgetButton(title: "Music Videos", color: .blue) {
                    showVideoPlayer.toggle()
                }
                .sheet(isPresented: $showVideoPlayer) {
                    MusicVideosComingSoonView()
                }
            }
            .padding()
        }
    }
}

