//
//  ZegoLiveRoomApiDefines-Publisher.h
//  ZegoLiveRoom
//
//  Copyright © 2017年 zego. All rights reserved.
//

#ifndef ZegoLiveRoomApiDefines_Publisher_h
#define ZegoLiveRoomApiDefines_Publisher_h

/** 预设直播配置 */
typedef enum {
    /** 超低质量 */
    ZegoAVConfigPreset_Verylow  = 0,
    /** 低质量 */
    ZegoAVConfigPreset_Low      = 1,
    /** 标准质量 */
    ZegoAVConfigPreset_Generic  = 2,
    /** 高质量，手机端直播建议使用High配置，效果最优 */
    ZegoAVConfigPreset_High     = 3,
    /** 超高质量 */
    ZegoAVConfigPreset_Veryhigh = 4,
    /**极高质量 */
    ZegoAVConfigPreset_Superhigh = 5
} ZegoAVConfigPreset;

/** 视频帧率 */
typedef enum {
    /**  超低质量下的视频帧率 */
    ZegoAVConfigVideoFps_Verylow    = 5,
    /**  低质量下的视频帧率 */
    ZegoAVConfigVideoFps_Low        = 10,
    /**  标准质量下的视频帧率 */
    ZegoAVConfigVideoFps_Generic    = 15,
    /**  高质量下的视频帧率 */
    ZegoAVConfigVideoFps_High       = 20,
    /**  超高质量下的视频帧率 */
    ZegoAVConfigVideoFps_Veryhigh   = 25,
    /**  极高质量下的视频帧率 */
    ZegoAVConfigVideoFps_Superhigh  = 30
} ZegoAVConfigVideoFps;

/** 视频码率 */
typedef enum {
    /**  超低质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Verylow    = 300*1000,
    /**  低质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Low        = 400*1000,
    /**  标准质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Generic    = 600*1000,
    /**  高质量下的视频码率 */
    ZegoAVConfigVideoBitrate_High       = 1200*1000,
    /**  超高质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Veryhigh   = 1500*1000,
    /**  极高质量下的视频码率 */
    ZegoAVConfigVideoBitrate_Superhigh  = 3000*1000
} ZegoAVConfigVideoBitrate;

/** 直播配置 */
@interface ZegoAVConfig : NSObject

/**
 获取不同质量的直播配置实例
 
 @param preset 预设直播质量
 @return ZegoAVConfig 实例
 @discussion 直播前要预设直播配置
 */
+ (instancetype)presetConfigOf:(ZegoAVConfigPreset)preset;

/**  视频编码输出分辨率 */
@property (assign) CGSize videoEncodeResolution;
/**  视频采集分辨率 */
@property (assign) CGSize videoCaptureResolution;
/**  视频帧率 */
@property (assign) int fps;
/**  视频码率 */
@property (assign) int bitrate;

@end

/** 发布直播的模式 */
enum ZegoAPIPublishFlag
{
    /**  连麦模式 */
    ZEGOAPI_JOIN_PUBLISH   = 0,
    /**  混流模式 */
    ZEGOAPI_MIX_STREAM     = 1 << 1,
    /**  单主播模式 */
    ZEGOAPI_SINGLE_ANCHOR  = 1 << 2,
};

/** 混流图层信息，原点在左上角 */
@interface ZegoMixStreamInfo : NSObject

/** 要混流的单流ID */
@property (copy) NSString *streamID;
/** 混流图层左上角坐标的第二个值 */
@property int top;
/** 混流图层左上角坐标的第一个值，即左上角坐标为 (left, top) */
@property int left;
/** 混流图层右下角坐标的第二个值 */
@property int bottom;
/** 混流图层左上角坐标的第一个值，即右下角坐标为 (right, bottom) */
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

/** 混流配置 */
@interface ZegoCompleteMixStreamConfig : NSObject

/**  outputIsUrl 为 YES，则此值为 Url；否则为流名 */
@property (copy) NSString *outputStream;
/**  输出为流名，或 Url */
@property BOOL outputIsUrl;
/**  输出帧率 */
@property int outputFps;
/**  输出码率 */
@property int outputBitrate;
/**  输出分辨率 */
@property CGSize outputResolution;
/**  音频编码 */
@property int outputAudioConfig;
/**  输入流列表 */
@property (strong) NSMutableArray<ZegoMixStreamInfo*> *inputStreamList;
/** 用户自定义数据 */
@property NSData* userData;
/** 混流声道数，默认为单声道*/
@property int channels;

@end

/** 滤镜特性 */
typedef enum : NSUInteger {
    /**  不使用滤镜 */
    ZEGO_FILTER_NONE        = 0,
    /**  简洁 */
    ZEGO_FILTER_LOMO        = 1,
    /**  黑白 */
    ZEGO_FILTER_BLACKWHITE  = 2,
    /**  老化 */
    ZEGO_FILTER_OLDSTYLE    = 3,
    /**  哥特 */
    ZEGO_FILTER_GOTHIC      = 4,
    /**  锐色 */
    ZEGO_FILTER_SHARPCOLOR  = 5,
    /**  淡雅 */
    ZEGO_FILTER_FADE        = 6,
    /**  酒红 */
    ZEGO_FILTER_WINE        = 7,
    /**  青柠 */
    ZEGO_FILTER_LIME        = 8,
    /**  浪漫 */
    ZEGO_FILTER_ROMANTIC    = 9,
    /**  光晕 */
    ZEGO_FILTER_HALO        = 10,
    /**  蓝调 */
    ZEGO_FILTER_BLUE        = 11,
    /**  梦幻 */
    ZEGO_FILTER_ILLUSION    = 12,
    /**  夜色 */
    ZEGO_FILTER_DARK        = 13
} ZegoFilter;

/** 美颜特性 */
typedef enum : NSUInteger {
    /**  无美颜 */
    ZEGO_BEAUTIFY_NONE          = 0,
    /**  磨皮 */
    ZEGO_BEAUTIFY_POLISH        = 1,
    /**  全屏美白，一般与磨皮结合使用：ZEGO_BEAUTIFY_POLISH | ZEGO_BEAUTIFY_WHITEN */
    ZEGO_BEAUTIFY_WHITEN        = 1 << 1,
    /**  皮肤美白 */
    ZEGO_BEAUTIFY_SKINWHITEN    = 1 << 2,
    /**  锐化 */
    ZEGO_BEAUTIFY_SHARPEN       = 1 << 3
} ZegoBeautifyFeature;

/** 音频设备模式 */
typedef enum : NSUInteger {
    /** 通话模式, 开启硬件回声消除 */
    ZEGOAPI_AUDIO_DEVICE_MODE_COMMUNICATION = 1,
    /** 普通模式, 关闭硬件回声消除 */
    ZEGOAPI_AUDIO_DEVICE_MODE_GENERAL = 2,
    /** 自动模式, 根据场景选择是否开启硬件回声消除 */
    ZEGOAPI_AUDIO_DEVICE_MODE_AUTO = 3
} ZegoAPIAudioDeviceMode;

/** 延迟模式 */
typedef enum : NSUInteger {
    /** 普通延迟模式 */
    ZEGOAPI_LATENCY_MODE_NORMAL = 0,
    /** 低延迟模式，无法用于 RTMP 流 */
    ZEGOAPI_LATENCY_MODE_LOW,
    /** 普通延迟模式，最高码率可达 192K */
    ZEGOAPI_LATENCY_MODE_NORMAL2,
    /** 低延迟模式，无法用于 RTMP 流。相对于 ZEGO_LATENCY_MODE_LOW 而言，CPU 开销稍低 */
    ZEGOAPI_LATENCY_MODE_LOW2,
} ZegoAPILatencyMode;

/** 流量控制属性 */
typedef enum : NSUInteger {
    /** 无 */
    ZEGOAPI_TRAFFIC_NONE = 0,
    /** 帧率 */
    ZEGOAPI_TRAFFIC_FPS = 1,
    /** 分辨率 */
    ZEGOAPI_TRAFFIC_RESOLUTION = 1 << 1,
} ZegoAPITrafficControlProperty;

/** 推流通道 */
typedef enum :  NSUInteger {
    /** 主推流通道，默认 */
    ZEGOAPI_CHN_MAIN        =   0,
    /** 第二路推流通道, 无法推出声音 */
    ZEGOAPI_CHN_AUX,
} ZegoAPIPublishChannelIndex;

/** 视频采集缩放时机 */
typedef enum : NSUInteger {
    /** 采集后立即进行缩放，默认 */
    ZEGOAPI_CAPTURE_PIPELINE_SCALE_MODE_PRE = 0,
    /** 编码时进行缩放 */
    ZEGOAPI_CAPTURE_PIPELINE_SCALE_MODE_POST = 1,
} ZegoAPICapturePipelineScaleMode;

#endif /* ZegoLiveRoomApiDefines_Publisher_h */
