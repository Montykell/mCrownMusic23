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
    @Published var profileImage: UIImage? // Optional user-selected image

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
                
                let emailValid = Self.isValidEmail(email)
                let passwordValid = Self.isValidPassword(password)
                let passwordsMatch = password == confirmPassword
                
                return !name.isEmpty
                    && !username.isEmpty
                    && emailValid
                    && passwordValid
                    && passwordsMatch
            }
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }

    // MARK: - Sign Up
    func signUp(completion: @escaping (Bool) -> Void) {
        guard isValid else {
            errorMessage = "Please ensure all fields are filled out correctly."
            completion(false)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            guard let self = self, let uid = authResult?.user.uid else {
                completion(false)
                return
            }

            // Send email verification
            authResult?.user.sendEmailVerification(completion: nil)

            let defaultProfileImageURL = "https://example.com/default-profile.png"

            if let image = self.profileImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                // Upload profile image
                let storageRef = Storage.storage().reference().child("profileImages/\(uid)/profile.jpg")
                storageRef.putData(imageData, metadata: nil) { _, error in
                    var profileURL = defaultProfileImageURL
                    if error == nil {
                        storageRef.downloadURL { url, _ in
                            if let urlString = url?.absoluteString {
                                profileURL = urlString
                            }
                            self.saveUserDocuments(uid: uid, profileImageURL: profileURL, completion: completion)
                        }
                    } else {
                        // Upload failed, use default
                        self.saveUserDocuments(uid: uid, profileImageURL: profileURL, completion: completion)
                    }
                }
            } else {
                // No image selected, use default
                self.saveUserDocuments(uid: uid, profileImageURL: defaultProfileImageURL, completion: completion)
            }
        }
    }

    // MARK: - Save to Firestore
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

        // Write to /users
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                completion(false)
                return
            }

            // Write to /publicProfiles
            self.db.collection("publicProfiles").document(uid).setData(publicProfileData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save public profile: \(error.localizedDescription)"
                    completion(false)
                } else {
                    self.clearFields()
                    completion(true)
                }
            }
        }
    }

    // MARK: - Clear input fields
    private func clearFields() {
        name = ""
        username = ""
        email = ""
        password = ""
        confirmPassword = ""
        profileImage = nil
        errorMessage = nil
    }

    // MARK: - Validation helpers
    static func isValidEmail(_ email: String) -> Bool {
        let emailLower = email.lowercased()
        return emailLower.contains("@") && emailLower.contains(".com")
    }

    static func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        
        let uppercasePattern = ".*[A-Z]+.*"
        let lowercasePattern = ".*[a-z]+.*"
        let numberPattern = ".*[0-9]+.*"
        let symbolPattern = ".*[!@#$%^&*(),.?\":{}|<>]+.*"
        
        let uppercaseTest = NSPredicate(format: "SELF MATCHES %@", uppercasePattern)
        let lowercaseTest = NSPredicate(format: "SELF MATCHES %@", lowercasePattern)
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberPattern)
        let symbolTest = NSPredicate(format: "SELF MATCHES %@", symbolPattern)
        
        return uppercaseTest.evaluate(with: password)
            && lowercaseTest.evaluate(with: password)
            && numberTest.evaluate(with: password)
            && symbolTest.evaluate(with: password)
    }
}
