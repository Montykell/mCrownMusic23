//
//  Comment.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation

struct Reply: Identifiable, Codable {
    var id: String
    var commentId: String
    var userID: String
    var userName: String
    var userImageURL: String?
    var text: String
    var photoURL: String?
    var timestamp: TimeInterval

    // Memberwise init so you can call Reply(...)
    init(
        id: String,
        commentId: String,
        userID: String,
        userName: String,
        userImageURL: String?,
        text: String,
        photoURL: String?,
        timestamp: TimeInterval
    ) {
        self.id = id
        self.commentId = commentId
        self.userID = userID
        self.userName = userName
        self.userImageURL = userImageURL
        self.text = text
        self.photoURL = photoURL
        self.timestamp = timestamp
    }

    // Firestore init
    init?(from dict: [String: Any]) {
        guard
            let id = dict["id"] as? String,
            let commentId = dict["commentId"] as? String,
            let userID = dict["userID"] as? String,
            let userName = dict["userName"] as? String,
            let text = dict["text"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval
        else {
            return nil
        }

        self.init(
            id: id,
            commentId: commentId,
            userID: userID,
            userName: userName,
            userImageURL: dict["userImageURL"] as? String,
            text: text,
            photoURL: dict["photoURL"] as? String,
            timestamp: timestamp
        )
    }
}
struct Comment: Identifiable, Codable {
    var id: String
    var postId: String
    var userID: String
    var userName: String
    var userImageURL: String?
    var text: String
    var photoURL: String?
    var timestamp: TimeInterval
    var replies: [Reply] = []

    // Memberwise init for creating a new comment in code
    init(
        id: String,
        postId: String,
        userID: String,
        userName: String,
        userImageURL: String?,
        text: String,
        photoURL: String?,
        timestamp: TimeInterval,
        replies: [Reply] = []
    ) {
        self.id = id
        self.postId = postId
        self.userID = userID
        self.userName = userName
        self.userImageURL = userImageURL
        self.text = text
        self.photoURL = photoURL
        self.timestamp = timestamp
        self.replies = replies
    }

    // Firestore/dictionary initializer
    init?(from dict: [String: Any]) {
        guard
            let id = dict["id"] as? String,
            let postId = dict["postId"] as? String,
            let userID = dict["userID"] as? String,
            let userName = dict["userName"] as? String,
            let text = dict["text"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval
        else {
            return nil
        }

        self.init(
            id: id,
            postId: postId,
            userID: userID,
            userName: userName,
            userImageURL: dict["userImageURL"] as? String,
            text: text,
            photoURL: dict["photoURL"] as? String,
            timestamp: timestamp,
            replies: [] // You'll need to populate replies separately, e.g., with a fetchReplies() method
        )
    }
}
