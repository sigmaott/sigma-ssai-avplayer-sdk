//
//  SigmaDRM.h
//  SigmaDRM
//
//  Created by NguyenVanSao on 12/21/17.
//  Copyright © 2017 NguyenVanSao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAssetResourceLoader.h>
#import <AVFoundation/AVAsset.h>
@protocol SigmaDRMDelegate
@optional
-(void)onSigmaStatus:(NSInteger)status;
-(void)onProgressLoad:(NSString *)progressName status:(NSString *)error;
@end
@interface SigmaDRM : NSObject
{
    
}
@property(nonatomic, weak) id<SigmaDRMDelegate> delegate;
+(SigmaDRM *)getInstance;
-(AVURLAsset *)assetWithUrl:(NSString *)url;
-(AVURLAsset *)assset;
-(void)setMerchantId:(NSString *)merchantId;
-(NSString *)merchantId;
-(void)setAppId:(NSString *)appId;
-(NSString *)appId;
-(void)setUserUid:(NSString *)userId;
-(NSString *)userId;
-(void)setSessionId:(NSString *)sessionId;
-(NSString *)sessionId;
-(void)setAuthToken:(NSString *)token;
-(NSString *)authToken;
-(void)setDrmUrl:(NSArray *)drmList;
-(NSArray *)drmList;

-(void)logging:(NSString *)progress status:(NSString *)status;
@end
