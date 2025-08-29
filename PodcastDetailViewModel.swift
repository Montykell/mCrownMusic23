//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation

class PodcastDetailViewModel: ObservableObject {
    @Published var podcastEpisode: PodcastEpisode
    
    init(podcastEpisode: PodcastEpisode) {
        self.podcastEpisode = podcastEpisode
    }
}
