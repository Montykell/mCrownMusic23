//
//  AdBannerView.swift
//  mCrownMusic23
//
//  Created by mCrown Music on 8/28/25.
//
import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    var adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner) // Use the SwiftPM API
        banner.adUnitID = adUnitID
        
        // Find the root view controller
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow })?.rootViewController {
            banner.rootViewController = rootVC
        }
        
        banner.load(Request()) // Load the ad
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // Nothing to update dynamically for now
    }
}
