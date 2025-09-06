//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct SectionView: View {
    var title: String
    var items: [SectionItem]
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.bottom, 5)
            
            ForEach(items) { item in
                SectionRow(item: item)
                    .padding(.bottom, 10)
                    .onTapGesture {
                        action()
                    }
            }
        }
        .padding()
        .background(Color.secondary)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct SectionRow: View {
    var item: SectionItem
    
    var body: some View {
        HStack {
            Image(systemName: "music.note")
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(10)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

struct ContentsView: View {
    // Example data
    let sectionItems = [
        SectionItem(title: "Song 1", subtitle: "Artist 1"),
        SectionItem(title: "Song 2", subtitle: "Artist 2"),
        SectionItem(title: "Song 3", subtitle: "Artist 3")
    ]
    
    var body: some View {
        SectionView(title: "Recent Songs", items: sectionItems) {
            // Action to perform when tapping on a row
            print("Tapped section item")
        }
        .padding()
    }
}

