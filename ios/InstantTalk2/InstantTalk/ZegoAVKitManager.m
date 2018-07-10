//
//  ZegoAVKitManager.m
//  LiveDemo
//
//  Copyright © 2015年 Zego. All rights reserved.
//

#include "ZegoAVKitManager.h"
#import "./advanced/video_capture_external_demo.h"
#import "./advanced/ZegoVideoCaptureFromImage.h"
#import "ZegoSettings.h"
#import "ZegoDataCenter.h"

#import <ZegoLiveRoom/ZegoLiveRoomApi-Publisher.h>

#define ZEGO_TEST_RTP3

NSString *kZegoDemoAppTypeKey          = @"apptype";
NSString *kZegoDemoAppIDKey            = @"appid";
NSString *kZegoDemoAppSignKey          = @"appsign";

static ZegoLiveRoomApi *g_ZegoApi = nil;

// Demo 默认版本为 UDP
ZegoAppType g_appType = ZegoAppTypeUDP;

BOOL g_useTestEnv = NO;
BOOL g_useAlphaEnv = NO;

#if TARGET_OS_SIMULATOR
BOOL g_requireHardwareAccelerated = NO;
#else
BOOL g_requireHardwareAccelerated = YES;
#endif

BOOL g_enableVideoRateControl = NO;
BOOL g_useInternationDomain = NO;


static Byte toByte(NSString* c);
static NSData* ConvertStringToSign(NSString* strSign);

@interface ZegoInstantTalk ()

+ (void)setupVideoCaptureDevice;


@end

@implementation ZegoInstantTalk

+ (ZegoLiveRoomApi *)api
{
    if (g_ZegoApi == nil)
    {
        
        // 国际版
        if (g_appType == ZegoAppTypeI18N) {
            g_useInternationDomain = YES;
        } else {
            g_useInternationDomain = NO;
        }
        
        [ZegoLiveRoomApi setUseTestEnv:g_useTestEnv];
        
#ifdef DEBUG
        [ZegoLiveRoomApi setVerbose:YES];
#endif
        
        [ZegoLiveRoomApi setUserID:[ZegoSettings sharedInstance].userID userName:[ZegoSettings sharedInstance].userName];
        [ZegoLiveRoomApi setBusinessType:2];
        [ZegoLiveRoomApi setUseChatRoom:YES];
        
        [self setupVideoCaptureDevice];
        
        uint32_t appID = [self appID];
        if (appID > 0) {    // 手动输入为空的情况下容错
            NSData *appSign = [self zegoAppSignFromServer];
            if (appSign) {
                g_ZegoApi = [[ZegoLiveRoomApi alloc] initWithAppID:appID appSignature:appSign];
            }
        }
        
        if (g_appType == ZegoAppTypeUDP || g_appType == ZegoAppTypeI18N) {
            [g_ZegoApi setLatencyMode:ZEGOAPI_LATENCY_MODE_LOW];
            [g_ZegoApi enableTrafficControl:YES properties:ZEGOAPI_TRAFFIC_FPS | ZEGOAPI_TRAFFIC_RESOLUTION];
        }
        
        [self setupHardwareAcceleratedAndRateControl];
    }
    
    return g_ZegoApi;
}

+ (void)releaseApi
{
    [[ZegoDataCenter sharedInstance] leaveRoom];
    
    g_ZegoApi = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RoomInstanceClear" object:nil userInfo:nil];
}

+ (void)setCustomAppID:(uint32_t)appid sign:(NSString *)sign
{
    NSData *d = ConvertStringToSign(sign);
    
    if (d.length == 32 && appid != 0)
    {
        // 本地持久化
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@(appid) forKey:kZegoDemoAppIDKey];
        [ud setObject:sign forKey:kZegoDemoAppSignKey];
        
        [self releaseApi];
    }
}

//!! Please contact ZEGO support to get the AppID and signKey
//!! 请开发者联系 ZEGO support 获取 APPID 与 key
+ (uint32_t)appID
{
    switch ([self appType]) {
        case ZegoAppTypeCustom:
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            uint32_t appID = [[ud objectForKey:kZegoDemoAppIDKey] unsignedIntValue];
            
            if (appID != 0) {
                return appID;
            } else {
                return 0;
            }
        }
            break;
        case ZegoAppTypeUDP:
            return 10;  // UDP版
            break;
        case ZegoAppTypeI18N:
            return 100;  // 国际版
            break;
    }
}

//!! Please contact ZEGO support to get the AppID and signKey
//!! 请开发者联系 ZEGO support 获取 APPID 与 key
//!! 规范用法：这个signKey需要从server下发到App，避免在App中存储，防止盗用
+ (NSData *)zegoAppSignFromServer
{
    ZegoAppType type = [self appType];
    
    if (type == ZegoAppTypeUDP)
    {
        Byte signkey[] = {};
        return [NSData dataWithBytes:signkey length:32];
    }
    else if (type == ZegoAppTypeI18N)
    {
        Byte signkey[] = {};
        return [NSData dataWithBytes:signkey length:32];
    }
    else
    {
        // 自定义模式下从本地持久化文件中加载
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *appSign = [ud objectForKey:kZegoDemoAppSignKey];
        if (appSign) {
            return ConvertStringToSign(appSign);
        } else {
            return nil;
        }
    }
}

+ (NSString *)customAppSign {
    ZegoAppType type = [self appType];
    
    if (type == ZegoAppTypeCustom) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *appSign = [ud objectForKey:kZegoDemoAppSignKey];
        return appSign;
    } else {
        return nil;
    }
}

+ (void)setUsingTestEnv:(bool)testEnv
{
    if (g_useTestEnv != testEnv)
    {
        [self releaseApi];
    }
    
    g_useTestEnv = testEnv;
    [ZegoLiveRoomApi setUseTestEnv:testEnv];
}

+ (bool)usingTestEnv
{
    return g_useTestEnv;
}

+ (bool)usingAlphaEnv
{
    return g_useAlphaEnv;
}

+ (bool)usingExternalRender
{
    return false;
}

+ (void)setRequireHardwareAccelerated:(bool)hardwareAccelerated
{
    g_requireHardwareAccelerated = hardwareAccelerated;
    [self setupHardwareAcceleratedAndRateControl];
}

+ (bool)requireHardwareAccelerated
{
    return g_requireHardwareAccelerated;
}

+ (void)setAppType:(ZegoAppType)type {
    if (g_appType == type)
        return;
    
    // 本地持久化
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:type forKey:kZegoDemoAppTypeKey];
    
    g_appType = type;
    
//    [self releaseApi];
    
    // 临时兼容 SDK 的 Bug，立即初始化 api 对象
//    if ([self api] == nil) {
//        [self api];
//    }
}

+ (ZegoAppType)appType {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSUInteger type = [ud integerForKey:kZegoDemoAppTypeKey];
    g_appType = (ZegoAppType)type;
    return (ZegoAppType)type;
}

#pragma mark - private

+ (void)setupVideoCaptureDevice
{
#if TARGET_OS_SIMULATOR
    static __strong id<ZegoVideoCaptureFactory> g_factory = nullptr;
    if (g_factory == nullptr) {
        g_factory = [[ZegoVideoCaptureFactory alloc] init];
        [ZegoLiveRoomApi setVideoCaptureFactory:g_factory];
    }
#else
    /*
     // try VideoCaptureFactoryDemo for camera
     static __strong id<ZegoVideoCaptureFactory> g_factory = nullptr;
     if (g_factory == nullptr)
     {
     g_factory = [[VideoCaptureFactoryDemo alloc] init];
     [ZegoLiveApi setVideoCaptureFactory:g_factory];
     }
     */
#endif
}

+ (void)setupHardwareAcceleratedAndRateControl
{
    [ZegoLiveRoomApi requireHardwareDecoder:g_requireHardwareAccelerated];
    [g_ZegoApi enableRateControl:g_enableVideoRateControl];

#ifdef ZEGO_TEST_RTP3
    // * rtp 不使用硬编
    [ZegoLiveRoomApi requireHardwareEncoder:false];
#else
    if (g_enableVideoRateControl)
    {
        // * 流控不使用硬编
        [ZegoLiveRoomApi requireHardwareEncoder:false];
    }
    else
    {
        [ZegoLiveRoomApi requireHardwareEncoder:g_requireHardwareAccelerated];
    }
#endif
}

@end

Byte toByte(NSString* c)
{
    NSString *str = @"0123456789abcdef";
    Byte b = [str rangeOfString:c].location;
    return b;
}

NSData* ConvertStringToSign(NSString* strSign)
{
    if(strSign == nil || strSign.length == 0)
        return nil;
    strSign = [strSign lowercaseString];
    strSign = [strSign stringByReplacingOccurrencesOfString:@" " withString:@""];
    strSign = [strSign stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSArray* szStr = [strSign componentsSeparatedByString:@","];
    int nLen = (int)[szStr count];
    Byte szSign[32];
    for(int i = 0; i < nLen; i++)
    {
        NSString *strTmp = [szStr objectAtIndex:i];
        if(strTmp.length == 1)
            szSign[i] = toByte(strTmp);
        else
        {
            szSign[i] = toByte([strTmp substringWithRange:NSMakeRange(0, 1)]) << 4 | toByte([strTmp substringWithRange:NSMakeRange(1, 1)]);
        }
        NSLog(@"%x,", szSign[i]);
    }
    
    NSData *sign = [NSData dataWithBytes:szSign length:32];
    return sign;
}

#pragma mark - alpha support

@interface NSObject()
// * suppress warning
+ (void)setUseAlphaEnv:(id)useAlphaEnv;
@end

@implementation ZegoInstantTalk (Alpha)

+ (void)setUsingAlphaEnv:(bool)alphaEnv
{
    if ([ZegoLiveRoomApi respondsToSelector:@selector(setUseAlphaEnv:)])
    {
        if (g_useAlphaEnv != alphaEnv)
        {
            [self releaseApi];
        }
        
        g_useAlphaEnv = alphaEnv;
        [ZegoLiveRoomApi performSelector:@selector(setUseAlphaEnv:) withObject:@(alphaEnv)];
    }
}

@end
