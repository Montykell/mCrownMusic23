//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct MusicDetailView: View {
    @ObservedObject var viewModel: MusicDetailViewModel
    @ObservedObject var playerViewModel: MusicPlayerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Album Cover
                Image("40352")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: min(geometry.size.width * 0.8, 600),
                        height: min(geometry.size.width * 0.8, 600)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 8)
                
                // Track Title
                Text(viewModel.musicItem.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.brown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
