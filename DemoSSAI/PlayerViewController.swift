//
//  PlayerViewController.swift
//  DemoSigmaInteractive
//
//  Created by PhamHai on 31/03/2022.
//

extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: 15, y: self.view.frame.size.height - 300, width: self.view.frame.size.width - 30, height: 45))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

protocol PickerModalDelegate: AnyObject {
    func didSelectItem(_ index: Int, _ isProfile: Bool)
}


import Foundation
import UIKit
import AVFoundation
import AVKit
import SSAITracking

class PlayerViewController: UIViewController, SigmaSSAIInterface, AVAssetResourceLoaderDelegate, AVPlayerItemMetadataCollectorPushDelegate, PickerModalDelegate {
    
    var itemIndex: Int = -1;
    var profileIndex: Int = -1;
    var videoUrl: String = "";
    var adsProxy: String = "";
    var listProfile:[[String: String]] = []
    var changeSourceNeedReset: Bool = false;
    var changeButton: UIButton!
    var changeProfileButton: UIButton!

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
    var isLive = true
    private var videoPlayer: AVPlayer?
    var selectedLabel: UILabel!

    @IBOutlet weak var playerView: UIView!
    let playPauseButton = UIButton(type: .system)
    var pickerSourceView: PickerModalViewController!
    var pickerProfileView: PickerModalProfile!
    
    func didSelectItem(_ index: Int, _ isProfile: Bool) {
        if(isProfile) {
            profileIndex = index
            videoUrl = listProfile[index]["url"]!
            changeCurrentItemPlayer()
            setTitleButtonProfile()
        } else {
            profileIndex = -1
            if(itemIndex != index) {
                itemIndex = index
                changeVideoUrlWithIndex(index)
            }
        }
    }
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        //
    }
    //event when session fail
    func onSessionFail(_ message: String) {
        print("onSessionFailSSAI=>\(message)")
    }
    
    func onSessionInitSuccess() {
        print("onSessionInitSuccess=>", videoUrl)
        if(profileIndex == -1) {
            fetchM3u8Url()
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
    
    func onTracking(_ message: String) {
        self.showToast(message: message, font: .systemFont(ofSize: 12.0))
    }
    
    override func viewDidLoad() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        self.ssai = SSAITracking.SigmaSSAI.init(videoUrl, adsProxy, self, playerView)
        //show or hide ssai log
        self.ssai?.setShowLog(true)
        setupPlayPauseButton()
        // Create the button
        changeButton = UIButton(type: .system)
        setTitleButton()
        changeButton.addTarget(self, action: #selector(openPickerModal), for: .touchUpInside)
        
        // Set button frame (or use Auto Layout)
//        button.frame = CGRect(x: 30, y: 100, width: 500, height: 50)// Set background color
        changeButton.backgroundColor = UIColor.gray
        changeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        // Set corner radius
        changeButton.layer.cornerRadius = 10
        changeButton.clipsToBounds = true // Ensure the corner radius is applied
        
        // Set title color for better visibility
        changeButton.setTitleColor(.white, for: .normal)
        
        // Add the button to the view
        view.addSubview(changeButton)
        changeButton.translatesAutoresizingMaskIntoConstraints = false

        //profile button
        
        changeProfileButton = UIButton(type: .system)
        setTitleButtonProfile()
        changeProfileButton.addTarget(self, action: #selector(openPickerProfileModal), for: .touchUpInside)
        
        // Set button frame (or use Auto Layout)
//        button.frame = CGRect(x: 30, y: 100, width: 500, height: 50)// Set background color
        changeProfileButton.backgroundColor = UIColor.gray
        changeProfileButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        // Set corner radius
        changeProfileButton.layer.cornerRadius = 10
        changeProfileButton.clipsToBounds = true // Ensure the corner radius is applied
        
        // Set title color for better visibility
        changeProfileButton.setTitleColor(.white, for: .normal)
        
        changeProfileButton.isHidden = true
        // Add the button to the view
        view.addSubview(changeProfileButton)
        changeProfileButton.translatesAutoresizingMaskIntoConstraints = false
        //end profile button
        NSLayoutConstraint.activate([
            changeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Center horizontally
            changeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100), // Set the top position
            changeButton.heightAnchor.constraint(equalToConstant: 50), // Set a fixed heightntally
            changeProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Center horizontally
            changeProfileButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 170), // Set the top position
            changeProfileButton.heightAnchor.constraint(equalToConstant: 50) // Set a fixed height
        ])
    }
    func fetchM3u8Url() {
        //
        Task {
            do {
                let content = try await Helper.fetchM3U8Content(from: videoUrl)
                print("Fetched .m3u8 content:")
                print(content)

                // Define the base URL for constructing playlist links
                let baseURL = Helper.getBaseURL(from: videoUrl)
                print("baseURL==>", baseURL)
                // Extract playlist URLs
                listProfile = Helper.extractPlaylistURLs(from: content, baseURL: baseURL)
                print("\nExtracted Playlist URLs:")
                print("listProfile=>", listProfile)
                if listProfile.isEmpty {
                    changeProfileButton.isHidden = true
                } else {
                    changeProfileButton.isHidden = false
                    if let pickerProfileView = pickerProfileView {
                        pickerProfileView.setData(listProfile)
                    }
                }
            } catch {
                print("Failed to fetch .m3u8 content: \(error)")
            }
        }
    }
    @objc func openPickerModal() {
        if pickerSourceView == nil {
            pickerSourceView = PickerModalViewController()
            pickerSourceView?.modalPresentationStyle = .formSheet
            pickerSourceView?.delegate = self
        } else {
            pickerSourceView.changeItem(itemIndex)
        }
        pickerSourceView.selectedIndexPure = itemIndex
        pickerSourceView.selectedIndex = itemIndex
        pickerSourceView.selectedItem = Constants.urls[itemIndex]
        present(pickerSourceView, animated: true, completion: nil)
    }
    
    @objc func openPickerProfileModal() {
        if pickerProfileView == nil {
            pickerProfileView = PickerModalProfile(data: listProfile, selectedIndex: 0)
            pickerProfileView?.modalPresentationStyle = .formSheet
            pickerProfileView?.delegate = self
        } else {
            if(profileIndex != -1) {
                pickerProfileView.selectedIndex = profileIndex
                pickerProfileView.selectedItem = listProfile[profileIndex]
            }
            pickerProfileView.changeItem(itemIndex)
        }
        present(pickerProfileView, animated: true, completion: nil)
    }
    
    @objc func closeModal() {
        dismiss(animated: true, completion: nil)
    }
    private func setupPlayPauseButton() {
        playPauseButton.setTitle("Pause", for: .normal)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add button to your view
        view.addSubview(playPauseButton)
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
    @objc func togglePlayPause() {
        if videoPlayer?.timeControlStatus == .playing {
            videoPlayer?.pause()
            playPauseButton.setTitle("Play", for: .normal)
        } else {
            videoPlayer?.play()
            playPauseButton.setTitle("Pause", for: .normal)
        }
    }
    @objc func changeSessionUrl() {
        let nextIndex = itemIndex == Constants.urls.count - 1 ? 0 : itemIndex + 1
        if(nextIndex != -1) {
            changeVideoUrlWithIndex(nextIndex)
        }
    }
    func setTitleButton() {
        let nextItem = Constants.urls[itemIndex]
        let name = (nextItem["name"] as? String)!
        changeButton.setTitle("Change source (\(name))", for: .normal)
    }
    func setTitleButtonProfile() {
        changeProfileButton.setTitle("Select profile (\(profileIndex != -1 ? listProfile[profileIndex]["name"]! : "Auto"))", for: .normal)
    }
    func changeVideoUrlWithIndex(_ index: Int) {
        stopBtnPressed(UIButton())
        if(index >= 0) {
            let nextItem = Constants.urls[index]
            isLive = (nextItem["isLive"] as? Bool)!
            videoUrl = (nextItem["url"] as? String)!
            itemIndex = index
            setTitleButton()
            if videoPlayer != nil && !changeSourceNeedReset {
                changeCurrentItemPlayer()
            } else {
                self.ssai = SSAITracking.SigmaSSAI.init(videoUrl, adsProxy, self, playerView)
                self.ssai?.setShowLog(true)
            }
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
    func changeCurrentItemPlayer() {
        print("changeCurrentItemPlayer=>", videoUrl)
        if let url = URL(string: videoUrl) {
            self.ssai?.setVideoUrl(videoUrl)
            let asset = isLive ? self.ssai?.getAsset() ?? AVURLAsset(url: url) : AVURLAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            videoPlayer?.replaceCurrentItem(with: playerItem)
            videoPlayer?.play()
        }
    }
    private func startPlayer() {
        print("start player ", videoUrl)
        if let url = URL(string: videoUrl) {
            // Use the asset from your SSAI if applicable
            let asset = isLive ? self.ssai?.getAsset() ?? AVURLAsset(url: url) : AVURLAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            videoPlayer = AVPlayer(playerItem: playerItem)
            self.ssai?.setPlayer(videoPlayer!)
            videoPlayer?.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
            // Observe playback time
            videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: DispatchQueue.main) { [weak self] time in
                guard let self = self else { return }
                let playbackTime = CMTimeGetSeconds(time)
                // Update your playback time variable here
                self.playBackTime = playbackTime
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
        if(changeSourceNeedReset) {
            self.ssai?.clear()
            videoPlayer?.pause()
            videoPlayer = nil
            self.ssai = nil
            playerView.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
            playerView.backgroundColor = .black
        }
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
