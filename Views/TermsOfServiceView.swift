//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)

                Text("These Terms of Service (\"Terms\") govern your use of the mCrown Music app (\"the App\"). By accessing or using the App, you agree to these Terms. If you do not agree to these Terms, please do not use the App.")

                Text("1. Use of the App")
                    .font(.headline)
                Text("1.1 License: We grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes related to music streaming and media content.")
                Text("1.2 Restrictions: You agree not to:")
                Text("• Modify, adapt, translate, or create derivative works of the App.")
                Text("• Reverse engineer, decompile, disassemble, or attempt to extract the source code of the App.")
                Text("• Use the App for any unlawful or unauthorized purposes, including infringing on third-party rights or violating applicable laws and regulations.")
                Text("• Attempt to interfere with or disrupt the integrity of the App.")
                Text("1.3 Updates: We may provide updates or upgrades to the App from time to time. These updates may include new features, bug fixes, or changes required for continued use of the App.")
                
                Text("2. User Accounts")
                    .font(.headline)
                Text("2.1 Registration: To access certain features of the App, including personalized music streaming, you may be required to register an account. You agree to provide accurate and complete information during registration.")
                Text("2.2 Account Security: You are responsible for maintaining the confidentiality of your account credentials and are responsible for all activities that occur under your account. You agree to notify us immediately of any unauthorized use or security breach.")

                Text("3. Privacy")
                    .font(.headline)
                Text("3.1 Data Collection: Your use of the App is subject to our Privacy Policy, which explains how we collect, use, and protect your information. By using the App, you consent to the data practices described in the Privacy Policy.")

                Text("4. Content and Intellectual Property")
                    .font(.headline)
                Text("4.1 Ownership: The App, including all music, media, and intellectual property contained within it, is owned by us or our licensors. You agree that you do not acquire any ownership rights by using the App.")
                Text("4.2 User-Generated Content: If you submit or share content (such as comments or reviews) through the App, you grant us a worldwide, non-exclusive, royalty-free license to use, reproduce, and distribute your content in connection with the App.")

                Text("5. Limitation of Liability")
                    .font(.headline)
                Text("5.1 Disclaimer: We provide the App \"as is\" without any warranties, express or implied. We do not guarantee that the App will be error-free, uninterrupted, or available at all times.")
                Text("5.2 Limitation of Liability: To the extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to lost profits, arising out of or in connection with your use of the App.")

                Text("6. Termination")
                    .font(.headline)
                Text("6.1 Termination by Us: We reserve the right to suspend or terminate your access to the App at any time for any reason, including breach of these Terms.")
                Text("6.2 Termination by You: You may stop using the App at any time and delete your account to terminate these Terms.")

                Text("7. Governing Law")
                    .font(.headline)
                Text("7.1 Jurisdiction: These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law principles.")

                Text("8. Miscellaneous")
                    .font(.headline)
                Text("8.1 Entire Agreement: These Terms constitute the entire agreement between you and us regarding the use of the App and supersede any prior agreements or communications.")
                Text("8.2 Changes to Terms: We reserve the right to modify these Terms at any time by posting the revised version on the App or our website. Continued use of the App after any modifications indicates your acceptance of the updated Terms.")
                Text("8.3 Contact Information: If you have any questions about these Terms, please contact us at support@mcrownmusic.com.")
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}
