//
//  ZegoSettings.h
//  LiveDemo3
//
//  Created by Strong on 16/6/22.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZegoAVKitManager.h"

@interface ZegoSettings : NSObject
{
    ZegoAVConfig *_currentConfig;
}

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
//@property (nonatomic, strong) NSString *channelID;

@property (nonatomic, readonly) NSArray *appTypeList;

@property (readonly) NSArray *presetVideoQualityList;
@property (nonatomic, strong) ZegoAVConfig *currentConfig;
@property (readonly) NSInteger presetIndex;
@property (nonatomic, assign) int beautifyFeature;
@property (readonly) CGSize currentResolution;

- (BOOL)selectPresetQuality:(NSInteger)presetIndex;

- (ZegoUser *)getZegoUser;

//用token跟id拼接出一个channelID
- (NSString *)getChannelID:(unsigned int)bizToken bizID:(unsigned int)bizID;

- (void)cleanLocalUser;

- (NSString *)getAvatarName:(NSString *)userID;
- (UIImage *)getMemberAvatar:(NSArray<ZegoUser *> *)userList width:(CGFloat)width;

- (BOOL)isDeviceiOS7;

@end
