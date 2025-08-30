//
//  SplashVideoView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/30/25.
//

import SwiftUI
import AVKit

struct FullscreenSplashVideo: UIViewControllerRepresentable {
    var videoName: String = "mcrownmusic"
    var videoExtension: String = "MP4"
    var onFinished: () -> Void // Closure to notify SwiftUI

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .black

        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            print("❌ Video not found!")
            DispatchQueue.main.async { self.onFinished() }
            return controller
        }

        let player = AVPlayer(url: url)
        player.isMuted = false
        player.volume = 0.5            

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = UIScreen.main.bounds
        playerLayer.videoGravity = .resizeAspectFill
        controller.view.layer.addSublayer(playerLayer)

        player.play()

        // Observe video finished
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            DispatchQueue.main.async { self.onFinished() }
        }

        // Add tap gesture to skip video
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        controller.view.addGestureRecognizer(tapGesture)
        context.coordinator.onFinished = onFinished
        context.coordinator.player = player

        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var onFinished: (() -> Void)?
        var player: AVPlayer?

        @objc func handleTap() {
            player?.pause()
            DispatchQueue.main.async {
                self.onFinished?()
            }
        }
    }
}

