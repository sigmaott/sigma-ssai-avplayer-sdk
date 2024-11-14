# SSAITracking SDK Integration Guide

 **Version**: 1.0.0

**Organization**: Thủ Đô Multimedia

## Table of Contents

1. [Introduction](#1-introduction)
2. [Scope](#1-scope)
3. [System Requirements](#3-system-requirements)
4. [SDK Installation](#4-sdk-installation)
5. [SDK Integration](#5-sdk-installation)
   * 5.1 [SDK Initialization](#51-sdk-initialization)
   * 5.2 [Generating Video URL](#52-generating-video-url)
   * 5.3 [Listening for Callbacks](#53-listening-for-callbacks)
6. [Important Notes](#6-important-notes)
7. [Callback Descriptions](#7-callback-descriptions)
8. [Conclusion](#8-conclusion)
9. [References](#9-references)

## 1. Introduction

This document provides a guide for integrating and using the SSAITracking SDK for iOS applications, specifically for iOS version 12.4 and above. It includes detailed information on installation, SDK initialization, and handling necessary callbacks.

## 2. Scope

This document applies to iOS developers who want to integrate the SSAITracking SDK into their applications, including requesting IDFA access as per App Tracking Transparency requirements.

## 3. System Requirements

* **Operating System**: iOS 12.4 and above
* **Device**: Physical device required
* **Additional Requirement**: App Tracking Transparency authorization needed **on ios 14+**

## 4. SDK Installation

To install the SSAITracking SDK, follow these steps:

1. **Update Info.plist**:
   Add the `NSUserTrackingUsageDescription` key with a custom message describing the usage of IDFA:

```swift
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

2. **Declare the library in Podfile**:

```swift
pod 'SSAITracking', :git => 'https://github.com/sigmaott/sigma-ssai-ios.git', :tag => '1.0.0'
```

3. **Run the installation command**:

```swift
cd [path to your project]
pod install
```

## 5. SDK Integration

### 5.1 SDK Initialization

* **Import the SDK**:

```swift
import SSAITracking
```

* **Call the start function when your application launches**:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      SSAITracking.SigmaSSAI.start()
      return true
  }
```

* **Initialize the SDK with the required parameters**:

```swift
self.ssai = SSAITracking.SigmaSSAI.init(adsEndpoint, self, playerView)
```

### Parameter Definitions

* **`adsEndpoint`**: Your ads endpoint. Here is document for it [https://placid-skateboard-a71.notion.site/T-i-li-u-H-ng-d-n-S-d-ng-Endpoint-cspm-control-12f7a665ded5802696b6c156bae20576
  ](https://placid-skateboard-a71.notion.site/T-i-li-u-H-ng-d-n-S-d-ng-Endpoint-cspm-control-12f7a665ded5802696b6c156bae20576)
* **`self`**: A reference to the current instance of your class, which must conform to the `SigmaSSAIInterface` protocol to handle callbacks.
* **`playerView`**: The view where the video player will be displayed.

### 5.2 Generating Video URL

Once the SDK is initialized, generate the video URL by calling the `generateUrl` method with the `videoUrl` parameter:

```swift
self.ssai?.generateUrl(videoUrl)
```

### 5.3 Listening for Callbacks

After calling `generateUrl`, listen for callbacks from the SDK:

* **Success Callback**:
  When the video URL is successfully generated, the `onGenerateVideoUrlSuccess` method will be called.
* **Failure Callback**:
  If there is an error generating the video URL, the `onGenerateVideoUrlFail` method will be invoked.

## 6. Important Notes

Always remember to call `setPlayer` on the SDK after initializing the `AVPlayer` or replacing the current item. This ensures that the SDK correctly recognizes the active video player and can effectively manage ad tracking. If you need to change the `adsEndpoint`, it is essential to reinitialize the SDK. This ensures that the new endpoint is properly configured and used for tracking.

## 7. Callback Descriptions

* `onGenerateVideoUrlSuccess(_ videoUrl: String)`: Called when the video URL is successfully generated.
* `onGenerateVideoUrlFail(_ message: String)`: Called when there is an error in generating the video URL.
* `onTracking(_ message: String)`: Called whenever there is a tracking message.

## 8. Conclusion

By following the steps outlined above, you can successfully integrate and utilize the SSAITracking SDK within your application. Ensure that you handle both success and failure callbacks to provide a seamless user experience.

## 9. References

* SSAITracking demo link: [Demo Link](https://github.com/sigmaott/sigma-ssai-avplayer-sdk)
