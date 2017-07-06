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

/**
 设置音频前处理函数
 
 @param prep 前处理函数指针
 @attention 必须在 InitSDK 前调用，不能置空
 @note 调用者调用此 API 设置音频前处理函数。SDK 会在音频编码前调用，inData 为输入的音频原始数据，outData 为函数处理后数据
 @note 单通道，位深为 16 bit
 */
+ (void)setAudioPrep:(void(*)(const short* inData, int inSamples, int sampleRate, short *outData))prep;

/**
 设置音频前处理函数
 
 @param prepSet 预处理的采样率等参数设置
 @param callback 采样数据回调
 @note 调用者调用此 API 设置音频前处理函数。SDK 会在音频编码前调用，inFrame 为采集的音频数据，outFrame 为处理后返回给SDK的数据
 */
+ (void)setAudioPrep2:(AVE::ExtPrepSet)prepSet dataCallback:(void(*)(const AVE::AudioFrame& inFrame, AVE::AudioFrame& outFrame))callback;

@end

#endif /* ZegoLiveRoomApi_AudioIO_h */
