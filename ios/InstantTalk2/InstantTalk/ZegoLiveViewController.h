//
//  ZegoLiveViewController.h
//  LiveDemo3
//
//  Created by Strong on 16/6/28.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoAVKitManager.h"
#import "ZegoAnchorOptionViewController.h"
#import <AVFoundation/AVAudioSession.h>

@interface ZegoLiveViewController : UIViewController <ZegoAnchorOptionDelegate>

//YES 使用前置摄像头
@property (nonatomic, assign) BOOL useFrontCamera;
//YES 开启麦克风
@property (nonatomic, assign) BOOL enableMicrophone;
//设置美颜效果
@property (nonatomic, assign) ZegoBeautifyFeature beautifyFeature;
//设置滤镜
@property (nonatomic, assign) ZegoFilter filter;
//设置视频view格式（等比缩放，等比缩放填充，填充整个视图等)
@property (nonatomic, assign) ZegoVideoViewMode viewMode;
//YES 开启手电筒
@property (nonatomic, assign) BOOL enableTorch;
//YES 启用摄像头 
@property (nonatomic, assign) BOOL enableCamera;

@property (nonatomic, assign, readonly) NSUInteger maxStreamCount;

//日志记录
@property (nonatomic, strong) NSMutableArray *logArray;
//帧率，码率信息
@property (nonatomic, strong) NSMutableArray *qualityLogArray;

- (void)setAnchorConfig:(UIView *)publishView;

// 设置视频视图的约束
- (BOOL)setContainerConstraints:(UIView *)view containerView:(UIView *)containerView viewCount:(NSUInteger)viewCount;
// 点击切换视图，约束更新
- (void)updateContainerConstraintsForTap:(UIView *)tapView containerView:(UIView *)containerView;
// 流删减后视图，约束更新
- (void)updateContainerConstraintsForRemove:(UIView *)removeView containerView:(UIView *)containerView;

- (void)reportStreamAction:(BOOL)success streamID:(NSString *)streamID;

- (void)showPublishOption;

- (void)setIdelTimerDisable:(BOOL)disable;

//电话监听处理函数
- (void)audioSessionWasInterrupted:(NSNotification *)notification;

- (void)addLogString:(NSString *)logString;

- (BOOL)isDeviceiOS7;

- (NSString *)addStaticsInfo:(BOOL)publish stream:(NSString *)streamID fps:(double)fps kbs:(double)kbs rtt:(int)rtt pktLostRate:(int)pktLostRate;

- (void)updateQuality:(int)quality detail:(NSString *)detail onView:(UIView *)playerView;

@end
