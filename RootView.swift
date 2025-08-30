//
//  RootView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/30/25.
//
import SwiftUI

struct RootView: View {
    @State private var showSplash = true
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            if showSplash {
                FullscreenSplashVideo {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .ignoresSafeArea()
            } else {
                ContentView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
