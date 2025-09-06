//
//
//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation

struct MusicItem: Hashable, Identifiable {
    var id: UUID
    var title: String
    var artist: String
    var url: URL? // Optional URL for the track
    
    // Optional album cover image URL
    var albumCoverURL: URL?
    
    // Duration of the track in seconds
    var duration: TimeInterval?
    
    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(artist)
        hasher.combine(url)
    }
    
    // Conform to Equatable
    static func == (lhs: MusicItem, rhs: MusicItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.artist == rhs.artist &&
               lhs.url == rhs.url
    }
}


import Foundation

struct AlbumItem: Hashable, Identifiable {
    var id: UUID
    var title: String
    var artist: String
    var tracks: [MusicItem] = []
    
    // Optional album cover image URL
    var albumCoverURL: URL?

    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(artist)
        hasher.combine(tracks.map { $0.id }) // Hash based on track IDs for better performance
    }
    
    // Conform to Equatable
    static func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.artist == rhs.artist &&
               lhs.tracks == rhs.tracks
    }
}
