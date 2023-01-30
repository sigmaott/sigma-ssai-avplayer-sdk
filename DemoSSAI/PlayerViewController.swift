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

class PlayerViewController: UIViewController, SigmaSSAIInterface, AVPlayerItemMetadataOutputPushDelegate, AVAssetResourceLoaderDelegate, AVPlayerItemMetadataCollectorPushDelegate {
    
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
    var fullTrackingUrl = ""
    //change to false if not use sdk ssai cover
    let useSSAICover = false
    //change time interval tracking
    let intervalTimeTracking = 10.0
    private var videoPlayer: AVPlayer?
    
    @IBOutlet weak var playerView: UIView!
    
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        //
    }
    
    //event when session fail
    func onSessionFail() {
        print("onSessionFailSSAI=>onSessionFail")
        DispatchQueue.main.sync {
            stopBtnPressed(UIButton())
        }
        self.ssai?.clear()
        getVideoAndTrackingUrl()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
    
    func onSessionInitSuccess(_ videoUrl: String) {
        print("onSessionInitSuccess=>", videoUrl)
//        self.videoUrl = videoUrl
//        startPlayer();
    }
    
    func onTracking(_ message: String) {
        self.showToast(message: message, font: .systemFont(ofSize: 12.0))

//        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//            switch action.style{
//                case .default:
//                print("default")
//
//                case .cancel:
//                print("cancel")
//
//                case .destructive:
//                print("destructive")
//
//            }
//        }))
//        self.present(alert, animated: true, completion: nil)
    }
    
    func onSessionUpdate(_ videoUrl: String) {
        stopBtnPressed(UIButton())
        print("onSessionUpdate=>")
        print("onSessionUpdate=>", videoUrl)
        self.videoUrl = videoUrl
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
    func getVideoAndTrackingUrl() {
        let dataSession = makeHttpRequestSync(address: sessionUrl)
        let url = URL(string: sessionUrl)
        let sessionScheme = url?.scheme!
        let sessionDomain = url?.host!
        var sessionPort:String = ""
        if let port = url?.port {
            sessionPort = String(port)
        }
        let trackingUrl:String = dataSession["trackingUrl"] as! String
        let manifestUrl:String = dataSession["manifestUrl"] as! String
        let isFullPath = manifestUrl.hasPrefix("http")
        let isAbsolutePath = manifestUrl.hasPrefix("/")
        let isRelativePath = manifestUrl.hasPrefix(".")
        let baseURL = sessionScheme! + "://" + sessionDomain! + (!sessionPort.isEmpty ? ":" + sessionPort : "")
        if(isFullPath) {
            videoUrl = manifestUrl
            fullTrackingUrl = trackingUrl
            self.ssai = SSAITracking.SigmaSSAI.init(source: "", fullTrackingUrl, self, intervalTimeTracking)
        }
        if(isAbsolutePath) {
            videoUrl = baseURL + manifestUrl
            fullTrackingUrl = baseURL + trackingUrl
            self.ssai = SSAITracking.SigmaSSAI.init(source: "", fullTrackingUrl, self, intervalTimeTracking)
        }
        if(isRelativePath) {
            videoUrl = URL(string: manifestUrl, relativeTo: URL(string: sessionUrl))!.absoluteString
            fullTrackingUrl = URL(string: trackingUrl, relativeTo: URL(string: sessionUrl))!.absoluteString
            self.ssai = SSAITracking.SigmaSSAI.init(source: "", fullTrackingUrl, self, intervalTimeTracking)
        }
    }
    
    override func viewDidLoad() {
        print("videoUrl=>", videoUrl);
        super.viewDidLoad()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        if(useSSAICover) {
            //init sdk
            self.ssai = SSAITracking.SigmaSSAI.init(source: sessionUrl, "", self, intervalTimeTracking)
            let dataUrl:Dictionary = self.ssai?.getDataUrl() as! Dictionary<String, String>
            self.videoUrl = dataUrl["videoUrl"]!
            startPlayer()
            //call init data
//            self.ssai?.getInitData()
        } else {
            getVideoAndTrackingUrl()
            startPlayer();
        }
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
//                    self.ssai = SSAI_Tracking.SigmaSSAI.init(source: "", player: videoPlayer!)
                }
                if(!useSSAICover) {
                    self.ssai?.onStartPlay()
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
    
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        let items = groups.first?.items;
        for item in items! {
            let value: String = item.value as! String;
            let key: String = item.key! as! String;
            print("metadataOutput=>id:", key);
        }
    }
    private func startPlayer() {
        if let url = URL(string: videoUrl) {
            let asset = AVURLAsset(url: url, options: nil);
            playerItem = AVPlayerItem(asset: asset)
            videoPlayer = AVPlayer(playerItem: playerItem)
            if(useSSAICover) {
                self.ssai?.setPlayer(videoPlayer!)
            }
            videoPlayer?.addObserver(self, forKeyPath: "status", options: [], context: nil)
            // listen the current time of playing video
            videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: Double(1), preferredTimescale: 2), queue: DispatchQueue.main) { [weak self] (sec) in
                guard let self = self else { return }
                let seconds = CMTimeGetSeconds(sec)
                print("second=>", seconds)
                if(!self.useSSAICover) {
                    self.ssai?.updatePlaybackTime(playbackTime: seconds)
                }
                if let duration = self.playerItem?.duration {
                    let seconds = CMTimeGetSeconds(duration)
                    print("second=>: \(seconds)")
                }
                var count = 0.0;
                NSLog("total player duration: %.2f", count);
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
            let metadataOutput = AVPlayerItemMetadataOutput();
            metadataOutput.advanceIntervalForDelegateInvocation = TimeInterval(Int.max);
            metadataOutput.setDelegate(self, queue: DispatchQueue.main);
            playerItem!.add(metadataOutput);
            playerItem?.addObserver(self, forKeyPath: keyTimedMetadata, options: [], context: nil)
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
    
    func makeHttpRequestSync(address: String) -> Dictionary<String, Any> {
        let url = URL(string: address)
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: String = ""
        var dataReturn: Dictionary = [String: Any]()
        
        let task = URLSession.shared.dataTask(with: url!) { [self](data, response, error) in
            result = String(data: data!, encoding: String.Encoding.utf8)!
            dataReturn = convertToDictionary(text: result)!
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        print("dataReturn=>", dataReturn)
        return dataReturn
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
