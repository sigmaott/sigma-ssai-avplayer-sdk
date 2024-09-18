//
//  PlayerViewController.swift
//  DemoSigmaInteractive
//
//  Created by PhamHai on 31/03/2022.
//

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height-100, width: self.view.frame.size.width, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }

import Foundation
import UIKit
import AVFoundation
import AVKit
import SSAITracking

class PlayerViewController: UIViewController, SigmaSSAIInterface, AVAssetResourceLoaderDelegate, AVPlayerItemMetadataCollectorPushDelegate {
    
    var videoUrl: String = "";
    var fullScreenAnimationDuration: TimeInterval {
        return 0.15
    }
    let widthDevice = UIScreen.main.bounds.width;
    let heightDevice = UIScreen.main.bounds.height;
    let keyTimedMetadata = "timedMetadata";
    let readyForDisplayKeyPath = "readyForDisplay";
    var playerItem: AVPlayerItem?;
    var topSafeArea = 0.0
    var bottomSafeArea = 0.0
    var layer: AVPlayerLayer = AVPlayerLayer();
    var ssai: SigmaSSAI?;
    var sessionUrl = "";
    //change to false if not use sdk ssai cover
    //change time interval tracking
    var playBackTime = 0.0
    private var videoPlayer: AVPlayer?
    
    @IBOutlet weak var playerView: UIView!

    var items: [String] = []
    var labels: [UILabel] = [] // Keep track of UILabels
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        //
    }
    //event when session fail
    func onSessionFail(_ message: String) {
        print("onSessionFailSSAI=>\(message)")
    }
    
    func onSessionInitSuccess(_ videoUrl: String) {
        print("onSessionInitSuccess=>", videoUrl)
        self.videoUrl = videoUrl
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
    
    func onTracking(_ message: String) {
        self.showToast(message: message, font: .systemFont(ofSize: 12.0))
    }
    
    override func viewDidLoad() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        self.ssai = SSAITracking.SigmaSSAI.init(sessionUrl, self, playerView)
        //show or hide ssai log
        self.ssai?.setShowLog(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("Player viewWillDisappear", animated);
        stopBtnPressed(UIButton())
        super.viewWillDisappear(animated);
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")	
        AppUtility.lockOrientation(.portrait)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("viewWillTransition=>")
        super.viewWillTransition(to: size, with: coordinator);
        if UIDevice.current.orientation.isLandscape {
            if #available(iOS 11.0, *) {
                topSafeArea = view.safeAreaInsets.top
                bottomSafeArea = view.safeAreaInsets.bottom
            } else {
                topSafeArea = topLayoutGuide.length
                bottomSafeArea = bottomLayoutGuide.length
            }
            print("Landscape=>",topSafeArea, bottomSafeArea);
            goFullscreen()
        } else {
            print("Portrait")
            minimizeToFrame()
        }
    }
    func minimizeToFrame() {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            let heightVideo = self.widthDevice * (9/16);
            self.layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: self.widthDevice, height: heightVideo)
            self.layer.videoGravity = .resizeAspectFill;
        }
    }

    func goFullscreen() {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            print("widthDevice=>", self.widthDevice, self.heightDevice)
            let widthVideo = self.widthDevice * (16/9);
            self.layer.frame = CGRect(x: (self.heightDevice - widthVideo) / 2, y: 0, width: widthVideo, height: self.widthDevice)
            self.layer.videoGravity = .resizeAspectFill
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer, player == videoPlayer, keyPath == "status" {
            if player.status == .readyToPlay {
                if let duration = player.currentItem?.duration {
                    let seconds = CMTimeGetSeconds(duration)
                    print("Seconds :: \(seconds)")
                }
                videoPlayer?.play()
                let heightVideo = self.widthDevice * (9/16);
                self.layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: self.widthDevice, height: heightVideo)
                self.layer.videoGravity = .resizeAspectFill;
            } else if player.status == .failed {
                stopBtnPressed(UIButton())
            }
        }
    }
    private func startPlayer() {
        if let url = URL(string: videoUrl) {
            let asset = AVURLAsset(url: url, options: nil);
            playerItem = AVPlayerItem(asset: asset)
            videoPlayer = AVPlayer(playerItem: playerItem)
            self.ssai?.setPlayer(videoPlayer!)
            videoPlayer?.addObserver(self, forKeyPath: "status", options: [], context: nil)
            // listen the current time of playing video
            videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: Double(0.5), preferredTimescale: 2), queue: DispatchQueue.main) { [weak self] (sec) in
                guard let self = self else { return }
                let seconds = CMTimeGetSeconds(sec)
                if let duration = self.playerItem?.duration {
                    let seconds = CMTimeGetSeconds(duration)
                }
                playBackTime = self.videoPlayer?.currentTime() != nil ? CMTimeGetSeconds((self.videoPlayer?.currentTime())!) : 0
            }
            videoPlayer?.volume = 1.0
            
            layer = AVPlayerLayer(player: videoPlayer);
            layer.backgroundColor = UIColor.white.cgColor
            let heightVideo = widthDevice * (9/16);
            layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: widthDevice, height: heightVideo)
            layer.videoGravity = .resizeAspectFill
            playerView.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
            playerView.layer.addSublayer(layer)
        }
    }
    
    func stopBtnPressed(_ sender: Any) {
        videoUrl = ""
        self.ssai?.clear()
        videoPlayer?.pause()
        videoPlayer = nil
        playerView.layer.sublayers?
            .filter { $0 is AVPlayerLayer }
            .forEach { $0.removeFromSuperlayer() }
        playerView.backgroundColor = .black
        self.title = ""
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
