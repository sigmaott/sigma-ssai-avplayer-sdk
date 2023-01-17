# SSAITracking SDK

## Requirement: IOS 12.4+

### I. Cài đặt

Thêm file SSAITracking.xcframework vào project.

Project -> app target -> General -> Embedded Binaries

![ssai_step_1](https://i.ibb.co/nR7v7H6/ssai-step-1.png)



![ssai_step_2](https://i.ibb.co/Hq13d4c/ssai-step-2.jpg)



![ssai_step_3](https://i.ibb.co/0QsP5r0/Screen-Shot-2023-01-17-at-13-40-40.png)



![ssai_step_4](https://i.ibb.co/Z6PW1zL/ssai-step-4.jpg)



### II. Sử dụng

1. Thêm SSAITracking sdk vào project (mục **I**).

2. Import SSAITracking vào file: 

   ```swift
   import SSAITracking
   ```

3. Tạo biến ssai type SigmaSSAI thể hiện cho view tương tác.

   ```swift
   var ssai: SigmaSSAI?;
   ```

   

4. Khởi tạo sdk

   ```swift
   self.ssai = SSAITracking.SigmaSSAI.init(source: sessionUrl, trackingUrl, self, intervalTimeTracking)
   ```

   sessionUrl: Link session (Bắt buộc có nếu muốn sdk thực hiện việc gọi và lấy link video, để trống nếu app tự thực hiện việc lấy link video)

   trackingUrl: Link tracking (Bắt buộc có nếu app thực hiện việc gọi link session và lấy link video, để trống nếu muốn  sdk thực hiện việc lấy link video)

   self: implement SigmaSSAIInterface (Để lắng nghe các sự kiện sdk SSAI gọi để thực hiện các logic nếu cần)

   intervalTimeTracking: Thời gian định kỳ sdk gọi tracking data (tính bằng giây)

   1. Nếu dùng sdk thực hiện việc gọi và lấy link video

   ​       1.1 - Lấy data url:  
            ```swift 
            self.ssai?.getDataUrl() - return Dictonary["videoUrl": videoUrl, "trackingUrl": trackingUrl] 
            ```

   ​       1.2 - Set player cho sdk:  **self**.ssai?.setPlayer(videoPlayer!) - set sau khi khởi tạo xong player

   2. Nếu app tự thực hiện việc gọi và lấy link video

      2.1 - **self**.ssai?.onStartPlay() - gọi khi player sẵn sàng play

      2.2 - self.ssai?.updatePlaybackTime(playbackTime: seconds) - gọi theo sự kiện update time play của player

5. Các hàm listener

     onSessionFail() - Khi sdk get data session fail

     onTracking(_ message: String) - Khi sdk gọi 1 ads tracking request

     onSessionUpdate(_ videoUrl: String) - Khi sdk cập nhật link video

6. Public method

   Clear() - Dùng để clear reset toàn bộ dữ liệu sdk

   

