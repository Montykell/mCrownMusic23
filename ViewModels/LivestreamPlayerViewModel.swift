//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import AVKit
import Combine

class LivestreamPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying: Bool = false
    @Published var livestreamEvent: LivestreamEvent
    
    private var cancellables = Set<AnyCancellable>()
    
    init(livestreamEvent: LivestreamEvent) {
        self.livestreamEvent = livestreamEvent
        setupPlayer()
    }
    
    func setupPlayer() {
        // Example: Setting up player with livestream URL
        guard let url = URL(string: "https://example.com/livestream") else {
            print("Invalid livestream URL.")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Example: Monitor player state for playback updates
        player?.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                self?.isPlaying = status == .playing
            }
            .store(in: &cancellables)
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    deinit {
        // Clean up
        player?.pause()
    }
}
