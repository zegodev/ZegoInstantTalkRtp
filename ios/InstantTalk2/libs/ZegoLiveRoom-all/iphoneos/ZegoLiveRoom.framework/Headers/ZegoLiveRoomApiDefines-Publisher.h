//
//  ZegoLiveRoomApiDefines-Publisher.h
//  ZegoLiveRoom
//
//  Created by Randy Qiu on 2017/1/24.
//  Copyright © 2017年 zego. All rights reserved.
//

#ifndef ZegoLiveRoomApiDefines_Publisher_h
#define ZegoLiveRoomApiDefines_Publisher_h

/** 预设直播配置 */
typedef enum {
    ZegoAVConfigPreset_Verylow  = 0,    /**< 超低质量 */
    ZegoAVConfigPreset_Low      = 1,    /**< 低质量 */
    ZegoAVConfigPreset_Generic  = 2,    /**< 标准质量 */
    ZegoAVConfigPreset_High     = 3,    /**< 高质量，手机端直播建议使用High配置，效果最优 */
    ZegoAVConfigPreset_Veryhigh = 4,    /**< 超高质量 */
    ZegoAVConfigPreset_Superhigh = 5    /**< 极高质量 */
} ZegoAVConfigPreset;

/** 视频帧率 */
typedef enum {
    ZegoAVConfigVideoFps_Verylow    = 5,    /**< 超低质量下的视频帧率 */
    ZegoAVConfigVideoFps_Low        = 10,   /**< 低质量下的视频帧率 */
    ZegoAVConfigVideoFps_Generic    = 15,   /**< 标准质量下的视频帧率 */
    ZegoAVConfigVideoFps_High       = 20,   /**< 高质量下的视频帧率 */
    ZegoAVConfigVideoFps_Veryhigh   = 25,   /**< 超高质量下的视频帧率 */
    ZegoAVConfigVideoFps_Superhigh  = 30    /**< 极高质量下的视频帧率 */
} ZegoAVConfigVideoFps;

/** 视频码率 */
typedef enum {
    ZegoAVConfigVideoBitrate_Verylow    = 300*1000,  /**< 超低质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Low        = 400*1000,  /**< 低质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Generic    = 600*1000,  /**< 标准质量下的视频码率 */
    ZegoAVConfigVideoBitrate_High       = 1200*1000, /**< 高质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Veryhigh   = 1500*1000, /**< 超高质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Superhigh  = 3000*1000  /**< 极高质量下的视频码率 */
} ZegoAVConfigVideoBitrate;


@interface ZegoAVConfig : NSObject

/**
 获取不同质量的直播配置实例

 @param preset 预设直播质量
 @return ZegoAVConfig 实例
 @attention 直播前要预设直播配置
 */
+ (instancetype)presetConfigOf:(ZegoAVConfigPreset)preset;

@property (assign) CGSize videoEncodeResolution;    /**< 视频编码输出分辨率 */
@property (assign) CGSize videoCaptureResolution;   /**< 视频采集分辨率 */
@property (assign) int fps;                         /**< 视频帧率 */
@property (assign) int bitrate;                     /**< 视频码率 */

@end

/** 发布直播的模式 */
enum ZegoAPIPublishFlag
{
    ZEGOAPI_JOIN_PUBLISH   = 0,         /**< 连麦模式 */
    ZEGOAPI_MIX_STREAM     = 1 << 1,    /**< 混流模式 */
    ZEGOAPI_SINGLE_ANCHOR  = 1 << 2,    /**< 单主播模式 */
};

/** 混流图层信息 */
@interface ZegoMixStreamInfo : NSObject

@property (copy) NSString *streamID;    /**< 要混流的单流ID */
@property int top;
@property int left;
@property int bottom;
@property int right;

/**
 *  原点在左上角，top/bottom/left/right 定义如下：
 *
 *  (left, top)-----------------------
 *  |                                |
 *  |                                |
 *  |                                |
 *  |                                |
 *  -------------------(right, bottom)
 */

@end

@interface ZegoCompleteMixStreamConfig : NSObject

@property (copy) NSString *outputStream;
@property BOOL outputIsUrl;
@property int outputFps;
@property int outputBitrate;
@property CGSize outputResolution;
@property int outputAudioConfig;

@property (strong) NSMutableArray<ZegoMixStreamInfo*> *inputStreamList;

@end

/** 滤镜特性 */
typedef enum : NSUInteger {
    ZEGO_FILTER_NONE        = 0,    /**< 不使用滤镜 */
    ZEGO_FILTER_LOMO        = 1,    /**< 简洁 */
    ZEGO_FILTER_BLACKWHITE  = 2,    /**< 黑白 */
    ZEGO_FILTER_OLDSTYLE    = 3,    /**< 老化 */
    ZEGO_FILTER_GOTHIC      = 4,    /**< 哥特 */
    ZEGO_FILTER_SHARPCOLOR  = 5,    /**< 锐色 */
    ZEGO_FILTER_FADE        = 6,    /**< 淡雅 */
    ZEGO_FILTER_WINE        = 7,    /**< 酒红 */
    ZEGO_FILTER_LIME        = 8,    /**< 青柠 */
    ZEGO_FILTER_ROMANTIC    = 9,    /**< 浪漫 */
    ZEGO_FILTER_HALO        = 10,   /**< 光晕 */
    ZEGO_FILTER_BLUE        = 11,   /**< 蓝调 */
    ZEGO_FILTER_ILLUSION    = 12,   /**< 梦幻 */
    ZEGO_FILTER_DARK        = 13    /**< 夜色 */
} ZegoFilter;

/** 美颜特性 */
typedef enum : NSUInteger {
    ZEGO_BEAUTIFY_NONE          = 0,        /**< 无美颜 */
    ZEGO_BEAUTIFY_POLISH        = 1,        /**< 磨皮 */
    ZEGO_BEAUTIFY_WHITEN        = 1 << 1,   /**< 全屏美白，一般与磨皮结合使用：ZEGO_BEAUTIFY_POLISH | ZEGO_BEAUTIFY_WHITEN */
    ZEGO_BEAUTIFY_SKINWHITEN    = 1 << 2,   /**< 皮肤美白 */
    ZEGO_BEAUTIFY_SHARPEN       = 1 << 3    /**< 锐化 */
} ZegoBeautifyFeature;

typedef enum : NSUInteger {
    ZEGOAPI_AUDIO_DEVICE_MODE_COMMUNICATION = 1,
    ZEGOAPI_AUDIO_DEVICE_MODE_GENERAL = 2,
    ZEGOAPI_AUDIO_DEVICE_MODE_AUTO = 3
} ZegoAPIAudioDeviceMode;

typedef enum : NSUInteger {
    ZEGOAPI_LATENCY_MODE_NORMAL = 0,    ///< 普通延迟模式
    ZEGOAPI_LATENCY_MODE_LOW,           ///< 低延迟模式，*无法用于 RTMP 流*
    ZEGOAPI_LATENCY_MODE_NORMAL2,       ///< 普通延迟模式，最高码率可达192K 
} ZegoAPILatencyMode;

typedef enum : NSUInteger {
    ZEGOAPI_TRAFFIC_NONE = 0,
    ZEGOAPI_TRAFFIC_FPS = 1,                ///< 帧率
    ZEGOAPI_TRAFFIC_RESOLUTION = 1 << 1,    ///< 分辨率
} ZegoAPITrafficControlProperty;

#endif /* ZegoLiveRoomApiDefines_Publisher_h */
