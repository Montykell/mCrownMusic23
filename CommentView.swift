//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    var replyAction: (Reply) -> Void
    var deleteAction: () -> Void
    var fetchReplies: () -> Void
    @State private var replyText: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text(comment.text)
                .font(.body)

            // Reply input
            HStack {
                TextField("Type your reply...", text: $replyText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Reply") {
                    let reply = Reply(
                        id: UUID().uuidString,
                        commentId: comment.id,
                        userID: comment.userID,
                        userName: comment.userName, userImageURL: comment.userImageURL, // Assuming userName is the same as the comment's
                        text: replyText,
                        photoURL: comment.photoURL, // Optional, assuming the comment has a photoURL
                        // Pass the userImageURL if available
                        timestamp: Date().timeIntervalSince1970
                    )
                    
                    replyAction(reply) // Pass the Reply to the action
                    replyText = "" // Clear the text field
                }
            }


            // Display replies
            ForEach(comment.replies) { reply in
                VStack(alignment: .leading) {
                    Text(reply.text)
                        .font(.subheadline)
                        .padding(.leading, 16) // Indent replies

                    Button(action: {
                        // Handle delete action for reply
                    }) {
                        Text("Delete")
                    }
                }
            }

            Button(action: deleteAction) {
                Text("Delete Comment")
            }
        }
        .padding()
    }
}
