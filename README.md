# SSAITracking SDK

## Requirement: IOS 12.4+ and Physical device

## Prepare for iOS 14+

Need request App Tracking Transparency authorization

To display the App Tracking Transparency authorization request for accessing the IDFA, update your `Info.plist` to add the `NSUserTrackingUsageDescription` key with a custom message describing your usage. Here is an example description text:

```
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

### I. Declare library SSAITracking in Podfile

```swift
pod 'SSAITracking', :git => 'https://github.com/sigmaott/sigma-ssai-ios.git', :tag => '1.0.39'
```

cd to your project and run

```swift
pod install
```

## Step 1: Initialize the SDK

Import SDK

```swift
import SSAITracking
```

Call **start** function when your app launch

```swift
SSAITracking.SigmaSSAI.start()
```

Example:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    SSAITracking.SigmaSSAI.start()
    return true
}
```

Initialize the SDK with the required parameters:

```swift
// Initialize the SDK
self.ssai = SSAITracking.SigmaSSAI.init(adsProxy, self, playerView)
```

### Parameter Definitions

* **`adsProxy`** : your ads proxy, responsible for handling ad requests and responses. Here is document for it [https://placid-skateboard-a71.notion.site/T-i-li-u-H-ng-d-n-S-d-ng-Endpoint-cspm-control-12f7a665ded5802696b6c156bae20576](https://placid-skateboard-a71.notion.site/T-i-li-u-H-ng-d-n-S-d-ng-Endpoint-cspm-control-12f7a665ded5802696b6c156bae20576)
* **`self`** : A reference to the current instance of your class, which must conform to the `SigmaSSAIInterface` protocol to handle callbacks.
* **`playerView`** : The view where the video player will be displayed.

## Step 2: Generate Video URL

Once the SDK is initialized, generate the video URL by calling the `generateUrl` method with the `videoUrl` parameter.

```swift
self.ssai?.generateUrl(videoUrl)
```

### Listening for Callbacks

After calling `generateUrl`, listen for callbacks from the SDK. The SDK will notify you whether the URL generation was successful or failed through the following methods:

1. **Success Callback** : If the video URL is generated successfully, you will receive a call to the `onGenerateVideoUrlSuccess` method. This is where you will call the `startPlayer` method.
2. **Failure Callback** : If there is an error generating the video URL, you will receive a call to the `onGenerateVideoUrlFail` method.

## Implementing the Interface

You must implement the `SigmaSSAIInterface` protocol in your class to handle the callbacks properly. Here’s an example implementation:

```swift
// Implement the success callback
    func onGenerateVideoUrlSuccess(_ videoUrl: String) {
       self.videoUrl = videoUrl
        // Call the playVideo method with the new video URL
        print("Generated video URL: \(videoUrl)")
       startPlayer()
    }
  
    // Implement the failure callback
    func onGenerateVideoUrlFail(_ message: String) {
        print("Failed to generate video URL: \(message)")
        // Handle the failure appropriately
    }
  
    // Implement the tracking callback if needed
    func onTracking(_ message: String) {
        print("Tracking message: \(message)")
        // Handle tracking message if needed
    }
   // Method to play video
    func startPlayer() {
        // Set up the AVPlayer with the new video URL
        let asset = AVAsset(url: URL(string: self.videoUrl)!)
        playerItem = AVPlayerItem(asset: asset)
  
        if videoPlayer == nil {
            // If videoPlayer is not initialized, create a new one
            videoPlayer = AVPlayer(playerItem: playerItem)
            self.ssai?.setPlayer(videoPlayer!)
        } else {
            // If videoPlayer already exists, replace the current item
            let newPlayerItem = AVPlayerItem(asset: asset)
            videoPlayer?.replaceCurrentItem(with: newPlayerItem)
            playerItem = newPlayerItem
  
            // Set the player in the SDK again after replacing the item
            self.ssai?.setPlayer(videoPlayer!)
        }

        // Start playing the video
        videoPlayer?.play()
    }
```

### Important Note

**Always remember to call `setPlayer` on the SDK after initializing the `AVPlayer` or replacing the current item. This ensures that the SDK is correctly aware of the active player and can manage ad tracking effectively.**

### Recommended Usage

When you need to clear the player, it’s recommended to use the `clear` method on the SDK `self.ssai?.clear()`. This ensures that the SDK is properly reset and can manage ad tracking effectively after clearing the player.

### Callbacks Description

* **`onGenerateVideoUrlSuccess(_ videoUrl: String)`** : This method is called when the video URL is successfully generated. Here, you call the `startPlayer` method with the new video URL.
* **`onGenerateVideoUrlFail(_ message: String)`** : This method is called when there is an error generating the video URL. Use the `message` parameter to display an error or log it.
* **`onTracking(_ message: String)`** : This method is called whenever there is a tracking message. You can use it to handle any tracking-related tasks.

## Conclusion

Following the above steps, you can successfully integrate and use the SSAI Tracking SDK in your application. Ensure you handle the success and failure callbacks to provide a seamless user experience.
