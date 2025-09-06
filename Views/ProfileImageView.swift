//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct ProfileImageView: View {
    var photoURL: URL?
    
    var body: some View {
        AsyncImage(url: photoURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            case .failure:
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                    .overlay(Text("N/A").font(.caption))
            default:
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
            }
        }
        .frame(width: 50, height: 50)
    }
}

#Preview {
    ProfileImageView()
}
