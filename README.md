# SSAITracking SDK

## Requirement: IOS 12.4+

## Prepare for iOS 14+

Need request App Tracking Transparency authorization

To display the App Tracking Transparency authorization request for accessing the IDFA, update your `Info.plist` to add the `NSUserTrackingUsageDescription` key with a custom message describing your usage. Here is an example description text:

```
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

### I. Declare library SSAITracking in Podfile

```swift
pod 'SSAITracking', '1.0.19'
```

cd to your project and run

```swift
pod install
```

### II. Init SDK

Implement SigmaSSAIInterface (To listen for SSAI events call and execute app logic if needed)

```swift
class PlayerViewController: SigmaSSAIInterface
```

Init sdk

```swift
self.ssai = SSAITracking.SigmaSSAI.init(sessionUrl, self, playerView)
```

   ``sessionUrl``: Link session (get link video and link tracking)

   ``self``: Your class implement SigmaSSAIInterface

   ``playerView``: Player UIView

### III. How to use

1. Import SSAITracking:

   ```swift
   import SSAITracking
   ```
2. Create variable ssai type SigmaSSAI.

   ```swift
   var ssai: SigmaSSAI?;
   ```
3. Init sdk from **II** when view loaded

   ```swift
   override func viewDidLoad() {
           self.ssai = SSAITracking.SigmaSSAI.init(sessionUrl, self, playerView)
           //show or hide ssai log
           self.ssai?.setShowLog(true)
       }
   ```
4. Listen event **onSessionInitSuccess** to start player

```swift
func onSessionInitSuccess(_ videoUrl: String) {
        self.videoUrl = videoUrl
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
```

5. Call **setPlayer** after init player

```swift
func startPlayer() {
    let asset = AVURLAsset(url:videoUrl, options: nil);
    playerItem = AVPlayerItem(asset: asset)
    videoPlayer = AVPlayer(playerItem: playerItem)
    //set player for sdk
    self.ssai?.setPlayer(videoPlayer!)
}
```

6. List Listener functional to execute app logic if needed

   ``onSessionFail(_ message: String)`` - When sdk get data session fail (status code other than 200 or returns data with incorrect structure)

   ``onTracking(_ message: String)`` - When sdk make call 1 ads tracking request
7. Public method

   ``clear()`` - To remove all data sdk (call when change video url or session url or release player)
