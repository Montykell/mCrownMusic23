//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import Combine

class LivestreamListViewModel: ObservableObject {
    @Published var livestreams: [LivestreamEvent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchLivestreams() {
        isLoading = true
        // Simulating async fetching of livestream events
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.livestreams = [
                LivestreamEvent(id: 1, title: "Livestream Event 1", startTime: Date(), endTime: Date().addingTimeInterval(3600)),
                LivestreamEvent(id: 2, title: "Livestream Event 2", startTime: Date().addingTimeInterval(7200), endTime: Date().addingTimeInterval(10800))
            ]
            self.isLoading = false
        }
    }
}
