//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import Combine

class PodcastListViewModel: ObservableObject {
    @Published var podcastEpisodes: [PodcastEpisode] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPodcastEpisodes() {
        isLoading = true
        // Simulating async fetching of podcast episodes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.podcastEpisodes = [
                PodcastEpisode(id: 1, title: "Episode 1", description: "Description for Episode 1"),
                PodcastEpisode(id: 2, title: "Episode 2", description: "Description for Episode 2"),
                PodcastEpisode(id: 3, title: "Episode 3", description: "Description for Episode 3")
            ]
            self.isLoading = false
        }
    }
}

struct PodcastEpisode: Identifiable {
    var id: Int
    var title: String
    var description: String
}
