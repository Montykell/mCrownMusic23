//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation

class MusicDetailViewModel: ObservableObject {
    @Published var musicItem: MusicItem
    
    init(musicItem: MusicItem) {
        self.musicItem = musicItem
    }
}
