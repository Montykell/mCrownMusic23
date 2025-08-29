//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit
import LocalAuthentication
import SwiftKeychainWrapper
import UIKit

@MainActor
class AuthenticationViewModel: NSObject, ObservableObject {
    // MARK: - Published properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    @Published var shouldResetNavigation: Bool = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var shouldSaveLoginInfo: Bool = false

    // Internal
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    override init() {
        super.init()
        setupAuthStateListener()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Listener
    func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isLoggedIn = (user != nil)
                self?.shouldResetNavigation = (user == nil)
            }
        }
    }

    // MARK: - Email/Password Login
    func login(completion: @escaping (Bool) -> Void) {
        guard isValidEmail(email) else {
            Task { @MainActor in
                self.errorMessage = "Invalid email format."
            }
            completion(false)
            return
        }

        guard isValidPassword(password) else {
            Task { @MainActor in
                self.errorMessage = "Password must meet the requirements."
            }
            completion(false)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            Task { @MainActor in
                guard let self = self else { completion(false); return }

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }

                guard let user = authResult?.user else {
                    self.errorMessage = "Unexpected login error."
                    completion(false)
                    return
                }

                user.reload { reloadError in
                    Task { @MainActor in
                        if let reloadError = reloadError {
                            self.errorMessage = "Failed to verify user: \(reloadError.localizedDescription)"
                            completion(false)
                            return
                        }

                        if user.isEmailVerified {
                            self.errorMessage = nil
                            self.currentUser = user
                            self.isLoggedIn = true
                            if self.shouldSaveLoginInfo {
                                self.saveCredentialsToKeychain(email: self.email, password: self.password)
                            }
                            completion(true)
                        } else {
                            self.errorMessage = "Email not verified."
                            completion(false)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Logout
    func logout(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            Task { @MainActor in
                self.isLoggedIn = false
                self.shouldResetNavigation = true
                self.currentUser = nil
                completion(true)
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = "Error signing out: \(error.localizedDescription)"
                completion(false)
            }
        }
    }

    // MARK: - Apple Sign-In
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Biometrics
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var authError: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            let reason = "Authenticate with Face ID / Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluationError in
                Task { @MainActor in
                    if success {
                        self.loginWithKeychainCredentials { success in
                            completion(success)
                        }
                    } else {
                        self.errorMessage = evaluationError?.localizedDescription ?? "Authentication failed"
                        completion(false)
                    }
                }
            }
        } else {
            Task { @MainActor in
                self.errorMessage = authError?.localizedDescription ?? "Biometrics not available"
                completion(false)
            }
        }
    }

    private func loginWithKeychainCredentials(completion: @escaping (Bool) -> Void) {
        if let (storedEmail, storedPassword) = fetchCredentialsFromKeychain() {
            Task { @MainActor in
                self.email = storedEmail
                self.password = storedPassword
                self.login { success in
                    completion(success)
                }
            }
        } else {
            Task { @MainActor in
                self.errorMessage = "No credentials found in Keychain."
                completion(false)
            }
        }
    }

    // MARK: - Keychain
    func saveCredentialsToKeychain(email: String, password: String) {
        KeychainWrapper.standard.set(email, forKey: "userEmail")
        KeychainWrapper.standard.set(password, forKey: "userPassword")
    }

    func fetchCredentialsFromKeychain() -> (String, String)? {
        guard let email = KeychainWrapper.standard.string(forKey: "userEmail"),
              let password = KeychainWrapper.standard.string(forKey: "userPassword") else {
            return nil
        }
        return (email, password)
    }

    // MARK: - Validation Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let patterns = [
            ".*[A-Z]+.*", // uppercase
            ".*[a-z]+.*", // lowercase
            ".*[0-9]+.*", // number
            ".*[!@#$%^&*(),.?\":{}|<>]+.*" // symbol
        ]
        return patterns.allSatisfy { NSPredicate(format: "SELF MATCHES %@", $0).evaluate(with: password) }
    }

    // MARK: - Nonce Utilities for Apple Sign-In
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce.")
            }

            if random < charset.count {
                result.append(charset[Int(random % UInt8(charset.count))])
                remainingLength -= 1
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Apple Sign-In Delegate
extension AuthenticationViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow
            }
            if let firstWindow = windowScene.windows.first {
                return firstWindow
            }
        }
        return ASPresentationAnchor()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            Task { @MainActor in
                self.errorMessage = "Invalid AppleID credential."
            }
            return
        }
        
        guard let nonce = currentNonce else {
            fatalError("Invalid state: missing nonce.")
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            Task { @MainActor in
                self.errorMessage = "Unable to fetch identity token from Apple."
            }
            return
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.currentUser = authResult?.user
                    self?.isLoggedIn = true
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
        }
    }
}
