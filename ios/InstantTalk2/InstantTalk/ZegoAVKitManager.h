//
//  ZegoAVKitManager.h
//  LiveDemo
//
//  Copyright © 2015年 Zego. All rights reserved.
//

#pragma once

#import <ZegoLiveRoom/ZegoLiveRoom.h>

typedef enum : NSUInteger {
    ZegoAppTypeCustom   = 0,    // 用户自定义
    ZegoAppTypeRTMP     = 1,    // RTMP版
    ZegoAppTypeUDP      = 2,    // UDP版
    ZegoAppTypeI18N     = 3,    // 国际版
} ZegoAppType;

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

+ (void)setAppType:(ZegoAppType)type;
+ (ZegoAppType)appType;

+ (NSData *)zegoAppSignFromServer;

@end

@interface ZegoInstantTalk (Alpha)
+ (void)setUsingAlphaEnv:(bool)alphaEnv;
@end
