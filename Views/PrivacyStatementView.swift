//
//  ContentView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI

struct PrivacyStatementView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Statement for mCrownMusic App")
                    .font(.title)
                    .bold()
                
                Text("Effective Date: 8-27-2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Introduction")
                    .font(.headline)
                Text("Welcome to mCrownMusic, a platform that allows users to create profiles to interact with our content, including music streaming, podcasts, and livestreams. Your privacy is important to us. This Privacy Statement outlines how we collect, use, and protect your information when you use our app.")
                
                Text("Information We Collect")
                    .font(.headline)
                Text("1. Personal Information\n   When you create a profile, we may collect personal information, including:\n   - Name\n   - Email address\n   - Profile picture\n   - Username\n   - Any other information you choose to provide\n\n2. Usage Data\n   We collect information about how you use our app, including:\n   - Listening history\n   - Interaction with content (likes, shares, comments)\n   - Device information (device type, operating system, etc.)\n   - IP address\n\n3. Cookies and Tracking Technologies\n   We use cookies and similar tracking technologies to enhance your experience. This includes:\n   - Remembering your preferences\n   - Analyzing user behavior to improve our services")
                
                Text("How We Use Your Information")
                    .font(.headline)
                Text("We may use the information we collect for the following purposes:\n- To Provide and Maintain Our Services\n- To Personalize Your Experience\n- To Communicate with You\n- To Improve Our Services\n- To Ensure Security")
                
                Text("Sharing Your Information")
                    .font(.headline)
                Text("We do not sell or rent your personal information to third parties. We may share your information in the following circumstances:\n- With Your Consent\n- With Service Providers\n- For Legal Reasons")
                
                Text("Data Security")
                    .font(.headline)
                Text("We take reasonable measures to protect your information from unauthorized access, use, or disclosure. However, please remember that no method of transmission over the internet or electronic storage is 100% secure.")
                
                Text("Your Rights")
                    .font(.headline)
                Text("You have the following rights regarding your personal information:\n- Access\n- Correction\n- Deletion\n- Opt-Out")
                
                Text("Changes to This Privacy Statement")
                    .font(.headline)
                Text("We may update this Privacy Statement from time to time. Any changes will be effective upon posting the updated statement within the app. We encourage you to review this statement periodically for the latest information on our privacy practices.")
                
                Text("Contact Us")
                    .font(.headline)
                Text("If you have any questions or concerns about this Privacy Statement or our privacy practices, please contact us at:\n- Email: support@mcrownmusic.com\n- Address: 213 Second St. Morven NC, 28119")
            }
            .padding()
        }
        .navigationTitle("Privacy Statement")
    }
}

struct PrivacyStatementView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyStatementView()
    }
}
