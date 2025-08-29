//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import Combine
import FirebaseStorage

class MusicListViewModel: ObservableObject {
    @Published var tracks: [MusicItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let album: AlbumItem

    init(album: AlbumItem) {
        self.album = album
        loadAlbumTracks()
    }

    func loadAlbumTracks() {
        isLoading = true
        errorMessage = nil
        
        let storageRef = Storage.storage().reference().child("40352/")
        
        storageRef.listAll { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Error listing files: \(error.localizedDescription)"
                self.isLoading = false
                return
            }
            
            guard let result = result else {
                self.errorMessage = "No result returned from listAll"
                self.isLoading = false
                return
            }

            var tracks = result.items
                .filter { $0.name.hasSuffix(".m4a") }
                .map { item in
                    return MusicItem(
                        id: UUID(),
                        title: item.name.replacingOccurrences(of: ".m4a", with: ""),
                        artist: self.album.artist,
                        url: nil
                    )
                }
                .sorted { $0.title < $1.title }

            let dispatchGroup = DispatchGroup()
            
            for (index, item) in result.items.enumerated() {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    defer { dispatchGroup.leave() }
                    if let url = url {
                        // Ensure that the index is within bounds
                        if index < tracks.count {
                            tracks[index].url = url
                        }
                    } else if let error = error {
                        print("Failed to get URL for track at index \(index): \(error.localizedDescription)")
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.tracks = tracks
                self.isLoading = false
            }
        }
    }
}
