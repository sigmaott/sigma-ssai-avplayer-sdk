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
    let periodicTime = 1.0
    var timeStartPlay = 0
    var countLoadingShow = 0
    var lastPlaybackTimePlayer = 0.0
    var isLive = true
    var isDrm = false
    var timeObserverToken: Any?
    var pilotEnable = false
    var resetSessionWhenChangeProfile = false
    var autoRotate = false
    private var videoPlayer: AVPlayer?
    var selectedLabel: UILabel!
    private var orientationTimer: Timer?

    let activityIndicator = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var playerView: UIView!
    let playPauseButton = UIButton(type: .system)
    let playbackTimeLabel = UILabel()
    var pickerSourceView: PickerModalViewController!
    var pickerProfileView: PickerModalProfile!
    
    func didSelectItem(_ index: Int, _ isProfile: Bool) {
        if(isProfile) {
            profileIndex = index
            let itemProfile = listProfile[index]
            videoUrl = itemProfile["url"]!
            if let isAuto = itemProfile["isAuto"] {
                if(isAuto == "true") {
                    profileIndex = -1
                }
            }
            if changeSourceNeedReset {
                clearPlayer()
                setupSSAI()
            } else {
                changeCurrentItemPlayer(false)
            }
        } else {
            profileIndex = -1
            if(itemIndex != index) {
                itemIndex = index
                changeVideoUrlWithIndex(index)
            }
        }
        setTitleButtonProfile()
    }
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        //
    }
    func setupSSAI() {
        self.ssai = SSAITracking.SigmaSSAI.init(adsProxy, self, playerView)
        //show or hide ssai log
        self.ssai?.setShowLog(true)
        self.ssai?.generateUrl(videoUrl)
    }
    func onGenerateVideoUrlFail(_ message: String) {
        print("onGenerateVideoUrlFail=>\(message)")
    }
    func onGenerateVideoUrlSuccess(_ videoUrl: String) {
        self.videoUrl = videoUrl
        print("---Clear player onGenerateVideoUrlSuccess---", videoUrl, self.ssai)
        if(profileIndex == -1) {
            fetchM3u8Url()
        }
        if videoPlayer == nil {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
            startPlayer();
        } else {
            if changeSourceNeedReset {
                startPlayer()
            } else {
                if let asset = getAssetWrapper() {
                    let newPlayerItem = AVPlayerItem(asset: asset)
                    videoPlayer?.replaceCurrentItem(with: newPlayerItem)
                    addPeriodicTimeObserver()
                    self.playBackTime = 0
                    playerItem = newPlayerItem
                    videoPlayer?.play()
                    self.ssai?.setPlayer(videoPlayer!)
                }
            }
        }
    }
    
    func onTracking(_ message: String) {
        self.showToast(message: message, font: .systemFont(ofSize: 12.0))
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        setDrmInfo()
        setupActivityIndicator()
        activityIndicator.startAnimating()
        setupSSAI()
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
    
    @objc private func appDidBecomeActive(_ gesture: UITapGestureRecognizer) {
        self.videoPlayer?.play()
    }
    @objc private func appDidEnterBackground(_ gesture: UITapGestureRecognizer) {
        self.videoPlayer?.pause()
    }
    func setupActivityIndicator() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .red
        view.addSubview(activityIndicator)
    }
    func setDrmInfo() {
        #if !targetEnvironment(simulator)
            if isDrm {
                SigmaDRM.getInstance().setAppId(Constants.appId)
                SigmaDRM.getInstance().setMerchantId(Constants.merchantId)
                SigmaDRM.getInstance().setUserUid("234")
                SigmaDRM.getInstance().setDrmUrl([])
                SigmaDRM.getInstance().setSessionId("1234")
            }
        #endif
    }
    private func startOrientationTimer() {
        // Khóa hướng ban đầu là ngang
        setOrientation(.portrait)
        orientationTimer?.invalidate()
        
        // Thiết lập Timer để thay đổi hướng sau 10 giây
        orientationTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.toggleOrientation()
        }
    }

    private func toggleOrientation() {
        print("toggleOrientation", UIDevice.current.orientation.isLandscape, UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)
        if (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)! {
            setOrientation(.portrait)
        } else {
            setOrientation(.landscapeLeft)
        }
    }
    private func setOrientation(_ orientation: UIInterfaceOrientation) {
        // Ensure the app is running on iOS 16 or later
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
            // Specify the interface orientations based on the requested orientation
            let orientationMask: UIInterfaceOrientationMask = {
                switch orientation {
                case .landscapeLeft, .landscapeRight:
                    return .landscape
                case .portrait, .portraitUpsideDown:
                    return .portrait
                default:
                    return .all
                }
            }()
            
            // Request the geometry update
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationMask))
        } else {
            // Fallback for iOS versions lower than 16
            // Note: You should not be using this for iOS 16 and later
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }



    // Khóa hướng theo chiều ngang và dọc
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }

    deinit {
        orientationTimer?.invalidate()
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
                listProfile = Helper.extractPlaylistURLs(from: content, baseURL: baseURL, videoUrl: videoUrl)
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
        var finalIndex = profileIndex
        if pickerProfileView == nil {
            pickerProfileView = PickerModalProfile(data: listProfile, selectedIndex: 0)
            pickerProfileView?.modalPresentationStyle = .formSheet
            pickerProfileView?.delegate = self
        } else {
            if(profileIndex != -1) {
                pickerProfileView.selectedIndex = profileIndex
                pickerProfileView.selectedItem = listProfile[profileIndex]
                pickerProfileView.pickerView.selectRow(profileIndex, inComponent: 0, animated: false)
            } else if listProfile.count > 0 {
                let keyToFind = "isAuto"
                let valueToMatch = "true"
                if let index = listProfile.firstIndex(where: { $0[keyToFind] == valueToMatch }) {
                    pickerProfileView.selectedIndex = index
                    pickerProfileView.selectedItem = listProfile[index]
                    pickerProfileView.pickerView.selectRow(index, inComponent: 0, animated: false)
                    finalIndex = index
                } else {
                    profileIndex = -1
                    finalIndex = -1
                    pickerProfileView.changeItem(itemIndex)
                    print("No item found with \(keyToFind) == \(valueToMatch)")
                }
            }
            pickerProfileView.changeItem(finalIndex)
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
        playPauseButton.backgroundColor = UIColor.white
        playPauseButton.layer.cornerRadius = 10
        playPauseButton.clipsToBounds = true
        playPauseButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        view.addSubview(playPauseButton)
        playbackTimeLabel.numberOfLines = 0
        setPlaybackTimeText(0)
        playbackTimeLabel.textColor = .white
        playbackTimeLabel.textAlignment = .center
        playbackTimeLabel.backgroundColor = .black
        playbackTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playbackTimeLabel)
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            playbackTimeLabel.centerXAnchor.constraint(equalTo: playPauseButton.centerXAnchor),
            playbackTimeLabel.bottomAnchor.constraint(equalTo: playPauseButton.topAnchor, constant: -8),
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
        clearPlayer()
        if(index >= 0) {
            let nextItem = Constants.urls[index]
            isLive = (nextItem["isLive"] as? Bool)!
            isDrm = (nextItem["isDrm"] as? Bool)!
            videoUrl = (nextItem["url"] as? String)!
            itemIndex = index
            setTitleButton()
            setDrmInfo()
            if videoPlayer != nil && !changeSourceNeedReset {
                changeCurrentItemPlayer(true)
            } else {
                setupSSAI()
            }
        }
    }
    
    func changeCurrentItemPlayer(_ needReset: Bool) {
        print("changeCurrentItemPlayer=>", videoUrl)
        if let url = URL(string: videoUrl) {
            self.ssai?.generateUrl(videoUrl)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("Player viewWillDisappear", animated);
        destroyPlayer(UIButton())
        super.viewWillDisappear(animated);
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        AppUtility.lockOrientation(.portrait)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)! {
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
        print("observeValueKeyPath=>", keyPath)
        if let player = object as? AVPlayer, player == videoPlayer, keyPath == "status" {
            if player.status == .readyToPlay {
                print("readyToPlay==>")
                if let duration = player.currentItem?.duration {
                    let seconds = CMTimeGetSeconds(duration)
                    print("Seconds :: \(seconds)")
                }
                countLoadingShow = 0
                activityIndicator.stopAnimating()
                videoPlayer?.play()
                let heightVideo = self.widthDevice * (9/16);
                self.layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: self.widthDevice, height: heightVideo)
                self.layer.videoGravity = .resizeAspectFill;
            } else if player.status == .failed {
                print("observeValue==>Failed")
                destroyPlayer(UIButton())
            }
        }
        if keyPath == "timeControlStatus" {
            if videoPlayer?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    print("Player is waiting to play")
                    activityIndicator.startAnimating() // Show loading indicator
                    countLoadingShow += 1
                } else {
                    print("Player is playing or paused")
                    activityIndicator.stopAnimating() // Hide loading indicator
                }
            }
    }
    func setPlaybackTimeText(_ time: Double) {
        playbackTimeLabel.text = "Reset player: \(changeSourceNeedReset),Reset session: \(resetSessionWhenChangeProfile)\nLoading: \(countLoadingShow)\n\(Helper.formatPlaybackTime(timeStartPlay > 0 ? Double(Int(Date().timeIntervalSince1970) - timeStartPlay) : 0))"
    }
    func getAssetWrapper() -> AVURLAsset? {
        print("getAssetWrapper=>", videoUrl)
        if autoRotate {
            startOrientationTimer()
        }
        if let url = URL(string: videoUrl) {
            //SigmaDRM not support simulator
            #if !targetEnvironment(simulator)
            let asset = isDrm ? SigmaDRM.getInstance().asset(withUrl: videoUrl) : self.ssai?.getAsset()
                if asset != nil {
                    return asset
                } else {
                    return AVURLAsset(url: url)
                }
            #else
                return AVURLAsset(url: url)
            #endif
        } else {
            return nil
        }
    }
    
    func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            videoPlayer?.removeTimeObserver(token)
            timeObserverToken = nil // Clear the token
        }
    }
    func addPeriodicTimeObserver() {
        // Add the periodic time observer
        timeObserverToken = videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: periodicTime, preferredTimescale: 600), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            let playbackTime = CMTimeGetSeconds(time)
            // Update your playback time variable here
            print("playbackTime=>", self.playBackTime, playbackTime)
            if(self.playBackTime == 0) {
                timeStartPlay = Int(Date().timeIntervalSince1970)
            }
            if(lastPlaybackTimePlayer != playbackTime) {
                self.playBackTime += periodicTime
            }
            lastPlaybackTimePlayer = playbackTime
            setPlaybackTimeText(self.playBackTime)
        }
    }
    private func startPlayer() {
        print("startPlayer=>", self.ssai != nil ? "inited" : "nil")
        if let asset = getAssetWrapper() {
            playerItem = AVPlayerItem(asset: asset)
            videoPlayer = AVPlayer(playerItem: playerItem)
            self.ssai?.setPlayer(videoPlayer!)
            videoPlayer?.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
            videoPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: nil)
            // Observe playback time
            addPeriodicTimeObserver()
            self.playBackTime = 0
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

    
    func clearPlayer() {
        if(changeSourceNeedReset) {
            self.ssai?.clear()
            self.ssai = nil
            print("---Clear player---")
            removePeriodicTimeObserver()
            videoPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
            videoPlayer?.removeObserver(self, forKeyPath: "status")
            videoPlayer?.pause()
            videoPlayer = nil
            playerView.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
            playerView.backgroundColor = .black
        }
        self.playBackTime = 0
        self.title = ""
    }
    
    func destroyPlayer(_ sender: Any) {
        print("---Destroy player---")
        self.ssai?.clear()
        removePeriodicTimeObserver()
        videoPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
        videoPlayer?.removeObserver(self, forKeyPath: "status")
        removePeriodicTimeObserver()
        videoPlayer?.pause()
        videoPlayer = nil
        self.ssai = nil
        self.playBackTime = 0
        self.videoUrl = ""
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
