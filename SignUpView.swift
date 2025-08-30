//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import PhotosUI

struct SignUpView: View {
    @StateObject var viewModel: SignUpViewModel = SignUpViewModel()
    @Binding var isSignedIn: Bool
    @State private var isLoading: Bool = false
    @State private var showVerifyEmailView: Bool = false
    @FocusState private var focusedField: Field?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var imageOffset: CGFloat = -50
    @State private var imageOpacity: Double = 0
    @State private var showImagePicker: Bool = false
    @State private var selectedPhoto: PhotosPickerItem?
    
    enum Field { case name, username, email, password, confirmPassword }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    topImageSection
                    formSection
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .onTapGesture { hideKeyboard() }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhoto)
        .onChange(of: selectedPhoto) { newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        viewModel.profileImage = uiImage
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showVerifyEmailView) {
            VerifyEmailView(isSignedIn: $isSignedIn)
        }
    }
    
    // MARK: - Sections
    var topImageSection: some View {
        ZStack {
            Image("SeeThru")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .offset(y: imageOffset)
                .opacity(imageOpacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        imageOffset = 0
                        imageOpacity = 1
                    }
                }
            
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.brown)
                        .font(.headline)
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, 50)
                Spacer()
            }
        }
    }
    
    var formSection: some View {
        VStack(spacing: 12) {
            Text("Create Account")
                .font(.system(size: 26, weight: .thin))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.brown)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            VStack(spacing: 10) {
                CustomTextField("Full Name", text: $viewModel.name, height: 40)
                    .focused($focusedField, equals: .name)
                if !SignUpViewModel.isValidFullName(viewModel.name) && !viewModel.name.isEmpty {
                    Text("Please enter your first and last name")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 4)
                }
                
                CustomTextField("Username", text: $viewModel.username, height: 40)
                    .focused($focusedField, equals: .username)
                if !SignUpViewModel.isValidUsername(viewModel.username) && !viewModel.username.isEmpty {
                    Text("Username must be 3-20 chars, no spaces or unsafe symbols")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 4)
                }
                
                CustomTextField("Email", text: $viewModel.email, keyboardType: .emailAddress, height: 40)
                    .focused($focusedField, equals: .email)
                if !SignUpViewModel.isValidEmail(viewModel.email) && !viewModel.email.isEmpty {
                    Text("Please enter a valid email address")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 4)
                }
                
                SecureInputField(placeholder: "Password", text: $viewModel.password, height: 40)
                    .focused($focusedField, equals: .password)
                if focusedField == .password {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Password must be at least 8 characters, including:")
                            .font(.caption.bold())
                        Text("• 1 uppercase letter")
                        Text("• 1 lowercase letter")
                        Text("• 1 number")
                        Text("• 1 special character")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 4)
                }
                if !SignUpViewModel.isValidPassword(viewModel.password) && !viewModel.password.isEmpty {
                    Text("Password does not meet requirements")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 4)
                }
                
                SecureInputField(placeholder: "Confirm Password", text: $viewModel.confirmPassword, height: 40)
                    .focused($focusedField, equals: .confirmPassword)
                if viewModel.confirmPassword != viewModel.password && !viewModel.confirmPassword.isEmpty {
                    Text("Passwords do not match")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 4)
                }
                
                // ✅ Profile image picker moved here
                profileImageSection
            }
            .padding()
            .frame(maxWidth: 340)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .shadow(radius: 8)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Button {
                hideKeyboard()
                isLoading = true
                viewModel.signUp { success in
                    isLoading = false
                    if success {
                        showVerifyEmailView = true // ✅ Show VerifyEmailView after signup
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 200, height: 45)
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(10)
                } else {
                    Text("Sign Up")
                        .font(.headline)
                        .frame(width: 200, height: 45)
                        .background(viewModel.isValid ? Color.brown : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .disabled(!viewModel.isValid || isLoading)
            
            Spacer(minLength: 40)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Profile Image Section
    var profileImageSection: some View {
        VStack {
            if let uiImage = viewModel.profileImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.brown, lineWidth: 2))
                    .shadow(radius: 5)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Button { showImagePicker = true } label: {
                Text("Choose Profile Image")
                    .font(.footnote)
                    .foregroundColor(.brown)
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Helpers
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Custom Text Fields
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var height: CGFloat = 40

    init(_ placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, height: CGFloat = 40) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.height = height
    }

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.horizontal)
            .frame(height: height)
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .keyboardType(keyboardType)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}

struct SecureInputField: View {
    let placeholder: String
    @Binding var text: String
    var height: CGFloat = 40

    var body: some View {
        SecureField(placeholder, text: $text)
            .padding(.horizontal)
            .frame(height: height)
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}
