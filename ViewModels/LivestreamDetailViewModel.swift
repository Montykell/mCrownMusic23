//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation

class LivestreamDetailViewModel: ObservableObject {
    @Published var livestreamEvent: LivestreamEvent
    
    init(livestreamEvent: LivestreamEvent) {
        self.livestreamEvent = livestreamEvent
    }
}
