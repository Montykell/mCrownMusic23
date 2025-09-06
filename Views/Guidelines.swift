//
//  Guidelines.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 9/1/25.
//

import SwiftUI

struct GuidelinesView: View {
    @Environment(\.dismiss) private var dismiss

    private let intro = """
    Welcome to mCrownMusic! The official home of Olso’s music, podcasts, livestreams, and reality TV. This is the only place to experience it all, and we want to keep the community positive, safe, and respectful.
    """

    private let sections: [GuidelinesSectionModel] = [
        .init(
            title: "1. Respect in the Community",
            bullets: [
                "Treat Olso and other fans with respect. No hate speech, bullying, harassment, or threats.",
                "Respect differences in opinion. Debates are fine, but insults are not."
            ]
        ),
        .init(
            title: "2. Interacting in Chats & Livestreams",
            bullets: [
                "No spamming, trolling, or flooding the chat with repeated messages.",
                "Keep conversations relevant to the livestream or content being discussed.",
                "Support is encouraged; negativity that tears others down isn’t."
            ]
        ),
        .init(
            title: "3. Protecting the Brand",
            bullets: [
                "Do not attempt to copy, record, or redistribute music, videos, podcasts, or livestreams outside the app.",
                "No pirating, screen recording, or re-uploading of mCrownMusic content anywhere else."
            ]
        ),
        .init(
            title: "4. Safety & Privacy",
            bullets: [
                "Don’t share private information about yourself or others.",
                "Impersonating Olso, the label, or other fans is not allowed."
            ]
        ),
        .init(
            title: "5. Commercial Activity",
            bullets: [
                "No selling, promoting, or advertising products/services without approval from mCrownMusic.",
                "Scams, fraud, or financial schemes will be banned immediately."
            ]
        ),
        .init(
            title: "6. Consequences",
            bullets: [
                "Violations may result in removal from chats, suspension, or permanent ban from the app.",
                "Severe violations (piracy, threats, illegal activity) will be reported to the proper authorities."
            ]
        ),
        .init(
            title: "7. The Spirit of mCrownMusic",
            bullets: [
                "This platform is built to connect fans directly with Olso — no middleman. Be respectful, enjoy the content, and contribute to a community that uplifts each other."
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("mCrownMusic Community Standards")
                        .font(.title2).bold()
                        .multilineTextAlignment(.center)

                    Text(intro)
                        .foregroundStyle(.secondary)

                    Divider()

                    ForEach(sections) { section in
                        GuidelinesSection(section: section)
                    }
                }
                .padding()
            }
            .navigationTitle("Community Guidelines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct GuidelinesSectionModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let bullets: [String]
}

struct GuidelinesSection: View {  // <— renamed from SectionView
    let section: GuidelinesSectionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .font(.headline).fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(section.bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(bullet).foregroundStyle(.secondary)
                    }
                    .font(.body)
                }
            }
        }
    }
}

#Preview { GuidelinesView() }
