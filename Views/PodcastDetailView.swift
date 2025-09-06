//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct PodcastDetailView: View {
    @ObservedObject var viewModel: PodcastDetailViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.podcastEpisode.title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text(viewModel.podcastEpisode.description)
                .font(.body)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Podcast Detail")
    }
}

struct PodcastDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastDetailView(viewModel: PodcastDetailViewModel(podcastEpisode: PodcastEpisode(id: 1, title: "Talkin w Tae", description: "Coming SOON!")))
    }
}
