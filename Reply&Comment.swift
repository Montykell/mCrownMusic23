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
    var timestamp: TimeInterval
    
    var likes: [String: Bool] = [:]
    var dislikes: [String: Bool] = [:]
    
    // MARK: - Initializer
    init(
        id: String,
        commentId: String,
        userID: String,
        userName: String,
        userImageURL: String?,
        text: String,
        timestamp: TimeInterval,
        likes: [String: Bool] = [:],
        dislikes: [String: Bool] = [:]
    ) {
        self.id = id
        self.commentId = commentId
        self.userID = userID
        self.userName = userName
        self.userImageURL = userImageURL
        self.text = text
        self.timestamp = timestamp
        self.likes = likes
        self.dislikes = dislikes
    }
    
    // MARK: - Computed Properties
    var likeCount: Int { likes.filter { $0.value }.count }
    var dislikeCount: Int { dislikes.filter { $0.value }.count }
    
    func didLike(currentUserId: String) -> Bool {
        likes[currentUserId] == true
    }
    
    func didDislike(currentUserId: String) -> Bool {
        dislikes[currentUserId] == true
    }
    
    // MARK: - Dictionary initializer (from Firebase)
    init?(from dict: [String: Any]) {
        guard
            let id = dict["id"] as? String,
            let commentId = dict["commentId"] as? String,
            let userID = dict["userID"] as? String,
            let userName = dict["userName"] as? String,
            let text = dict["text"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval
        else { return nil }
        
        self.init(
            id: id,
            commentId: commentId,
            userID: userID,
            userName: userName,
            userImageURL: dict["userImageURL"] as? String,
            text: text,
            timestamp: timestamp,
            likes: dict["likes"] as? [String: Bool] ?? [:],
            dislikes: dict["dislikes"] as? [String: Bool] ?? [:]
        )
    }
}

import Foundation

struct Comment: Identifiable, Codable {
    var id: String
    var postId: String
    var userID: String
    var userName: String
    var userImageURL: String?
    var text: String
    var timestamp: TimeInterval
    
    var replies: [Reply] = []
    var likes: [String: Bool] = [:]
    var dislikes: [String: Bool] = [:]
    
    // MARK: - Initializer
    init(
        id: String,
        postId: String,
        userID: String,
        userName: String,
        userImageURL: String?,
        text: String,
        timestamp: TimeInterval,
        replies: [Reply] = [],
        likes: [String: Bool] = [:],
        dislikes: [String: Bool] = [:]
    ) {
        self.id = id
        self.postId = postId
        self.userID = userID
        self.userName = userName
        self.userImageURL = userImageURL
        self.text = text
        self.timestamp = timestamp
        self.replies = replies
        self.likes = likes
        self.dislikes = dislikes
    }
    
    // MARK: - Computed Properties
    var likeCount: Int { likes.filter { $0.value }.count }
    var dislikeCount: Int { dislikes.filter { $0.value }.count }
    
    func didLike(currentUserId: String) -> Bool {
        likes[currentUserId] == true
    }
    
    func didDislike(currentUserId: String) -> Bool {
        dislikes[currentUserId] == true
    }
    
    // MARK: - Dictionary initializer (from Firebase)
    init?(from dict: [String: Any]) {
        guard
            let id = dict["id"] as? String,
            let postId = dict["postId"] as? String,
            let userID = dict["userID"] as? String,
            let userName = dict["userName"] as? String,
            let text = dict["text"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval
        else { return nil }
        
        var replies: [Reply] = []
        if let repliesDict = dict["replies"] as? [String: [String: Any]] {
            replies = repliesDict.values.compactMap { Reply(from: $0) }
                .sorted(by: { $0.timestamp < $1.timestamp })
        }
        
        self.init(
            id: id,
            postId: postId,
            userID: userID,
            userName: userName,
            userImageURL: dict["userImageURL"] as? String,
            text: text,
            timestamp: timestamp,
            replies: replies,
            likes: dict["likes"] as? [String: Bool] ?? [:],
            dislikes: dict["dislikes"] as? [String: Bool] ?? [:]
        )
    }
}
