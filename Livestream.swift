//
//
//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation

struct LivestreamEvent: Identifiable {
    var id: Int
    var title: String
    var startTime: Date
    var endTime: Date
    // Add more properties as needed, e.g., description, streamURL, thumbnailURL, etc.
}
let sampleLivestreamEvent = LivestreamEvent(
    id: 123,
    title: "Sample Livestream",
    startTime: Date(),
    endTime: Date().addingTimeInterval(3600)
)
