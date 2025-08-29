//
//  Update.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/14/25.
//

import Foundation

struct Update: Identifiable, Codable {
    var id: String
    var userId: String
    var username: String?
    var photoURL: String?
    var description: String
    var timestamp: TimeInterval
    
    var likes: [String: Bool]?
    var dislikes: [String: Bool]?
    
    // MARK: - Convenience Init
    init(
        id: String,
        userId: String,
        description: String,
        timestamp: TimeInterval,
        username: String? = nil,
        photoURL: String? = nil,
        likes: [String: Bool]? = nil,
        dislikes: [String: Bool]? = nil
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.photoURL = photoURL
        self.description = description
        self.timestamp = timestamp
        self.likes = likes
        self.dislikes = dislikes
    }
    
    // MARK: - Computed Properties
    var likeCount: Int {
        likes?.count ?? 0
    }
    
    var dislikeCount: Int {
        dislikes?.count ?? 0
    }
    
    // MARK: - User Actions
    func didLike(currentUserId: String) -> Bool {
        likes?[currentUserId] == true
    }
    
    func didDislike(currentUserId: String) -> Bool {
        dislikes?[currentUserId] == true
    }
}
