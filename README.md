# SSAITracking SDK

## Requirement: IOS 12.4+

### I. Declare library SSAITracking in Podfile

```swift
pod 'SSAITracking', '1.0.7'
```

cd to your project and run

```swift
pod install
```

### II. Init SDK

```swift
self.ssai = SSAITracking.SigmaSSAI.init(sessionUrl, self, playerView)
```

   ``sessionUrl``: Link session (get link video and link tracking)

   ``self``: Implement SigmaSSAIInterface (To listen for SSAI events call and execute app logic if needed)

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
3. Listen event **onSessionInitSuccess** to start player

```swift
func onSessionInitSuccess(_ videoUrl: String) {
        self.videoUrl = videoUrl
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
```

4. List Listener functional to execute app logic if needed

   ``onSessionFail()`` - When sdk get data session fail

   ``onTracking(_ message: String)`` - When sdk make call 1 ads tracking request

   ``onSessionUpdate(_ videoUrl: String)`` - When sdk update link video
5. Public method

   ``clear()`` - To remove all data sdk
