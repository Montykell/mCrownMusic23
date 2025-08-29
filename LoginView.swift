//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import SwiftKeychainWrapper
import GoogleSignInSwift
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var loginViewModel: AuthenticationViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    
    @State private var shouldSaveLoginInfo: Bool = false
    @State private var isLoading: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var showingBiometricAlert: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                NavigationView {
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            // Top Image
                            Image("SeeThru")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .padding(.top, 40)
                            
                            // Email & Password Fields
                            VStack(spacing: 12) {
                                LoginCustomTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                                LoginSecureInputField(placeholder: "Password", text: $password)
                                
                                Toggle(isOn: $shouldSaveLoginInfo) {
                                    Text("Save Login Info")
                                        .foregroundColor(.brown)
                                }
                                .tint(.brown)
                                .onChange(of: shouldSaveLoginInfo) { newValue in
                                    if newValue {
                                        loginViewModel.saveCredentialsToKeychain(email: email, password: password)
                                    } else {
                                        KeychainWrapper.standard.removeObject(forKey: "userEmail")
                                        KeychainWrapper.standard.removeObject(forKey: "userPassword")
                                    }
                                }
                            }
                            .padding(.horizontal, 32)
                            
                            Spacer(minLength: 30)
                            
                            // Buttons
                            VStack(spacing: 16) {
                                
                                // Email Login
                                Button(action: {
                                    guard !isLoading else { return }
                                    isLoading = true
                                    loginViewModel.email = email
                                    loginViewModel.password = password
                                    
                                    loginViewModel.login { success in
                                        isLoading = false
                                        if success {
                                            if shouldSaveLoginInfo {
                                                loginViewModel.saveCredentialsToKeychain(email: email, password: password)
                                            }
                                            email = ""
                                            password = ""
                                        } else {
                                            showErrorAlert = true
                                        }
                                    }
                                }) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 45)
                                    } else {
                                        Text("Login")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 45)
                                            .background(Color.brown)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 4)
                                    }
                                }
                                .disabled(isLoading)
                                
                                // Face ID / Touch ID
                                Button(action: {
                                    guard !isLoading else { return }
                                    isLoading = true
                                    loginViewModel.authenticateWithBiometrics { success in
                                        isLoading = false
                                        if !success {
                                            showingBiometricAlert = true
                                        }
                                    }
                                }) {
                                    Text("Face ID / Touch ID Login")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 45)
                                        .background(Color.brown)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 4)
                                }
                                .disabled(isLoading)
                                
                                // Sign Up Navigation
                                NavigationLink(destination: SignUpView(viewModel: SignUpViewModel(), isSignedIn: $loginViewModel.isLoggedIn)) {
                                    Text("Don't have an account? Sign Up!")
                                        .foregroundColor(.brown)
                                        .font(.callout)
                                        .padding(.top, 10)
                                }
                                
                                Spacer(minLength: 40)
                            }
                            .padding(.bottom, 20)
                        }
                        .onAppear {
                            if let (savedEmail, savedPassword) = loginViewModel.fetchCredentialsFromKeychain() {
                                email = savedEmail
                                password = savedPassword
                                shouldSaveLoginInfo = true
                            }
                        }
                        .navigationBarBackButtonHidden(true)
                        .alert(isPresented: $showErrorAlert) {
                            Alert(title: Text("Error"), message: Text(loginViewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
                        }
                        .alert(isPresented: $showingBiometricAlert) {
                            Alert(title: Text("Biometric Authentication Error"), message: Text(loginViewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .navigationViewStyle(.stack) // consistent on iPad
                
                // MARK: - Adaptive Banner Ad
                AdBannerView(adUnitID: "ca-app-pub-3827921422149204/6770605361")
                    .frame(width: geo.size.width, height: 50)
                    .padding(.bottom, geo.safeAreaInsets.bottom)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    // MARK: - Custom Text Field
    struct LoginCustomTextField: View {
        let placeholder: String
        @Binding var text: String
        var keyboardType: UIKeyboardType = .default
        var height: CGFloat = 40
        
        var body: some View {
            TextField(placeholder, text: $text)
                .padding(.horizontal)
                .frame(height: height)
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
                .keyboardType(keyboardType)
                .foregroundColor(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Secure Input Field
    struct LoginSecureInputField: View {
        let placeholder: String
        @Binding var text: String
        var height: CGFloat = 40
        
        var body: some View {
            SecureField(placeholder, text: $text)
                .padding(.horizontal)
                .frame(height: height)
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
                .foregroundColor(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
