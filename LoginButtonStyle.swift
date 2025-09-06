//
//  LoginButtonStyle.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/26/25.
//

import SwiftUI

struct LoginButtonStyle: ButtonStyle {
    @Binding var isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color.brown)
                    .cornerRadius(10)
                    .shadow(radius: 4)
            } else {
                configuration.label
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 4)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            }
        }
    }
}
