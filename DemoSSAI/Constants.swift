//
//  Constants.swift
//  DemoSSAI
//
//  Created by Pham Hai on 14/10/2024.
//

import Foundation

struct Constants {
    // URL constants
    static let baseDomain = "https://cdn-lrm-test.sigma.video"
    static let adsEndpoint = "6fe7279e-fb9e-4da4-8cef-97044194448d"
    static let adsEndpointQuery = "sigma.dai.adsEndpoint=\(adsEndpoint)"
    static let drmUrl = "\(baseDomain)/manifest/origin04/scte35-av4s-sigma-drm/master.m3u8?\(adsEndpointQuery)"
    static let hlsSCTE35 = "\(baseDomain)/manifest/origin04/scte35-video-audio-clear/master.m3u8?\(adsEndpointQuery)"
    static let hlsTs2s = "\(baseDomain)/manifest/origin04/scte35-av2s-clear/master.m3u8?\(adsEndpointQuery)"
    static let hlsTs4s = "\(baseDomain)/manifest/origin04/scte35-av4s-clear/master.m3u8?\(adsEndpointQuery)&sigma.dai.userId=test_123"
    static let hlsTs6s = "\(baseDomain)/manifest/origin04/scte35-av6s-clear/master.m3u8?\(adsEndpointQuery)"
    static let ANTV = "http://live-on-v2-akm.akamaized.net/manifest/test_live/master.m3u8?\(adsEndpointQuery)"
    static let sourceTestStreamMux = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8?\(adsEndpointQuery)"
    static let sourceTestTearOfSteel = "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?\(adsEndpointQuery)"
//    static let playlist480Url = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av4s-clear/playlist_480.m3u8"
//    static let playlist360Url = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av4s-clear/playlist_360.m3u8"
    
    static let urls = [
        ["url": hlsSCTE35, "isLive": true, "name": "SCTE 35", "isDrm": false],
        ["url": hlsTs2s, "isLive": true, "name": "Hls 2s", "isDrm": false],
        ["url": hlsTs4s, "isLive": true, "name": "Hls 4s", "isDrm": false],
        ["url": hlsTs6s, "isLive": true, "name": "Hls 6s", "isDrm": false],
        ["url": drmUrl, "isLive": true, "name": "Link drm", "isDrm": true],
        ["url": ANTV, "isLive": true, "name": "ANTV", "isDrm": false],
        ["url": sourceTestStreamMux, "isLive": false, "name": "Vod", "isDrm": false],
        ["url": sourceTestTearOfSteel, "isLive": false, "name": "Tear of steel", "isDrm": false]
    ] as [[String: Any]]

    // API keys
    static let apiKey = "YOUR_API_KEY"

    // Notification names
    static let userLoggedInNotification = Notification.Name("UserLoggedIn")
    static let userLoggedOutNotification = Notification.Name("UserLoggedOut")

    // Other constants
    static let defaultTimeout: TimeInterval = 60.0
    static let maxRetries = 3
    //drm info
    static let drmScheme = "SIGMA_DRM"
    static let merchantId = "d5321abd-6676-4bc1-a39e-6bb763029e54"
    static let appId = "7444c496-67be-4998-8b29-82152668ba20"
    static let assetId = "123"
    static let host = "https://api.sigmadrm.com"
    static let baseUrl = ""
}
