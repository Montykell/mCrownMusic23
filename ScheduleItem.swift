//
//
//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation

struct ScheduleItem: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    // Add any other properties you need for a schedule item
    
    init(title: String, time: String) {
        self.title = title
        self.time = time
    }
}
