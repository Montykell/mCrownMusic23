//
//  mCrownMusic23App.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/8/25.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth
import AVFoundation
import AppTrackingTransparency
import UserNotifications

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // ✅ Firebase
        FirebaseApp.configure()
        
        // ✅ Configure audio session
        setupAudioSession()
        
        // ✅ Request tracking authorization
        requestAppTrackingTransparency()
        
        // ✅ Register for push notifications
        registerForPushNotifications(application)
        
        return true
    }
    
    // MARK: - Audio Session
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
    
    // MARK: - Tracking Transparency
    private func requestAppTrackingTransparency() {
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized: print("✅ Tracking authorized")
                    case .denied: print("❌ Tracking denied")
                    case .restricted: print("🚫 Tracking restricted")
                    case .notDetermined: print("⚠️ Tracking not determined")
                    @unknown default: break
                    }
                }
            }
        }
    }
    
    // MARK: - Push Notifications
    private func registerForPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("Push Notification permission granted: \(granted)")
        }
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // ✅ Pass APNs token to Firebase Auth
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        print("✅ APNs token set for Firebase")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // ✅ Let Firebase handle auth notifications
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }
}

// MARK: - Main App Entry
@main
struct mCrownMusic23App: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}

