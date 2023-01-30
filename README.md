# SSAITracking SDK

## Requirement: IOS 12.4+

### I. Embed SSAITracking.xcframework in project’s target

Project -> app target -> General -> Embedded Binaries

![ssai_step_1](https://i.ibb.co/nR7v7H6/ssai-step-1.png)



![ssai_step_2](https://i.ibb.co/Hq13d4c/ssai-step-2.jpg)



![ssai_step_3](https://i.ibb.co/0QsP5r0/Screen-Shot-2023-01-17-at-13-40-40.png)



![ssai_step_4](https://i.ibb.co/Z6PW1zL/ssai-step-4.jpg)

### II. Init SDK

   ```swift
   self.ssai = SSAITracking.SigmaSSAI.init(source: sessionUrl, trackingUrl, self, intervalTimeTracking)
   ```

   ```sessionUrl```: Link session (Required if you want sdk makes call and get link video, set empty if app makes the call and get link video)

   ```trackingUrl```: Link tracking (Required if app make call link session and get link video, set empty if you want sdk make call and get link video)

   ```self```: Implement SigmaSSAIInterface (To listen for SSAI events call and execute app logic if needed)

   ```intervalTimeTracking```: Interval time sdk calls tracking data (in seconds)

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

4. Init sdk
    - Follow section ***II*** and call the functions below
   1. If using sdk to make calls and get video links (required)

      1.1 - Get data url:  ```self.ssai?.getDataUrl() - return Dictonary["videoUrl": videoUrl, "trackingUrl": trackingUrl]```

      1.2 - Set player for sdk:  ```self.ssai?.setPlayer(videoPlayer!)``` - set after init player

   2. If the app itself makes the call and gets the video link (required)

      2.1 - ```self.ssai?.onStartPlay()``` - Call when player ready to play

      2.2 - ```self.ssai?.updatePlaybackTime(playbackTime: seconds)``` - Call on player's time play update event

5. Listener functional

     ```onSessionFail()``` - When sdk get data session fail

     ```onTracking(_ message: String)``` - When sdk make call 1 ads tracking request

     ```onSessionUpdate(_ videoUrl: String)``` - When sdk update link video

6. Public method

   ```clear()``` - To remove all data sdk

   

