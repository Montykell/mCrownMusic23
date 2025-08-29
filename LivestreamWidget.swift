//
//  Untitled.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import Foundation
import SwiftUI

struct LiveStreamsWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Streams")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(0..<3) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Stream \(index + 1)")
                        .font(.headline)
                    
                    Text("Now playing...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
    }
}
