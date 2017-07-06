//
//  ZegoLiveRoomApiDefines.h
//  ZegoLiveRoom
//
//  Copyright © 2017年 zego. All rights reserved.
//

#ifndef ZegoLiveRoomApiDefines_h
#define ZegoLiveRoomApiDefines_h

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define ZEGOView UIView
#define ZEGOImage UIImage
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#define ZEGOView NSView
#define ZEGOImage NSImage
#endif

#ifdef __cplusplus
#define ZEGO_EXTERN     extern "C"
#else
#define ZEGO_EXTERN     extern
#endif

/** 流信息列表项 */
ZEGO_EXTERN NSString *const kZegoRtmpUrlListKey;        /**< rtmp 播放 url 列表，值为 NSArray<NSString *> */
ZEGO_EXTERN NSString *const kZegoHlsUrlListKey;         /**< hls 播放 url 列表，值为 NSArray<NSString *> */
ZEGO_EXTERN NSString *const kZegoFlvUrlListKey;         /**< flv 播放 url 列表，值为 NSArray<NSString *> */

ZEGO_EXTERN NSString *const kZegoMixNonExistsStreamIDKey;   /**< 混流不存在的流名，值为 NSString* */
ZEGO_EXTERN NSString *const kZegoMixStreamReqSeqKey;        /**< 混流请求 seq，值为 @(int) */

/** 混流配置项，调用 [ZegoLiveRoomApi (Publisher) -setMixStreamConfig:] 设置 */
ZEGO_EXTERN NSString *const kZegoMixStreamIDKey;        /**< 混流ID，值为 NSString */
ZEGO_EXTERN NSString *const kZegoMixStreamResolution;   /**< 混流输出大小，值为 NSValue */


/** 自定义推流配置项，调用 [ZegoLiveRoomApi (Publisher) -setPublishConfig:] 设置 */
ZEGO_EXTERN NSString *const kPublishCustomTarget;       /**< 自定义转推 RTMP 地址 */

/** 设备项 */
ZEGO_EXTERN NSString *const kZegoDeviceCameraName;      /**< 摄像头设备 */
ZEGO_EXTERN NSString *const kZegoDeviceMicrophoneName;  /**< 麦克风设备 */

ZEGO_EXTERN NSString *const kZegoConfigKeepAudioSesionActive;  /**< AudioSession相关配置信息的key, 值为 NSString */

/** 成员角色 */
typedef enum
{
    ZEGO_ANCHOR = 1,    /**< 主播 */
    ZEGO_AUDIENCE = 2,  /**< 观众 */
} ZegoRole;

/** 流变更类型 */
typedef enum
{
    ZEGO_STREAM_ADD     = 2001,     /**< 新增流 */
    ZEGO_STREAM_DELETE  = 2002,     /**< 删除流 */
} ZegoStreamType;

/** 本地预览视频视图的模式 */
typedef enum {
    ZegoVideoViewModeScaleAspectFit     = 0,    /**< 等比缩放，可能有黑边 */
    ZegoVideoViewModeScaleAspectFill    = 1,    /**< 等比缩放填充整View，可能有部分被裁减 */
    ZegoVideoViewModeScaleToFill        = 2,    /**< 填充整个View */
} ZegoVideoViewMode;

/** 发布直播模式 */
enum ZegoApiPublishFlag
{
    ZEGO_JOIN_PUBLISH   = 0,        /**< 连麦模式 */
    ZEGO_MIX_STREAM     = 1 << 1,   /**< 混流模式 */
    ZEGO_SINGLE_ANCHOR  = 1 << 2,   /**< 单主播模式 */
};

typedef struct
{
    double fps;
    double kbps;
    int rtt;
    int pktLostRate;            ///< 丢包率: 0 ~ 255
    
    int quality;
    
} ZegoApiPublishQuality;

typedef ZegoApiPublishQuality ZegoApiPlayQuality;

@interface ZegoStream : NSObject

@property (nonatomic, copy) NSString *userID;       /**< 用户 ID */
@property (nonatomic, copy) NSString *userName;     /**< 用户名 */
@property (nonatomic, copy) NSString *streamID;     /**< 流 ID */
@property (nonatomic, copy) NSString *extraInfo;    /**< 流附加信息 */
@end

typedef void(^ZegoSnapshotCompletionBlock)(ZEGOImage* img);

/** 设备模块类型 */
enum ZegoAPIModuleType
{
    ZEGOAPI_MODULE_AUDIO            = 0x4 | 0x8,    /**< 音频采集播放设备 */
};

enum ZegoAPIAudioRecordMask
{
    ZEGOAPI_AUDIO_RECORD_NONE      = 0x0,  ///< 关闭音频录制
    ZEGOAPI_AUDIO_RECORD_CAP       = 0x01, ///< 打开采集录制
    ZEGOAPI_AUDIO_RECORD_RENDER    = 0x02, ///< 打开渲染录制
    ZEGOAPI_AUDIO_RECORD_MIX       = 0x04  ///< 打开采集和渲染混音结果录制
};

#endif /* ZegoLiveRoomApiDefines_h */
