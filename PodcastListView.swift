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
            VStack {
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
                        VStack(alignment: .leading) {
                            Text(episode.title)
                                .font(.headline)
                            Text(episode.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .navigationTitle("Podcasts")
                    .onAppear {
                        viewModel.fetchPodcastEpisodes()
                    }
                }
            }
        }
    }
}

struct PodcastListView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastListView(viewModel: PodcastListViewModel())
    }
}

