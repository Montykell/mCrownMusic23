//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct LivestreamListView: View {
    @ObservedObject var viewModel: LivestreamListViewModel
    
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
                    List(viewModel.livestreams) { livestream in
                        NavigationLink(destination: LivestreamDetailView(viewModel: LivestreamDetailViewModel(livestreamEvent: livestream))) {
                            VStack(alignment: .leading) {
                                Text(livestream.title)
                                    .font(.headline)
                                Text("Start Time: \(livestream.startTime, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .navigationTitle("Livestreams")
                    .onAppear {
                        viewModel.fetchLivestreams()
                    }
                }
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

struct LivestreamListView_Previews: PreviewProvider {
    static var previews: some View {
        LivestreamListView(viewModel: LivestreamListViewModel())
    }
}
