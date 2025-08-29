//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

// Example of a ReplyView for displaying replies
struct ReplyView: View {
    let reply: Reply
    var deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let photoURL = reply.photoURL {
                    // Load photo from URL or use a placeholder
                    AsyncImage(url: URL(string: photoURL)) { image in
                        image.resizable()
                             .scaledToFit()
                             .frame(width: 30, height: 30)
                             .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 30, height: 30)
                             .clipShape(Circle())
                    }
                }
                VStack(alignment: .leading) {
                    Text(reply.userName)
                        .font(.headline)
                    Text(reply.text)
                        .font(.subheadline)
                        .padding(.bottom, 2)
                }
            }
            HStack {
                Button("Delete") {
                    deleteAction()
                }
                .foregroundColor(.red)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
}
