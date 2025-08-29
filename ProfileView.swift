//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showLogoutConfirmation: Bool
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    // Header state
    @State private var searchText: String = ""
    @State private var navigateToProfile: Bool = false
    @State private var navigateToSettings: Bool = false
    
    // Editing state
    @State private var isEditing: Bool = false
    @State private var editingName: String = ""
    @State private var editingUsername: String = ""
    @State private var editingEmail: String = ""
    @State private var editingPhoneNumber: String = ""
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
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
                                                    if success {
                                                        viewModel.fetchUserPosts()
                                                    }
                                                }
                                            }
                                        )
                                        .environmentObject(authViewModel)
                                    }
                                }
                            }
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
            
            // MARK: - Banner Ad at Bottom
            AdBannerView(adUnitID: "ca-app-pub-3827921422149204/6770605361")
                .frame(width: 320, height: 50)
                .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showLogoutConfirmation) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Logout")) {},
                secondaryButton: .cancel()
            )
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(viewModel: ProfileViewModel(), showLogoutConfirmation: $showLogoutConfirmation)
                .environmentObject(authViewModel)
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView(showLogoutConfirmation: $showLogoutConfirmation)
        }
        .onAppear {
            viewModel.fetchUserPosts()
        }
    }

    
    // MARK: - Profile Image Section
    private func profileImageSection(user: UserProfile) -> some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            } else if let photoURL = user.profileImageURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 120, height: 120)
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    case .failure(_):
                        Circle().fill(Color.gray).frame(width: 120, height: 120)
                    @unknown default:
                        Circle().fill(Color.gray).frame(width: 120, height: 120)
                    }
                }
            } else {
                Circle().fill(Color.gray).frame(width: 120, height: 120)
            }
            
            if isEditing {
                Button("Change Profile Picture") {
                    showImagePicker.toggle()
                }
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
            
            Button("Save Profile") {
                saveProfileChanges()
            }
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
        }
    }
    
    // MARK: - Save Changes
    private func saveProfileChanges() {
        var changes: [String: Any] = [
            "name": editingName,
            "username": editingUsername,
            "email": editingEmail,
            "phoneNumber": editingPhoneNumber
        ]
        
        if let selectedImage = selectedImage {
            viewModel.uploadProfileImage(selectedImage) { success in
                if success {
                    if let url = viewModel.user?.profileImageURL {
                        changes["profileImageURL"] = url
                    }
                    viewModel.updateProfile(changes: changes)
                }
                self.selectedImage = nil
                isEditing = false
            }
        } else {
            viewModel.updateProfile(changes: changes)
            isEditing = false
        }
    }
}
