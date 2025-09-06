//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import Foundation
import FirebaseAuth
import LocalAuthentication
import SwiftKeychainWrapper
import SwiftUI
import FirebaseFirestore

@MainActor
class AuthenticationViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false
    @Published var shouldResetNavigation: Bool = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var shouldSaveLoginInfo: Bool = false
    
    // Internal
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Init / Deinit
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
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isLoggedIn = (user != nil)   // ✅ Correct check
                self?.shouldResetNavigation = (user == nil)
            }
        }
    }

    
    func loginAsync() async -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty."
            return false
        }
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty."
            return false
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = result.user

            // Check Firestore if account is deactivated
            let userDoc = Firestore.firestore().collection("users").document(user.uid)
            let snapshot = try await userDoc.getDocument()
            if let data = snapshot.data(), data["isDeactivated"] as? Bool == true {
                errorMessage = "Your account has been deactivated."
                try Auth.auth().signOut()
                return false
            }

            currentUser = user
            isLoggedIn = true
            shouldResetNavigation = false
            errorMessage = nil

            if shouldSaveLoginInfo {
                saveCredentialsToKeychain(email: email, password: password)
            }

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    
    // MARK: - Logout
    func logoutAsync() async -> Bool {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isLoggedIn = false
            shouldResetNavigation = true
            return true
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Deactivate Account (Soft)
    func deactivateAccountAsync() async -> Bool {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user signed in."
            return false
        }

        do {
            // 1️⃣ Update Firestore user document
            let userDoc = Firestore.firestore().collection("users").document(user.uid)
            try await userDoc.updateData(["isDeactivated": true])

            // 2️⃣ Log out
            try Auth.auth().signOut()
            currentUser = nil
            isLoggedIn = false
            shouldResetNavigation = true

            print("🔥 Account deactivated successfully")
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to deactivate account: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Delete Account (Optional)
    func deleteAccountAsync() async -> Bool {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user signed in."
            return false
        }

        do {
            try await user.delete()
            currentUser = nil
            isLoggedIn = false
            shouldResetNavigation = true
            print("✅ Account deleted successfully")
            return true
        } catch {
            errorMessage = "Failed to delete account: \(error.localizedDescription)"
            print("❌ \(errorMessage!)")
            return false
        }
    }
    
    // MARK: - Reactivate Account
    func reactivateAccountAsync(email: String, password: String) async -> Bool {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = authResult.user
            isLoggedIn = true
            shouldResetNavigation = false
            errorMessage = nil
            
            // Reactivate in Firestore
            let db = FirebaseFirestore.Firestore.firestore()
            try await db.collection("users").document(authResult.user.uid)
                .setData(["deactivated": false], merge: true)
            
            print("✅ Account reactivated client-side")
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Biometric Authentication
    func authenticateWithBiometrics() async -> Bool {
        await withCheckedContinuation { continuation in
            let context = LAContext()
            var authError: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                let reason = "Authenticate with Face ID / Touch ID"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                    Task { @MainActor in
                        if success {
                            if let (storedEmail, storedPassword) = self.fetchCredentialsFromKeychain() {
                                self.email = storedEmail
                                self.password = storedPassword
                                Task {
                                    let loginSuccess = await self.loginAsync()
                                    continuation.resume(returning: loginSuccess)
                                }
                            } else {
                                self.errorMessage = "No credentials found in Keychain."
                                continuation.resume(returning: false)
                            }
                        } else {
                            self.errorMessage = error?.localizedDescription ?? "Authentication failed"
                            continuation.resume(returning: false)
                        }
                    }
                }
            } else {
                self.errorMessage = authError?.localizedDescription ?? "Biometrics not available"
                continuation.resume(returning: false)
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
              let password = KeychainWrapper.standard.string(forKey: "userPassword") else { return nil }
        return (email, password)
    }
    
    // MARK: - Validation Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let patterns = ["[A-Z]+", "[a-z]+", "[0-9]+", "[!@#$%^&*(),.?\":{}|<>]+"]
        return patterns.allSatisfy {
            NSPredicate(format: "SELF MATCHES %@", $0).evaluate(with: password)
        }
    }
}
