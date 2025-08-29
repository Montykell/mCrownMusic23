//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct MusicListView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(viewModel.filteredTracks) { track in
                    MusicRowView(
                        track: track,
                        isCurrent: viewModel.currentTrack?.id == track.id
                    ) {
                        if viewModel.currentTrack?.id == track.id {
                            viewModel.togglePlayPause()
                        } else {
                            viewModel.play(track: track)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Single Music Row
struct MusicRowView: View {
    let track: MusicItem
    let isCurrent: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Album cover
                if let url = track.albumCoverURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.brown.opacity(0.6))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.brown.opacity(0.6))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.headline)
                        .foregroundColor(.brown)
                    Text(track.artist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                if isCurrent {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCurrent ? Color.orange.opacity(0.2) : Color.white.opacity(0.8))
            )
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}
