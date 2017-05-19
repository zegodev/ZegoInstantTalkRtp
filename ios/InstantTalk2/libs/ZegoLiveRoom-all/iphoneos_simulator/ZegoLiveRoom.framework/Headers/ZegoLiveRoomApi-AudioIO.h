//
//  ZegoLiveRoomApi-AudioIO.h
//  ZegoLiveRoom
//
//  Created by Strong on 2017/3/16.
//  Copyright © 2017年 zego. All rights reserved.
//

#ifndef ZegoLiveRoomApi_AudioIO_h
#define ZegoLiveRoomApi_AudioIO_h

#import "ZegoLiveRoomApi.h"
#import "ZegoAudioCapture.h"

@interface ZegoLiveRoomApi (AudioIO)

/**
 启用外部音频采集

 @param enable true 启用，false 不启用。默认 false
 */
+ (void)enableExternalAudioDevice:(bool)enable;

/**
 获取 IAudioDataInOutput 对象

 @return IAudioDataInOutput 对象
 */
- (AVE::IAudioDataInOutput *)getIAudioDataInOutput;

@end

#endif /* ZegoLiveRoomApi_AudioIO_h */
