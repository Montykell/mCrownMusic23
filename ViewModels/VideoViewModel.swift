//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI
import Combine

class VideoViewModel: ObservableObject {
    @Published var videoURL: URL

    init(videoURL: URL) {
        self.videoURL = videoURL
    }
}
