//
//  NewsFeedItem.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

// MARK: - NewsFeedItem
struct NewsFeedItem: View {
    let update: Update
    let onLike: () -> Void
    let onDislike: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var comments: [Comment] = []
    
    private let db = Database.database().reference()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - User Info
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: update.photoURL ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(radius: 2)
                
                VStack(alignment: .leading) {
                    Text(update.username ?? "Unknown").bold()
                        .foregroundColor(.black)
                    Text(formattedDate(timestamp: update.timestamp))
                        .font(.caption)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                if update.userId == authViewModel.currentUser?.uid {
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            // MARK: - Post Text
            Text(update.description)
                .font(.body)
                .foregroundColor(.black)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // MARK: - Action Buttons
            HStack(spacing: 20) {
                ActionButton(
                    icon: "hand.thumbsup",
                    count: update.likeCount,
                    isActive: update.didLike(currentUserId: authViewModel.currentUser?.uid ?? ""),
                    action: onLike
                )
                
                ActionButton(
                    icon: "hand.thumbsdown",
                    count: update.dislikeCount,
                    isActive: update.didDislike(currentUserId: authViewModel.currentUser?.uid ?? ""),
                    action: onDislike
                )
                
                Spacer()
            }
            
            Divider().padding(.vertical, 4)
            
            // MARK: - Comments Section
            VStack(alignment: .leading, spacing: 8) {
                ForEach(comments) { comment in
                    CommentView(
                        comment: comment,
                        replyAction: { reply in saveReply(reply, to: comment) },
                        deleteCommentAction: { deleteComment(comment) },
                        deleteReplyAction: { reply in deleteReply(reply, from: comment) }
                    )
                    .environmentObject(authViewModel)
                }
                
                AddCommentView { text in
                    saveComment(text)
                }
            }
            
        }
        .padding()
        .background(LinearGradient(colors: [Color.white, Color(UIColor.systemGray6)], startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
        .onAppear { fetchComments() }
    }
    
    // MARK: - Firebase Actions
    private func fetchComments() {
        let commentsRef = db.child("updates").child(update.id).child("comments")
        
        commentsRef.observe(.value) { snapshot in
            var newComments: [Comment] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   var comment = Comment(from: dict) {
                    if let repliesDict = dict["replies"] as? [String: [String: Any]] {
                        comment.replies = repliesDict.compactMap { Reply(from: $0.value) }
                    }
                    newComments.append(comment)
                }
            }
            
            self.comments = newComments.sorted(by: { $0.timestamp < $1.timestamp })
        }
    }

    
    private func saveComment(_ text: String) {
        guard let currentUser = authViewModel.currentUser else { return }
        let commentId = db.childByAutoId().key ?? UUID().uuidString
        
        // 🔹 Fetch user info from Firestore `publicProfiles`
        Firestore.firestore().collection("publicProfiles").document(currentUser.uid).getDocument { snapshot, _ in
            let username = snapshot?.get("username") as? String ?? "Anonymous"
            let photoURL = snapshot?.get("profileImageURL") as? String ?? nil
            
            let commentData: [String: Any] = [
                "id": commentId,
                "postId": update.id,
                "userID": currentUser.uid,
                "userName": username,
                "userImageURL": photoURL ?? "",
                "text": text,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            db.child("updates").child(update.id).child("comments").child(commentId).setValue(commentData)
        }
    }

    
    private func saveReply(_ reply: Reply, to comment: Comment) {
        let replyData: [String: Any] = [
            "id": reply.id,
            "commentId": comment.id,
            "userID": reply.userID,
            "userName": reply.userName,
            "userImageURL": reply.userImageURL ?? "",
            "text": reply.text,
            "timestamp": reply.timestamp
        ]
        
        db.child("updates").child(update.id).child("comments").child(comment.id).child("replies").child(reply.id).setValue(replyData)
    }

    private func deleteComment(_ comment: Comment) {
        db.child("updates").child(update.id).child("comments").child(comment.id).removeValue()
    }
    
    private func deleteReply(_ reply: Reply, from comment: Comment) {
        db.child("updates").child(update.id).child("comments").child(comment.id).child("replies").child(reply.id).removeValue()
    }
    
    private func formattedDate(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Action Button View
struct ActionButton: View {
    let icon: String
    let count: Int
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: isActive ? "\(icon).fill" : icon)
                Text("\(count)")
            }
            .font(.subheadline)
            .foregroundColor(isActive ? .brown : .gray)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
