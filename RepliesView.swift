//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ReplyInputField: View {
    @Binding var replyText: String
    var onSend: () -> Void

    var body: some View {
        HStack {
            TextField("Type your reply...", text: $replyText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(8)
                .background(Color.white.opacity(0.3))
                .cornerRadius(8)

            Button("Send") {
                onSend()
            }
            .foregroundColor(.white)
            .padding()
            .background(replyText.isEmpty ? Color.gray : Color.brown)
            .cornerRadius(8)
            .disabled(replyText.isEmpty)
        }
    }
}

struct RepliesView: View {
    let commentId: String
    var replyAction: (Reply) -> Void // Adjusted to accept Reply
    var deleteAction: (String) -> Void

    @State private var replies: [Reply] = [] // Change to Reply
    @State private var replyText: String = ""
    @State private var isReplying: Bool = false
    @State private var currentUser: User?
    @State private var usersData: [String: (userName: String, photoURL: String?)] = [:]
    @State private var isLoading: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                if !replies.isEmpty {
                    ForEach(replies) { reply in
                        ReplyView( // Custom view for Reply
                            reply: reply,
                            deleteAction: { deleteAction(reply.id) }
                        )
                        .padding(.leading, 16)
                    }
                }

                if isReplying {
                    ReplyInputField(replyText: $replyText) {
                        sendReply()
                    }
                } else {
                    Button("Reply") {
                        isReplying.toggle()
                    }
                    .foregroundColor(.brown)
                    .accessibilityLabel("Reply to this comment")
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.3))
        .cornerRadius(10)
        .shadow(radius: 1)
        .onAppear {
            fetchAllUsersData()
            fetchReplies()
        }
    }

    private func sendReply() {
        guard let user = currentUser, !replyText.isEmpty else { return }
        let reply = Reply(
            id: UUID().uuidString, commentId: commentId,
            userID: user.id,
            userName: user.username, userImageURL: user.userImageURL,
            text: replyText,
            photoURL: user.photoURL,
            timestamp: Date().timeIntervalSince1970
        )
        replyAction(reply)
        replyText = ""
        isReplying = false
    }

    private func fetchReplies() {
        let db = Firestore.firestore()
        db.collection("comments").document(commentId)
            .collection("replies")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                isLoading = false // Directly reference self
                if let error = error {
                    print("Error fetching replies: \(error.localizedDescription)")
                    return
                }

                var fetchedReplies: [Reply] = []
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let reply = Reply(from: data) {
                        fetchedReplies.append(reply)
                    }
                }
                self.replies = fetchedReplies
                self.mapRepliesToUsers()
            }
    }

    private func mapRepliesToUsers() {
        for index in replies.indices {
            if let userData = usersData[replies[index].userID] {
                replies[index].userName = userData.userName
                replies[index].photoURL = userData.photoURL
            }
        }
    }

    private func fetchAllUsersData() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            for document in snapshot?.documents ?? [] {
                let data = document.data()
                let userID = document.documentID
                let userName = data["username"] as? String ?? "Unknown User"
                let photoURL = data["photoURL"] as? String

                usersData[userID] = (userName: userName, photoURL: photoURL)
            }
            mapRepliesToUsers()
        }
    }
}
