# SSAITracking SDK

## Requirement: IOS 12.4+

### I. Embed SSAITracking.xcframework and ProgrammaticAccessLibrary.xcframework in project’s target

Project -> app target -> General -> Embedded Binaries

![ssai_step_1](https://i.ibb.co/nR7v7H6/ssai-step-1.png)

![ssai_step_2](https://i.ibb.co/Hq13d4c/ssai-step-2.jpg)

![ssai_step_3](https://i.ibb.co/0QsP5r0/Screen-Shot-2023-01-17-at-13-40-40.png)

![ssai_step_4](https://i.ibb.co/Z6PW1zL/ssai-step-4.jpg)

To embed **ProgrammaticAccessLibrary.xcframework** do the same as **SSAITracking.xcframework**. When choosing a file, select **ProgrammaticAccessLibrary.xcframework**

![ssai_step_5](https://i.ibb.co/z4cCYw4/Screenshot-2024-08-14-at-16-44-33.png)

### II. Init SDK

```swift
   self.ssai = SSAITracking.SigmaSSAI.init(sessionUrl, self, playerView)
```

   ``sessionUrl``: Link session (get link video and link tracking)

   ``self``: Implement SigmaSSAIInterface (To listen for SSAI events call and execute app logic if needed)

   ``playerView``: Player UIView

### III. How to use

1. Embed SSAITracking.xcframework in project’s target (from **I**).
2. Import SSAITracking:

   ```swift
   import SSAITracking
   ```
3. Create variable ssai type SigmaSSAI.

   ```swift
   var ssai: SigmaSSAI?;
   ```
4. Listen event **onSessionInitSuccess** to start player

```swift
func onSessionInitSuccess(_ videoUrl: String) {
        self.videoUrl = videoUrl
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
```

5. List Listener functional to execute app logic if needed

   ``onSessionFail()`` - When sdk get data session fail

   ``onTracking(_ message: String)`` - When sdk make call 1 ads tracking request

   ``onSessionUpdate(_ videoUrl: String)`` - When sdk update link video
6. Public method

   ``clear()`` - To remove all data sdk
