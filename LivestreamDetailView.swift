//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct LivestreamDetailView: View {
    @ObservedObject var viewModel: LivestreamDetailViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.livestreamEvent.title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("Start Time: \(viewModel.livestreamEvent.startTime, formatter: dateFormatter)")
                .font(.body)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Livestream Detail")
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

struct LivestreamDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LivestreamDetailView(viewModel: LivestreamDetailViewModel(livestreamEvent: LivestreamEvent(id: 1, title: "Livestream Event 1", startTime: Date(), endTime: Date().addingTimeInterval(3600))))
    }
}
