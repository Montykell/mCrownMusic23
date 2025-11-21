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
import PhotosUI

@MainActor
class SignUpViewModel: ObservableObject {
    // MARK: - Input
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var profileImage: UIImage?
    @Published var phoneNumber: String = ""
    
    // MARK: - Output
    @Published var isValid: Bool = false
    @Published var errorMessage: String?
    @Published var statusMessage: String? // non-error information (verification sent etc)
    @Published var isCheckingUsername: Bool = false
    @Published var isUsernameAvailable: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    // fallback picture if upload fails or none selected
    private let defaultProfileImageURL = "https://example.com/default-profile.png"
    
    init() {
        // Debounced username availability check
        $username
            .removeDuplicates()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] username in
                guard let self = self else { return }
                guard !username.isEmpty && SignUpViewModel.isValidUsername(username) else {
                    // if empty or invalid format, treat as not available to prevent premature enable
                    self.isUsernameAvailable = false
                    return
                }
                Task { await self.checkUsernameAvailability(username: username) }
            }
            .store(in: &cancellables)
        
        // Validation pipeline includes phone and username availability
        Publishers.CombineLatest4($name, $username, $email, $password)
            .combineLatest($confirmPassword, $phoneNumber, $isUsernameAvailable)
            .map { (input, confirmPassword, phoneNumber, isUsernameAvailable) in
                let (name, username, email, password) = input
                
                let nameValid = Self.isValidFullName(name)
                let usernameValid = Self.isValidUsername(username)
                let emailValid = Self.isValidEmail(email)
                let passwordValid = Self.isValidPassword(password)
                let passwordsMatch = password == confirmPassword
                // digits only phone check: require exactly 10 digits (US)
                let digits = phoneNumber.filter { "0"..."9" ~= $0 }
                let phoneValid = digits.count == 10
                
                return nameValid && usernameValid && emailValid && passwordValid && passwordsMatch && phoneValid && isUsernameAvailable
            }
            .receive(on: RunLoop.main)
            .assign(to: &$isValid)
    }
    
    // MARK: - Public API
    
    /// Sign up user. Calls completion(true) on success; completion(false) on failure.
    func signUp(completion: @escaping (Bool) -> Void) {
        // Clear previous messages
        errorMessage = nil
        statusMessage = nil
        
        guard isValid else {
            errorMessage = "Please ensure all fields are filled out correctly."
            completion(false)
            return
        }
        
        // Create user
        Auth.auth().createUser(withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines),
                               password: password) { [weak self] authResult, error in
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
            
            // Send verification email (best-effort)
            user.sendEmailVerification { sendError in
                if let sendError = sendError {
                    print("Failed to send verification email: \(sendError.localizedDescription)")
                    // statusMessage is optional, we won't fail signup on this alone
                } else {
                    print("Verification email sent to \(user.email ?? "")")
                }
            }
            
            // Upload profile image if exists; else use default.
            if let image = self.profileImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference().child("profileImages/\(user.uid)/profile.jpg")
                
                storageRef.putData(imageData, metadata: nil) { metadata, uploadError in
                    if let uploadError = uploadError {
                        print("Failed to upload image: \(uploadError.localizedDescription)")
                        // Continue and save user document with default image URL
                        self.saveUserDocuments(uid: user.uid, profileImageURL: self.defaultProfileImageURL) { saved in
                            if saved {
                                self.statusMessage = "A verification email has been sent to \(user.email ?? ""). Please verify before signing in."
                                completion(true)
                            } else {
                                completion(false)
                            }
                        }
                        return
                    }
                    
                    // Get real download URL
                    storageRef.downloadURL { url, urlError in
                        if let urlError = urlError {
                            print("Failed to fetch download URL: \(urlError.localizedDescription)")
                        }
                        let profileURL = url?.absoluteString ?? self.defaultProfileImageURL
                        self.saveUserDocuments(uid: user.uid, profileImageURL: profileURL) { saved in
                            if saved {
                                self.statusMessage = "A verification email has been sent to \(user.email ?? ""). Please verify before signing in."
                                completion(true)
                            } else {
                                completion(false)
                            }
                        }
                    }
                }
            } else {
                // No profile image selected, save with default URL
                self.saveUserDocuments(uid: user.uid, profileImageURL: self.defaultProfileImageURL) { saved in
                    if saved {
                        self.statusMessage = "A verification email has been sent to \(user.email ?? ""). Please verify before signing in."
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - Email verification check
    func checkEmailVerification(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        user.reload { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to reload user: \(error.localizedDescription)")
                self.errorMessage = "Failed to check verification status."
                completion(false)
            } else {
                completion(user.isEmailVerified)
            }
        }
    }
    
    // MARK: - Firestore Saving
    /// Saves full user document and a public profile document. Phone is saved as digits only.
    private func saveUserDocuments(uid: String, profileImageURL: String, completion: @escaping (Bool) -> Void) {
        // Format phone number to digits only
        let digits = phoneNumber.filter { "0"..."9" ~= $0 }
        let e164Phone = digits.count == 10 ? "+1\(digits)" : digits // best-effort formatting
        
        let userData: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespacesAndNewlines),
            "username": username.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
            "profileImageURL": profileImageURL,
            "phoneNumber": e164Phone,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        let publicProfileData: [String: Any] = [
            "username": username.trimmingCharacters(in: .whitespacesAndNewlines),
            "profileImageURL": profileImageURL,
            "displayName": name.trimmingCharacters(in: .whitespacesAndNewlines),
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).setData(userData) { [weak self] error in
            guard let self = self else { return }
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
    
    // MARK: - Username availability (simple Firestore query)
    /// Checks whether the username is already present in any publicProfiles document.
    /// Updates `isUsernameAvailable` and `isCheckingUsername`.
    func checkUsernameAvailability(username: String) async {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                self.isUsernameAvailable = false
                self.isCheckingUsername = false
            }
            return
        }
        await MainActor.run { self.isCheckingUsername = true }
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        do {
            let query = db.collection("publicProfiles").whereField("username", isEqualTo: trimmed)
            let snapshot = try await query.getDocuments()
            let taken = !snapshot.documents.isEmpty
            await MainActor.run {
                self.isUsernameAvailable = !taken
                self.isCheckingUsername = false
            }
        } catch {
            print("Username check failed: \(error.localizedDescription)")
            await MainActor.run {
                // In case of failure, conservatively mark as not available to prevent race conditions.
                self.isUsernameAvailable = false
                self.isCheckingUsername = false
            }
        }
    }
    
    // MARK: - Validation helpers
    static func isValidFullName(_ name: String) -> Bool {
        let parts = name.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        return parts.count >= 2 && parts.allSatisfy { !$0.isEmpty }
    }
    
    static func isValidUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        // keep original allowed characters (., _, -)
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
