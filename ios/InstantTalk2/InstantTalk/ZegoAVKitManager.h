//
//  ZegoAVKitManager.h
//  LiveDemo
//
//  Copyright © 2015年 Zego. All rights reserved.
//

#pragma once

#import <ZegoLiveRoom/ZegoLiveRoom.h>

@interface ZegoInstantTalk : NSObject

+ (ZegoLiveRoomApi *)api;
+ (void)releaseApi;

+ (void)setCustomAppID:(uint32_t)appid sign:(NSString *)sign;
+ (uint32_t)appID;

+ (void)setUsingTestEnv:(bool)testEnv;
+ (bool)usingTestEnv;

+ (bool)usingAlphaEnv;

+ (bool)usingExternalRender;

+ (void)setRequireHardwareAccelerated:(bool)hardwareAccelerated;
+ (bool)requireHardwareAccelerated;

@end

@interface ZegoInstantTalk (Alpha)
+ (void)setUsingAlphaEnv:(bool)alphaEnv;
@end
