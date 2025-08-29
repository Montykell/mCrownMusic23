//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @Binding var isSignedIn: Bool
    @State private var isLoading: Bool = false
    @FocusState private var isPasswordFieldFocused: Bool
    @Environment(\.presentationMode) var presentationMode

    // Animation state
    @State private var imageOffset: CGFloat = -50
    @State private var imageOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // MARK: Top Image with animation
                    ZStack {
                        Image("SeeThru")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300) // slightly bigger
                            .clipped()
                            .offset(y: imageOffset)
                            .opacity(imageOpacity)
                            .onAppear {
                                withAnimation(.easeOut(duration: 1.0)) {
                                    imageOffset = 0
                                    imageOpacity = 1
                                }
                            }

                        // Back Button overlayed on top-left
                        VStack {
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
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

                    // MARK: Form
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
                            CustomTextField("Name", text: $viewModel.name, height: 40)
                            CustomTextField("Username", text: $viewModel.username, height: 40)
                            CustomTextField("Email", text: $viewModel.email, keyboardType: .emailAddress, height: 40)

                            SecureInputField(placeholder: "Password", text: $viewModel.password, height: 40)
                                .focused($isPasswordFieldFocused)

                            // Password rules below password field
                            if isPasswordFieldFocused {
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

                            SecureInputField(placeholder: "Confirm Password", text: $viewModel.confirmPassword, height: 40)
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

                        Button(action: {
                            isLoading = true
                            viewModel.signUp { success in
                                isLoading = false
                                if success {
                                    isSignedIn = true
                                }
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .font(.headline)
                                    .frame(maxWidth: 340)
                                    .frame(height: 45)
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
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Helpers to dismiss keyboard
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
