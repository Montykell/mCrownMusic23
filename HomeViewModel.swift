//
//  HomeViewModel.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth

@MainActor
class HomeViewModel: ObservableObject {
    @Published var updates: [Update] = []

    private let realtimeDB = Database.database(url: "https://mcrownmusic23-default-rtdb.firebaseio.com/").reference()
    private let firestoreDB = Firestore.firestore()

    // MARK: - Fetch all updates with user info
    func fetchAllUpdates() {
        // 1️⃣ Fetch all public profiles from Firestore
        firestoreDB.collection("publicProfiles").getDocuments { [weak self] snapshot, error in
            guard let self = self, let docs = snapshot?.documents else { return }

            // Build dictionary of userId -> (username, photoURL)
            var usersDict: [String: (username: String?, photoURL: String?)] = [:]
            for doc in docs {
                let userId = doc.documentID
                let username = doc.get("username") as? String
                let photoURL = doc.get("profileImageURL") as? String
                usersDict[userId] = (username, photoURL)
            }

            // 2️⃣ Fetch posts from Realtime Database
            self.fetchPosts(with: usersDict)
        }
    }

    // MARK: - Fetch posts and merge user info
    private func fetchPosts(with usersDict: [String: (username: String?, photoURL: String?)]) {
        let updatesRef = realtimeDB.child("updates")
        
        updatesRef.observe(.value) { snapshot in
            var loadedUpdates: [Update] = []
            
            for case let snap as DataSnapshot in snapshot.children {
                guard let dict = snap.value as? [String: Any],
                      let description = dict["description"] as? String,
                      let timestamp = dict["timestamp"] as? TimeInterval,
                      let userId = dict["userId"] as? String else { continue }
                
                let likesDict = dict["likes"] as? [String: Bool] ?? [:]
                let dislikesDict = dict["dislikes"] as? [String: Bool] ?? [:]
                
                let userInfo = usersDict[userId]
                
                let update = Update(
                    id: snap.key,
                    userId: userId,
                    description: description,
                    timestamp: timestamp,
                    username: userInfo?.username,
                    photoURL: userInfo?.photoURL,
                    likes: likesDict,
                    dislikes: dislikesDict
                )

                loadedUpdates.append(update)
            }
            
            DispatchQueue.main.async {
                self.updates = loadedUpdates.sorted { $0.timestamp > $1.timestamp }
            }
        }
    }

    // MARK: - Add update
    func addUpdate(description: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // 🔹 Fetch from publicProfiles now instead of users
        firestoreDB.collection("publicProfiles").document(uid).getDocument { [weak self] snapshot, _ in
            guard let self = self else { return }
            let username = snapshot?.get("username") as? String ?? ""
            let photoURL = snapshot?.get("profileImageURL") as? String ?? ""

            let newUpdateRef = self.realtimeDB.child("updates").childByAutoId()
            let updateData: [String: Any] = [
                "description": description,
                "likes": 0,
                "dislikes": 0,
                "timestamp": Date().timeIntervalSince1970,
                "userId": uid,
                "username": username,
                "photoURL": photoURL
            ]

            newUpdateRef.setValue(updateData) { error, _ in
                completion(error == nil)
            }
        }
    }

    // MARK: - Like
    func likeUpdate(updateId: String, completion: @escaping (Bool) -> Void) {
        realtimeDB.child("updates").child(updateId).child("likes").runTransactionBlock { currentData in
            var likes = currentData.value as? Int ?? 0
            likes += 1
            currentData.value = likes
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, _, _ in
            completion(error == nil)
        }
    }

    // MARK: - Dislike
    func dislikeUpdate(updateId: String, completion: @escaping (Bool) -> Void) {
        realtimeDB.child("updates").child(updateId).child("dislikes").runTransactionBlock { currentData in
            var dislikes = currentData.value as? Int ?? 0
            dislikes += 1
            currentData.value = dislikes
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, _, _ in
            completion(error == nil)
        }
    }

    // MARK: - Delete
    func deleteUpdate(updateId: String, completion: @escaping (Bool) -> Void) {
        realtimeDB.child("updates").child(updateId).removeValue { error, _ in
            completion(error == nil)
        }
    }
}
