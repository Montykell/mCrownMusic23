//
//  CommentsViewModel.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/30/25.
//
import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

@MainActor
class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var replyText: String = ""
    @Published var showReplyField: Bool = false

    let updateID: String
    let db = Database.database().reference()
    let firestoreDB = Firestore.firestore()
    let auth = Auth.auth()

    init(updateID: String) {
        self.updateID = updateID
        fetchComments()
    }

    // MARK: - Fetch Comments
    func fetchComments() {
        let commentsRef = db.child("updates").child(updateID).child("comments")
        commentsRef.observe(.value) { snapshot in
            var loadedComments: [Comment] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   var comment = Comment(from: dict) {

                    if let repliesDict = dict["replies"] as? [String: [String: Any]] {
                        comment.replies = repliesDict.values.compactMap { Reply(from: $0) }
                            .sorted(by: { $0.timestamp < $1.timestamp })
                    }

                    loadedComments.append(comment)
                }
            }

            self.comments = loadedComments.sorted(by: { $0.timestamp < $1.timestamp })
        }
    }

    // MARK: - Save Comment
    func saveComment(_ text: String) {
        guard let currentUser = auth.currentUser else { return }
        let commentId = db.childByAutoId().key ?? UUID().uuidString

        firestoreDB.collection("publicProfiles").document(currentUser.uid).getDocument { snapshot, _ in
            let username = snapshot?.get("username") as? String ?? "Anonymous"
            let photoURL = snapshot?.get("profileImageURL") as? String ?? ""

            let commentData: [String: Any] = [
                "id": commentId,
                "postId": self.updateID,
                "userID": currentUser.uid,
                "userName": username,
                "userImageURL": photoURL,
                "text": text,
                "timestamp": Date().timeIntervalSince1970,
                "replies": [:]
            ]

            self.db.child("updates").child(self.updateID).child("comments").child(commentId).setValue(commentData)
        }
    }

    // MARK: - Save Reply
    func saveReply(_ reply: Reply, to comment: Comment) {
        let replyData: [String: Any] = [
            "id": reply.id,
            "commentId": comment.id,
            "userID": reply.userID,
            "userName": reply.userName,
            "userImageURL": reply.userImageURL ?? "",
            "text": reply.text,
            "timestamp": reply.timestamp,
            "likes": [:],
            "dislikes": [:]
        ]

        db.child("updates").child(updateID).child("comments").child(comment.id).child("replies").child(reply.id).setValue(replyData)
    }

    // MARK: - Delete Comment / Reply
    func deleteComment(_ comment: Comment) {
        db.child("updates").child(updateID).child("comments").child(comment.id).removeValue()
    }

    func deleteReply(_ reply: Reply, from comment: Comment) {
        db.child("updates").child(updateID).child("comments").child(comment.id).child("replies").child(reply.id).removeValue()
    }

    // MARK: - Like/Dislike Replies
    func likeReply(_ reply: Reply, in comment: Comment) {
        guard let currentUser = auth.currentUser else { return }
        let replyRef = db.child("updates").child(updateID)
            .child("comments").child(comment.id)
            .child("replies").child(reply.id).child("likes").child(currentUser.uid)

        let isLiked = reply.didLike(currentUserId: currentUser.uid)
        replyRef.setValue(!isLiked)

        let dislikeRef = db.child("updates").child(updateID)
            .child("comments").child(comment.id)
            .child("replies").child(reply.id).child("dislikes").child(currentUser.uid)
        dislikeRef.setValue(false)
    }

    func dislikeReply(_ reply: Reply, in comment: Comment) {
        guard let currentUser = auth.currentUser else { return }
        let replyRef = db.child("updates").child(updateID)
            .child("comments").child(comment.id)
            .child("replies").child(reply.id).child("dislikes").child(currentUser.uid)

        let isDisliked = reply.didDislike(currentUserId: currentUser.uid)
        replyRef.setValue(!isDisliked)

        let likeRef = db.child("updates").child(updateID)
            .child("comments").child(comment.id)
            .child("replies").child(reply.id).child("likes").child(currentUser.uid)
        likeRef.setValue(false)
    }
}
