//
//  NewsFeedItem.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI

struct NewsFeedItem: View {
    let update: Update
    let onLike: () -> Void
    let onDislike: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: - User info
            HStack(spacing: 10) {
                if let photoURL = update.photoURL, let url = URL(string: photoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 40, height: 40)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        case .failure(_):
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                
                Text(update.username ?? "Unknown")
                    .font(.headline)
            }
            
            // MARK: - Post description
            Text(update.description)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // MARK: - Actions
            HStack(spacing: 20) {
                
                // Like button (always visible)
                HStack(spacing: 4) {
                    Button(action: onLike) {
                        Image(systemName: update.didLike(currentUserId: authViewModel.currentUser?.uid ?? "")
                              ? "hand.thumbsup.fill"
                              : "hand.thumbsup")
                    }
                    .disabled(update.userId == authViewModel.currentUser?.uid) // disable own post
                    Text("\(update.likeCount)")
                }
                
                // Dislike button (always visible)
                HStack(spacing: 4) {
                    Button(action: onDislike) {
                        Image(systemName: update.didDislike(currentUserId: authViewModel.currentUser?.uid ?? "")
                              ? "hand.thumbsdown.fill"
                              : "hand.thumbsdown")
                    }
                    .disabled(update.userId == authViewModel.currentUser?.uid) // disable own post
                    Text("\(update.dislikeCount)")
                }
                
                Spacer()
                
                Text(formattedDate(timestamp: update.timestamp))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                // Delete button (only for own post)
                if update.userId == authViewModel.currentUser?.uid {
                    Button(action: onDelete) {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .padding(.horizontal)
    }
    
    private func formattedDate(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
