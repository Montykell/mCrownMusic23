//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

struct UserProfile: Identifiable {
    var id: String
    var name: String
    var username: String
    var email: String
    var phoneNumber: String
    var profileImageURL: String?
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    @Published var profileImage: UIImage?
    @Published var userPosts: [Update] = []

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var profileListener: ListenerRegistration?
    private var postsListener: ListenerRegistration?
    private let rtdb = Database.database(url: "https://mcrownmusic23-default-rtdb.firebaseio.com/").reference()

    init() {
        startListeningForProfile()
        fetchUserPosts()
    }

    deinit {
        profileListener?.remove()
        postsListener?.remove()
    }

    // MARK: - Listen for profile changes
    func startListeningForProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        profileListener = db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching profile: \(error)")
                    return
                }
                guard let data = snapshot?.data() else { return }

                let userProfile = UserProfile(
                    id: uid,
                    name: data["name"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    phoneNumber: data["phoneNumber"] as? String ?? "",
                    profileImageURL: data["profileImageURL"] as? String
                )
                self.user = userProfile

                // Load profile image
                if let urlString = userProfile.profileImageURL,
                   let url = URL(string: "\(urlString)?t=\(Date().timeIntervalSince1970)") {
                    self.downloadImage(from: url)
                }
            }
    }

    // MARK: - Download image
    func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async { self.profileImage = image }
            } else if let error = error {
                print("Error downloading image: \(error)")
            }
        }.resume()
    }

    // MARK: - Upload profile image
    // MARK: - Upload profile image and update Firestore
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let imageRef = storage.reference().child("profileImages/\(uid)/profile.jpg")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(false)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(false)
                    return
                }

                guard let profileImageURL = url?.absoluteString else {
                    completion(false)
                    return
                }

                // Update both users and publicProfiles
                let changes: [String: Any] = ["profileImageURL": profileImageURL]

                let batch = self.db.batch()
                let usersRef = self.db.collection("users").document(uid)
                let publicRef = self.db.collection("publicProfiles").document(uid)
                batch.setData(changes, forDocument: usersRef, merge: true)
                batch.setData(changes, forDocument: publicRef, merge: true)

                batch.commit { error in
                    if let error = error {
                        print("Error updating profile image in Firestore: \(error)")
                        completion(false)
                    } else {
                        print("Profile image updated in both collections successfully")
                        // Optionally update local state
                        DispatchQueue.main.async {
                            self.user?.profileImageURL = profileImageURL
                            self.profileImage = image
                        }
                        completion(true)
                    }
                }
            }
        }
    }

    // MARK: - Update profile
    func updateProfile(changes: [String: Any]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).setData(changes, merge: true) { error in
            if let error = error {
                print("Error updating profile: \(error)")
            } else {
                print("Profile updated successfully")
            }
        }
    }

    // MARK: - Fetch user's posts from Realtime Database
    func fetchUserPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        rtdb.child("updates").queryOrdered(byChild: "userId").queryEqual(toValue: uid)
            .observeSingleEvent(of: .value) { snapshot in
                var posts: [Update] = []
                let group = DispatchGroup() // To fetch Firestore user profile if needed

                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let data = snap.value as? [String: Any],
                       let description = data["description"] as? String,
                       let timestamp = data["timestamp"] as? TimeInterval {

                        let userId = data["userId"] as? String ?? uid
                        let username = data["username"] as? String
                        let photoURL = data["photoURL"] as? String // <- from RTDB
                        var profileImageURL: String?

                        group.enter()
                        // Fetch user's profileImageURL from Firestore
                        self.db.collection("users").document(userId).getDocument { doc, error in
                            if let data = doc?.data() {
                                profileImageURL = data["profileImageURL"] as? String
                            }

                            let post = Update(
                                id: snap.key,
                                userId: userId,
                                description: description,
                                timestamp: timestamp,
                                username: username,
                                photoURL: photoURL, // keep RTDB photoURL
                                likes: data["likes"] as? [String: Bool],
                                dislikes: data["dislikes"] as? [String: Bool]
                            )
                            posts.append(post)
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.userPosts = posts.sorted { $0.timestamp > $1.timestamp }
                }
            }
    }



    // MARK: - Delete a user's post
    func deletePost(postId: String, completion: @escaping (Bool) -> Void) {
        db.collection("updates").document(postId).delete { [weak self] error in
            if let error = error {
                print("Error deleting post: \(error)")
                completion(false)
                return
            }
            self?.fetchUserPosts() // refresh after deletion
            completion(true)
        }
    }
}
