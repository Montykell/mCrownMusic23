//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

@MainActor
class SignUpViewModel: ObservableObject {
    // MARK: - Input
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var profileImage: UIImage?
    
    // MARK: - Output
    @Published var isValid: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    init() {
        Publishers.CombineLatest4($name, $username, $email, $password)
            .combineLatest($confirmPassword)
            .map { (input, confirmPassword) in
                let (name, username, email, password) = input
                
                let nameValid = Self.isValidFullName(name)
                let usernameValid = Self.isValidUsername(username)
                let emailValid = Self.isValidEmail(email)
                let passwordValid = Self.isValidPassword(password)
                let passwordsMatch = password == confirmPassword
                
                return nameValid && usernameValid && emailValid && passwordValid && passwordsMatch
            }
            .assign(to: &$isValid)
    }
    
    // MARK: - Sign Up
    func signUp(completion: @escaping (Bool) -> Void) {
        guard isValid else {
            errorMessage = "Please ensure all fields are filled out correctly."
            completion(false)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    self.errorMessage = "This email is already in use. Please use a different email."
                case .invalidEmail:
                    self.errorMessage = "The email address is invalid."
                case .weakPassword:
                    self.errorMessage = "The password is too weak."
                default:
                    self.errorMessage = error.localizedDescription
                }
                completion(false)
                return
            }

            guard let user = authResult?.user else {
                self.errorMessage = "Unexpected error: no user returned."
                completion(false)
                return
            }

            // Send verification email
            user.sendEmailVerification { error in
                if let error = error {
                    print("Failed to send verification email: \(error.localizedDescription)")
                } else {
                    print("Verification email sent to \(user.email ?? "")")
                }
            }

            // Upload profile image
            let defaultProfileImageURL = "https://example.com/default-profile.png"
            if let image = self.profileImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference().child("profileImages/\(user.uid)/profile.jpg")
                storageRef.putData(imageData, metadata: nil) { _, error in
                    let profileURL = (error == nil) ? "https://example.com/default-profile.png" : defaultProfileImageURL
                    self.saveUserDocuments(uid: user.uid, profileImageURL: profileURL) { _ in
                        // ✅ Return true after saving Firestore data
                        self.errorMessage = "A verification email has been sent to \(user.email ?? ""). Please verify before signing in."
                        completion(true)
                    }
                }
            } else {
                self.saveUserDocuments(uid: user.uid, profileImageURL: defaultProfileImageURL) { _ in
                    // ✅ Return true after saving Firestore data
                    self.errorMessage = "A verification email has been sent to \(user.email ?? ""). Please verify before signing in."
                    completion(true)
                }
            }
        }
    }

    
    // MARK: - Check Verification
    func checkEmailVerification(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        user.reload { error in
            if let error = error {
                print("Failed to reload user: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(user.isEmailVerified)
            }
        }
    }
    
    // MARK: - Firestore Saving
    private func saveUserDocuments(uid: String, profileImageURL: String, completion: @escaping (Bool) -> Void) {
        let userData: [String: Any] = [
            "name": name,
            "username": username,
            "email": email,
            "profileImageURL": profileImageURL
        ]
        let publicProfileData: [String: Any] = [
            "username": username,
            "profileImageURL": profileImageURL
        ]
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                completion(false)
                return
            }
            self.db.collection("publicProfiles").document(uid).setData(publicProfileData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save public profile: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - Validation
    static func isValidFullName(_ name: String) -> Bool {
        let parts = name.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        return parts.count >= 2 && parts.allSatisfy { !$0.isEmpty }
    }
    
    static func isValidUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let regex = "^[A-Za-z0-9._-]{3,20}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed)
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let uppercase = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
        let lowercase = NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*")
        let number = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
        let symbol = NSPredicate(format: "SELF MATCHES %@", ".*[!@#$%^&*(),.?\":{}|<>]+.*")
        return uppercase.evaluate(with: password)
            && lowercase.evaluate(with: password)
            && number.evaluate(with: password)
            && symbol.evaluate(with: password)
    }
}
