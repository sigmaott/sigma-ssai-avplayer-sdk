//
//  Constants.swift
//  DemoSSAI
//
//  Created by Pham Hai on 14/10/2024.
//

import Foundation

struct Constants {
    // URL constants
//    static let masterUrl = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av4s-clear/master.m3u8"
//    static let hlsTs2s = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av2s-clear/master.m3u8"
    static let hlsTs4s = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av4s-clear/master.m3u8"
    static let hlsTs6s = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av6s-clear/master.m3u8"
    static let sourceTestStreamMux = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
//    static let playlist480Url = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av4s-clear/playlist_480.m3u8"
//    static let playlist360Url = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av4s-clear/playlist_360.m3u8"
    
    static let urls = [
//        ["url": hlsTs2s, "isLive": true, "name": "Hls 2s"],
        ["url": hlsTs4s, "isLive": true, "name": "Hls 4s"],
        ["url": hlsTs6s, "isLive": true, "name": "Hls 6s"],
        ["url": sourceTestStreamMux, "isLive": false, "name": "Vod"]
    ] as [[String: Any]]

    // API keys
    static let apiKey = "YOUR_API_KEY"

    // Notification names
    static let userLoggedInNotification = Notification.Name("UserLoggedIn")
    static let userLoggedOutNotification = Notification.Name("UserLoggedOut")

    // Other constants
    static let defaultTimeout: TimeInterval = 60.0
    static let maxRetries = 3
}
