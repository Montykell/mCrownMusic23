//
//  mCrownMusic23App.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import GoogleMobileAds
import FirebaseCore
import AVFoundation
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Firebase
        FirebaseApp.configure()

        // Google Mobile Ads — MUST be here
        MobileAds.shared.start { status in
            print("✅ Google Mobile Ads SDK initialized")
        }

        // Audio session
        setupAudioSession()

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            print("✅ Audio session configured")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
}

@main
struct mCrownMusic23App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var videoViewModel = VideoViewModel(videoURL: URL(string: "https://www.example.com/sample.mp4")!)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(videoViewModel)
                .onAppear {
                    authViewModel.setupAuthStateListener()
                }
        }
    }
}
