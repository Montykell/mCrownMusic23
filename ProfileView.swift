//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showLogoutConfirmation: Bool
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    // Header & Navigation
    @State private var searchText: String = ""
    @State private var navigateToProfile: Bool = false
    @State private var navigateToSettings: Bool = false

    // Editing & Image Picker
    @State private var isEditing: Bool = false
    @State private var editingName: String = ""
    @State private var editingUsername: String = ""
    @State private var editingEmail: String = ""
    @State private var editingPhoneNumber: String = ""
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?

    // Deactivation
    @State private var showDeactivateConfirmation: Bool = false
    @State private var isDeactivating: Bool = false

    // Alerts
    enum ActiveAlert: Identifiable {
        case logout
        case message(String)

        var id: String {
            switch self {
            case .logout: return "logout"
            case .message(let msg): return msg
            }
        }
    }
    @State private var activeAlert: ActiveAlert?

    var body: some View {
        VStack(spacing: 0) {
            AppHeaderView(
                searchText: $searchText,
                showLogoutConfirmation: $showLogoutConfirmation,
                navigateToProfile: $navigateToProfile,
                navigateToSettings: $navigateToSettings
            )

            ZStack {
                Image("SeeThru")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.1)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 16)

                        if let user = viewModel.user {
                            profileImageSection(user: user)
                            if isEditing {
                                editableFields
                            } else {
                                displayFields(user: user)
                            }

                            Divider().padding(.vertical)
                            userPostsSection
                        } else {
                            ProgressView("Loading profile...")
                        }
                    }
                    .padding(.bottom)
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedImage)
                }
            }

            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(width: 320, height: 50)
                .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .logout:
                return Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Logout")) {
                        Task { await authViewModel.logoutAsync() }
                    },
                    secondaryButton: .cancel()
                )
            case .message(let msg):
                return Alert(
                    title: Text("Account Status"),
                    message: Text(msg),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onChange(of: showLogoutConfirmation) { newValue in
            if newValue {
                activeAlert = .logout
                showLogoutConfirmation = false
            }
        }
        .onAppear {
            viewModel.fetchUserPosts()
        }
    }

    // MARK: - Profile Image Section
    private func profileImageSection(user: UserProfile) -> some View {
        VStack {
            Group {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                } else if let photoURL = user.profileImageURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                        case .failure(_):
                            Circle().fill(Color.gray)
                        @unknown default:
                            Circle().fill(Color.gray)
                        }
                    }
                } else {
                    Circle().fill(Color.gray)
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)

            if isEditing {
                Button("Change Profile Picture") { showImagePicker.toggle() }
                    .padding(.top)
            }
        }
    }

    // MARK: - Editable Fields
    private var editableFields: some View {
        VStack(spacing: 12) {
            TextField("Name", text: $editingName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Username", text: $editingUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Email", text: $editingEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
            TextField("Phone Number", text: $editingPhoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Save Profile") { saveProfileChanges() }
                .padding(.top)
        }
        .padding(.horizontal)
    }

    // MARK: - Display Fields
    private func displayFields(user: UserProfile) -> some View {
        VStack(spacing: 8) {
            Text("Name: \(user.name)")
            Text("Username: \(user.username)")
            Text("Email: \(user.email)")
            Text("Phone: \(user.phoneNumber)")

            Button("Edit Profile") {
                isEditing = true
                editingName = user.name
                editingUsername = user.username
                editingEmail = user.email
                editingPhoneNumber = user.phoneNumber
            }
            .padding(.top)

            Divider().padding(.vertical, 12)

            // 🔴 Deactivate Account
            Button(role: .destructive) {
                showDeactivateConfirmation = true
            } label: {
                if isDeactivating {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                } else {
                    Text("Deactivate Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .disabled(isDeactivating)
            .confirmationDialog(
                "Are you sure you want to deactivate your account?",
                isPresented: $showDeactivateConfirmation,
                titleVisibility: .visible
            ) {
                Button("Yes, deactivate", role: .destructive) { performDeactivation() }
                Button("Cancel", role: .cancel) {}
            }
        }
        .padding(.horizontal)
    }

    // MARK: - User Posts Section
    private var userPostsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Posts")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.userPosts.isEmpty {
                Text("You haven't posted anything yet.")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(viewModel.userPosts) { post in
                    NewsFeedItem(
                        update: post,
                        onLike: {},
                        onDislike: {},
                        onDelete: {
                            viewModel.deletePost(postId: post.id) { success in
                                if success { viewModel.fetchUserPosts() }
                            }
                        }
                    )
                    .environmentObject(authViewModel)
                }
            }
        }
    }

    // MARK: - Save Profile Changes
    private func saveProfileChanges() {
        var changes: [String: Any] = [
            "name": editingName,
            "username": editingUsername,
            "email": editingEmail,
            "phoneNumber": editingPhoneNumber
        ]

        if let selectedImage = selectedImage {
            viewModel.uploadProfileImage(selectedImage) { success in
                if success, let url = viewModel.user?.profileImageURL {
                    changes["profileImageURL"] = url
                }
                viewModel.updateProfile(changes: changes)
                self.selectedImage = nil
                isEditing = false
            }
        } else {
            viewModel.updateProfile(changes: changes)
            isEditing = false
        }
    }

    // MARK: - Deactivate Account
    private func performDeactivation() {
        guard !isDeactivating else { return }
        isDeactivating = true

        Task {
            let success = await authViewModel.deactivateAccountAsync()
            await MainActor.run {
                isDeactivating = false
                activeAlert = .message(
                    success ? "Your account has been deactivated." :
                              (authViewModel.errorMessage ?? "Failed to deactivate account.")
                )
            }
        }
    }
}
