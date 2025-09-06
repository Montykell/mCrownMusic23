//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct LivestreamPlayerView: View {
    let livestreamEvent: LivestreamEvent

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "video.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.brown)
                .padding(.top, 50)

            Text("Coming Soon!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.brown)

            Text("The livestream feature for \"\(livestreamEvent.title)\" will be available soon.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)

            Spacer()
        }
        .navigationTitle("Livestream")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

// Sample LivestreamEvent for preview
struct LivestreamPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEvent = LivestreamEvent(
            id: 1,
            title: "Exciting Event",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600)
        )
        LivestreamPlayerView(livestreamEvent: sampleEvent)
    }
}
