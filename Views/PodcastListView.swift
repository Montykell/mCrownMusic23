//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct PodcastListView: View {
    @ObservedObject var viewModel: PodcastListViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.podcastEpisodes) { episode in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(episode.title)
                                .font(.headline)
                            Text(episode.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Podcasts")
                    .onAppear {
                        viewModel.fetchPodcastEpisodes()
                    }
                }
                
                // Banner Ad at bottom
                AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716") // test unit
                    .frame(width: 320, height: 50)
                    .padding(.bottom, 8)
                    .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .navigationViewStyle(.stack) // keeps it clean on iPad
    }
}

struct PodcastListView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastListView(viewModel: PodcastListViewModel())
    }
}


