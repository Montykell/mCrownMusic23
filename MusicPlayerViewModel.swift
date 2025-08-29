//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import Combine
import AVKit
import FirebaseStorage

class MusicPlayerViewModel: ObservableObject {
    @Published var currentTrack: MusicItem? {
        didSet { updateCurrentTrackIndex() }
    }
    @Published var isPlaying: Bool = false
    @Published var tracks: [MusicItem] = []
    @Published var isShuffling: Bool = false
    @Published var repeatMode: RepeatMode = .none
    @Published var searchText: String = ""

    private var player: AVPlayer?
    private var currentTrackIndex: Int?

    enum RepeatMode {
        case none, track, album
    }

    // Filtered tracks based on searchText
    var filteredTracks: [MusicItem] {
        if searchText.isEmpty { return tracks }
        return tracks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: Player Setup
    func setupPlayer() { updateCurrentTrackIndex() }

    func togglePlayPause() {
        if isPlaying { player?.pause() } else { player?.play() }
        isPlaying.toggle()
    }

    func play(track: MusicItem) {
        stopPlayer()
        guard let url = track.url else { return }
        player = AVPlayer(url: url)
        currentTrack = track
        player?.play()
        isPlaying = true
        updateCurrentTrackIndex()
    }

    func playNextTrack() {
        guard !tracks.isEmpty else { return }
        let nextIndex: Int
        if isShuffling {
            nextIndex = Int.random(in: 0..<tracks.count)
        } else {
            if let currentIndex = currentTrackIndex {
                nextIndex = (currentIndex + 1) % tracks.count
            } else { nextIndex = 0 }
        }
        play(track: tracks[safe: nextIndex] ?? tracks[0])
    }

    func playPreviousTrack() {
        guard !tracks.isEmpty else { return }
        let previousIndex: Int
        if isShuffling {
            previousIndex = Int.random(in: 0..<tracks.count)
        } else {
            if let currentIndex = currentTrackIndex {
                previousIndex = (currentIndex - 1 + tracks.count) % tracks.count
            } else { previousIndex = 0 }
        }
        play(track: tracks[safe: previousIndex] ?? tracks[0])
    }

    func toggleShuffle() { isShuffling.toggle() }
    
    func toggleRepeatMode() {
        switch repeatMode {
        case .none:
            repeatMode = .track
        case .track:
            repeatMode = .album
        case .album:
            repeatMode = .none
        }
    }

    func repeatModeIcon() -> String {
        switch repeatMode {
        case .none: return "repeat"
        case .track: return "repeat.1"
        case .album: return "repeat"
        }
    }

    func setRepeatMode(_ mode: RepeatMode) { repeatMode = mode }

    func stopPlayer() {
        player?.pause()
        player = nil
        isPlaying = false
    }

    func loadAllTracks() {
        let storage = Storage.storage(url: "gs://mcrownmusic23.firebasestorage.app")
        let storageRef = storage.reference().child("40352/")

        storageRef.listAll { [weak self] result, error in
            guard let self = self else { return }
            if let error = error { print("Error listing files: \(error.localizedDescription)"); return }
            guard let result = result else { print("No result returned"); return }

            var tracks = result.items
                .filter { $0.name.hasSuffix(".m4a") }
                .map { item in
                    MusicItem(id: UUID(), title: item.name.replacingOccurrences(of: ".m4a", with: ""), artist: "Olso", url: nil)
                }
                .sorted { $0.title < $1.title }

            let dispatchGroup = DispatchGroup()
            for (index, item) in result.items.enumerated() {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    defer { dispatchGroup.leave() }
                    if let url = url, index < tracks.count { tracks[index].url = url }
                    else if let error = error { print("Failed URL for index \(index): \(error.localizedDescription)") }
                }
            }

            dispatchGroup.notify(queue: .main) { self.tracks = tracks }
        }
    }

    private func updateCurrentTrackIndex() {
        if let currentTrack = currentTrack {
            currentTrackIndex = tracks.firstIndex { $0.id == currentTrack.id }
        } else { currentTrackIndex = nil }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}
