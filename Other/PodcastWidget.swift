//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import SwiftUI

struct PodcastWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Podcast")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Podcast Title")
                    .font(.headline)
                
                Text("Episode Title")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}
