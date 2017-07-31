//
//  ZegoSettings.m
//  LiveDemo3
//
//  Created by Strong on 16/6/22.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoSettings.h"

#include <string>

NSString *kZegoDemoUserIDKey            = @"userid";
NSString *kZegoDemoUserNameKey          = @"username";
NSString *kZegoDemoChannelIDKey         = @"channelid";
NSString *kZegoDemoVideoPresetKey       = @"preset";
NSString *kZegoDemoVideoResolutionKey   = @"resolution";
NSString *kZegoDemoVideoFrameRateKey    = @"framerate";
NSString *kZegoDemoVideoBitRateKey      = @"bitrate";

NSString *kZegoDemoPublishingStreamID   = @"streamID";   ///< 当前直播流 ID
NSString *kZegoDemoPublishingLiveID     = @"liveID";        ///< 当前直播频道 ID

NSString *kZeogDemoBeautifyFeatureKey = @"beautify_feature";
NSString *kZegoDemoVideoWitdhKey        = @"resolution-width";
NSString *kZegoDemoVideoHeightKey       = @"resolution-height";

@implementation ZegoSettings
{
    NSString *_userID;
    NSString *_userName;
    int _beautifyFeature;
}

+ (instancetype)sharedInstance {
    static ZegoSettings *s_instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [self new];
    });
    
    return s_instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _presetVideoQualityList = @[NSLocalizedString(@"超低质量", nil),
                                    NSLocalizedString(@"低质量", nil),
                                    NSLocalizedString(@"标准质量", nil),
                                    NSLocalizedString(@"高质量", nil),
                                    NSLocalizedString(@"超高质量", nil),
                                    NSLocalizedString(@"自定义", nil)];
        
        _appTypeList = @[NSLocalizedString(@"UDP版", nil),
                         NSLocalizedString(@"RTMP版", nil),
                         NSLocalizedString(@"国际版", nil),
                         NSLocalizedString(@"自定义", nil)];
        
        [self loadConfig];
    }
    
    return self;
}

- (ZegoUser *)getZegoUser
{
    ZegoUser *user = [ZegoUser new];
    user.userId = [ZegoSettings sharedInstance].userID;
    user.userName = [ZegoSettings sharedInstance].userName;
    
    return user;
}


- (NSString *)userID {
    if (_userID.length == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *userID = [ud stringForKey:kZegoDemoUserIDKey];
        if (userID.length > 0) {
            _userID = userID;
        } else {
            srand((unsigned)time(0));
            _userID = [NSString stringWithFormat:@"%u", (unsigned)rand()];
            [ud setObject:_userID forKey:kZegoDemoUserIDKey];
        }
    }
    
    return _userID;
}


- (void)setUserID:(NSString *)userID {
    if ([_userID isEqualToString:userID]) {
        return;
    }
    
    if (userID.length > 0) {
        _userID = userID;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:_userID forKey:kZegoDemoUserIDKey];
    }
}


- (void)cleanLocalUser
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kZegoDemoUserIDKey];
    [userDefaults removeObjectForKey:kZegoDemoUserNameKey];
    
    _userID = nil;
    _userName = nil;
}

- (NSString *)userName {
    if (_userName.length == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *userName = [ud stringForKey:kZegoDemoUserNameKey];
        if (userName.length > 0) {
            _userName = userName;
        } else {
            srand((unsigned)time(0));
#if TARGET_OS_SIMULATOR
            _userName = [NSString stringWithFormat:@"simulator-%u", (unsigned)rand()];
#else
            _userName = [NSString stringWithFormat:@"iphone-%u", (unsigned)rand()];
#endif
            [ud setObject:_userName forKey:kZegoDemoUserNameKey];
        }
    }
    
    return _userName;
}


- (void)setUserName:(NSString *)userName {
    if ([_userName isEqualToString:userName]) {
        return;
    }
    
    if (userName.length > 0) {
        _userName = userName;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:_userName forKey:kZegoDemoUserNameKey];
    }
}


- (BOOL)selectPresetQuality:(NSInteger)presetIndex {
    if (presetIndex >= self.presetVideoQualityList.count) {
        return NO;
    }
    
    _presetIndex = presetIndex;
    if (_presetIndex < self.presetVideoQualityList.count - 1) {
        _currentConfig = [ZegoAVConfig presetConfigOf:(ZegoAVConfigPreset)_presetIndex];
    }
    
    [self saveConfig];
    return YES;
}


- (void)setCurrentConfig:(ZegoAVConfig *)currentConfig {
    _presetIndex = self.presetVideoQualityList.count - 1;
    _currentConfig = currentConfig;
    
    [self saveConfig];
}


- (CGSize)currentResolution {
    return [self.currentConfig videoEncodeResolution];
}

- (int)beautifyFeature {
    if (_beautifyFeature == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([ud objectForKey:kZeogDemoBeautifyFeatureKey]) {
            _beautifyFeature = (int)[ud integerForKey:kZeogDemoBeautifyFeatureKey];
        } else {
            _beautifyFeature = ZEGO_BEAUTIFY_POLISH | ZEGO_BEAUTIFY_WHITEN;
        }
    }
    
    return _beautifyFeature;
}

- (void)setBeautifyFeature:(int)beautifyFeature {
    if (_beautifyFeature != beautifyFeature) {
        _beautifyFeature = beautifyFeature;
        [[NSUserDefaults standardUserDefaults] setInteger:_beautifyFeature forKey:kZeogDemoBeautifyFeatureKey];
    }
}


- (void)loadConfig {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    id preset = [ud objectForKey:kZegoDemoVideoPresetKey];
    if (preset) {
        _presetIndex = [preset integerValue];
        if (_presetIndex < _presetVideoQualityList.count - 1) {
            _currentConfig = [ZegoAVConfig presetConfigOf:(ZegoAVConfigPreset)_presetIndex];
            return ;
        }
    } else {
        _presetIndex = ZegoAVConfigPreset_High;
        _currentConfig = [ZegoAVConfig presetConfigOf:ZegoAVConfigPreset_High];
        return ;
    }
    
    _currentConfig = [ZegoAVConfig presetConfigOf:ZegoAVConfigPreset_Generic];
    
    NSInteger vWidth = [ud integerForKey:kZegoDemoVideoWitdhKey];
    NSInteger vHeight = [ud integerForKey:kZegoDemoVideoHeightKey];
    if (vWidth && vHeight) {
        CGSize r = CGSizeMake(vWidth, vHeight);
        _currentConfig.videoEncodeResolution = r;
        _currentConfig.videoCaptureResolution = r;
    }
    
    id frameRate = [ud objectForKey:kZegoDemoVideoFrameRateKey];
    if (frameRate) {
        _currentConfig.fps = (int)[frameRate integerValue];
    }
    
    id bitRate = [ud objectForKey:kZegoDemoVideoBitRateKey];
    if (bitRate) {
        _currentConfig.bitrate = (int)[bitRate integerValue];
    }
}


- (void)saveConfig {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(_presetIndex) forKey:kZegoDemoVideoPresetKey];
    
    if (_presetIndex >= self.presetVideoQualityList.count - 1) {
        [ud setInteger:_currentConfig.videoEncodeResolution.width forKey:kZegoDemoVideoWitdhKey];
        [ud setInteger:_currentConfig.videoEncodeResolution.height forKey:kZegoDemoVideoHeightKey];
        [ud setObject:@([_currentConfig fps]) forKey:kZegoDemoVideoFrameRateKey];
        [ud setObject:@([_currentConfig bitrate]) forKey:kZegoDemoVideoBitRateKey];
    } else {
        [ud removeObjectForKey:kZegoDemoVideoWitdhKey];
        [ud removeObjectForKey:kZegoDemoVideoHeightKey];
        [ud removeObjectForKey:kZegoDemoVideoFrameRateKey];
        [ud removeObjectForKey:kZegoDemoVideoBitRateKey];
    }
}

- (NSString *)getAvatarName:(NSString *)userID
{
    if (userID.length == 0)
        return nil;
    
    NSUInteger userIDInteger = [userID integerValue];
    
    NSUInteger avatarIndexBase = 86;
    NSUInteger avatarIndexEnd = 132;
    
    return [NSString stringWithFormat:@"emoji_%03lu", (userIDInteger % (avatarIndexEnd - avatarIndexBase + 1)) + avatarIndexBase];
}

- (UIImage *)getMemberAvatar:(NSArray<ZegoUser *> *)userList width:(CGFloat)width
{
    if (userList.count == 1)
        return [UIImage imageNamed:[self getAvatarName:userList.firstObject.userId]];
    else if (userList.count == 2)
    {
        CGFloat imagewidth = (width - 4) / 2;
        CGFloat yPos = (width - imagewidth) / 2;
        
        UIImage *firstImage = [UIImage imageNamed:[self getAvatarName:userList.firstObject.userId]];
        UIImage *secondImage = [UIImage imageNamed:[self getAvatarName:userList.lastObject.userId]];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, [UIScreen mainScreen].scale);
        
        [firstImage drawInRect:CGRectMake(1, yPos, imagewidth, imagewidth)];
        [secondImage drawInRect:CGRectMake(imagewidth + 3, yPos, imagewidth, imagewidth)];
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return finalImage;
    }
    else if (userList.count == 3)
    {
        CGFloat imagewidth = (width - 4) / 2;
        CGFloat yPos = 1;
        
        UIImage *firstImage = [UIImage imageNamed:[self getAvatarName:userList.firstObject.userId]];
        UIImage *secondImage = [UIImage imageNamed:[self getAvatarName:userList[1].userId]];
        UIImage *thirdImage = [UIImage imageNamed:[self getAvatarName:userList.lastObject.userId]];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, [UIScreen mainScreen].scale);
        [firstImage drawInRect:CGRectMake(1, yPos, imagewidth, imagewidth)];
        [secondImage drawInRect:CGRectMake(imagewidth + 3, yPos, imagewidth, imagewidth)];
        
        CGFloat xPos = (width - imagewidth) / 2;
        [thirdImage drawInRect:CGRectMake(xPos, 3 + imagewidth, imagewidth, imagewidth)];
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return finalImage;
    }
    else if (userList.count >= 4)
    {
        CGFloat imageWidth = (width - 4) / 2;
        CGFloat yPos = 1;
        
        UIImage *firstImage = [UIImage imageNamed:[self getAvatarName:userList.firstObject.userId]];
        UIImage *secondImage = [UIImage imageNamed:[self getAvatarName:userList[1].userId]];
        UIImage *thirdImage = [UIImage imageNamed:[self getAvatarName:userList[2].userId]];
        UIImage *fourthImage = [UIImage imageNamed:[self getAvatarName:userList[3].userId]];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, [UIScreen mainScreen].scale);
        [firstImage drawInRect:CGRectMake(1, yPos, imageWidth, imageWidth)];
        [secondImage drawInRect:CGRectMake(imageWidth + 3, yPos, imageWidth, imageWidth)];
        [thirdImage drawInRect:CGRectMake(1, imageWidth + 3, imageWidth, imageWidth)];
        [fourthImage drawInRect:CGRectMake(imageWidth + 3, imageWidth + 3, imageWidth, imageWidth)];
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return finalImage;
    }
    
    return nil;
}

- (BOOL)isDeviceiOS7
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        return YES;
    
    return NO;
}

@end
