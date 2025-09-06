//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

struct CommentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var replyText: String = ""
    @State private var showReplyField: Bool = false

    let comment: Comment
    var replyAction: (Reply) -> Void
    var deleteCommentAction: () -> Void
    var deleteReplyAction: ((Reply) -> Void)? = nil

    private let firestoreDB = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: Comment Header
            HStack(alignment: .top, spacing: 8) {
                if let photoURL = comment.userImageURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(comment.userName).font(.subheadline).bold()
                    Text(comment.text).font(.body).foregroundColor(.primary).fixedSize(horizontal: false, vertical: true)

                    if comment.userID == authViewModel.currentUser?.uid {
                        Button(action: deleteCommentAction) {
                            Text("Delete Comment").font(.caption2).foregroundColor(.red)
                        }.padding(.top, 2)
                    }
                }
            }

            // MARK: Replies
            if !comment.replies.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(comment.replies.sorted(by: { $0.timestamp < $1.timestamp })) { reply in
                        HStack(alignment: .top, spacing: 8) {
                            if let urlString = reply.userImageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(reply.userName).font(.caption).bold()
                                Text(reply.text).font(.subheadline).foregroundColor(.primary)
                            }

                            Spacer()

                            if let deleteReplyAction = deleteReplyAction,
                               reply.userID == authViewModel.currentUser?.uid {
                                Button(action: { deleteReplyAction(reply) }) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.leading, 16)
                    }
                }
            }

            // MARK: Reply Field
            HStack(spacing: 8) {
                if showReplyField {
                    TextField("Type your reply...", text: $replyText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Send") { submitReply() }
                        .buttonStyle(BorderlessButtonStyle())
                } else {
                    Button(action: { showReplyField.toggle() }) {
                        Text("Reply").font(.caption).foregroundColor(.brown)
                    }
                }
            }.padding(.top, 4)
        }
        .padding(12)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    // MARK: Submit Reply
    private func submitReply() {
        guard !replyText.trimmingCharacters(in: .whitespaces).isEmpty,
              let currentUser = authViewModel.currentUser else { return }

        firestoreDB.collection("publicProfiles").document(currentUser.uid).getDocument { snapshot, _ in
            let username = snapshot?.get("username") as? String ?? "Anonymous"
            let photoURL = snapshot?.get("profileImageURL") as? String

            let newReply = Reply(
                id: UUID().uuidString,
                commentId: comment.id,
                userID: currentUser.uid,
                userName: username,
                userImageURL: photoURL,
                text: replyText,
                timestamp: Date().timeIntervalSince1970
            )

            replyAction(newReply)
            replyText = ""
            showReplyField = false
        }
    }
}

    // MARK: - AddCommentView inside CommentView
    struct AddCommentView: View {
        @State private var commentText: String = ""
        var onSubmit: (String) -> Void
        
        var body: some View {
            HStack(spacing: 8) {
                TextField("Add a comment...", text: $commentText)
                    .padding(8)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
                
                Button(action: {
                    let text = commentText.trimmingCharacters(in: .whitespaces)
                    guard !text.isEmpty else { return }
                    onSubmit(text)
                    commentText = ""
                }) {
                    Text("Send")
                        .foregroundColor(commentText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .brown)
                }
                .disabled(commentText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
        }
    }

