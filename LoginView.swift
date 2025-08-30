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

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var loginViewModel: AuthenticationViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    
    @State private var shouldSaveLoginInfo: Bool = false
    @State private var isLoading: Bool = false
    @State private var showingBiometricAlert: Bool = false
    
    // Error states
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var shakeEmail: Bool = false
    @State private var shakePassword: Bool = false
    
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
                            
                            // Email Field + Error
                            VStack(alignment: .leading, spacing: 4) {
                                LoginCustomTextField(
                                    placeholder: "Email",
                                    text: $email,
                                    keyboardType: .emailAddress
                                )
                                .modifier(ShakeEffect(animatableData: CGFloat(shakeEmail ? 1 : 0)))
                                
                                if let emailError = emailError {
                                    Text(emailError)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 32)
                            
                            // Password Field + Error
                            VStack(alignment: .leading, spacing: 4) {
                                LoginSecureInputField(
                                    placeholder: "Password",
                                    text: $password
                                )
                                .modifier(ShakeEffect(animatableData: CGFloat(shakePassword ? 1 : 0)))
                                
                                if let passwordError = passwordError {
                                    Text(passwordError)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 32)
                            
                            // Save Login Info
                            Toggle(isOn: $shouldSaveLoginInfo) {
                                Text("Save Login Info")
                                    .foregroundColor(.brown)
                            }
                            .tint(.brown)
                            .padding(.horizontal, 32)
                            .onChange(of: shouldSaveLoginInfo) { newValue in
                                if newValue {
                                    loginViewModel.saveCredentialsToKeychain(email: email, password: password)
                                } else {
                                    KeychainWrapper.standard.removeObject(forKey: "userEmail")
                                    KeychainWrapper.standard.removeObject(forKey: "userPassword")
                                }
                            }
                            
                            Spacer(minLength: 30)
                            
                            // Buttons
                            VStack(spacing: 16) {
                                
                                // Email Login
                                Button(action: handleLogin) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .frame(width: 200, height: 45)

                                    } else {
                                        Text("Login")
                                            .font(.headline)
                                            .frame(width: 100, height: 45)
                                            .background(Color.brown)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 4)
                                    }
                                }
                                .buttonStyle(AnimatedButtonStyle())
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
                                        .frame(width: 200, height: 45)
                                        .background(Color.brown)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 4)
                                }
                                .buttonStyle(AnimatedButtonStyle())
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
                        .alert(isPresented: $showingBiometricAlert) {
                            Alert(
                                title: Text("Biometric Authentication Error"),
                                message: Text(loginViewModel.errorMessage ?? "Unknown error"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
                .navigationViewStyle(.stack)
                
                // MARK: - Adaptive Banner Ad
                AdBannerView(adUnitID: "ca-app-pub-3827921422149204/6770605361")
                    .frame(width: geo.size.width, height: 50)
                    .padding(.bottom, geo.safeAreaInsets.bottom)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    // MARK: - Handle Login Logic
    private func handleLogin() {
        guard !isLoading else { return }
        isLoading = true
        emailError = nil
        passwordError = nil
        shakeEmail = false
        shakePassword = false
        
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
                // Validation feedback
                if email.isEmpty || !(email.contains("@") && email.contains(".")) {
                    emailError = "Invalid email address"
                    withAnimation { shakeEmail.toggle() }
                }
                if password.isEmpty {
                    passwordError = "Password cannot be empty"
                    withAnimation { shakePassword.toggle() }
                } else if password.count < 6 {
                    passwordError = "Password must be at least 6 characters"
                    withAnimation { shakePassword.toggle() }
                } else {
                    passwordError = "Incorrect email or password"
                    withAnimation { shakePassword.toggle() }
                }
            }
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

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 10 * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Animated Button Style
struct AnimatedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
