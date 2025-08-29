//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import AVKit
import Combine

class PodcastPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentEpisode: PodcastEpisode?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Example: Set up player with a default episode
        currentEpisode = PodcastEpisode(id: 1, title: "KnowSo w Olso", description: "EP.1 Coming SOON!")
        setupPlayer()
    }
    
    func setupPlayer() {
        guard let urlString = Bundle.main.path(forResource: "episode1", ofType: "mp3") else {
            print("File not found.")
            return
        }
        let url = URL(fileURLWithPath: urlString)
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
