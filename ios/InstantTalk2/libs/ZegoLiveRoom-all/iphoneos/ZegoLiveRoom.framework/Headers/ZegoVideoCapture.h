//
//  ZegoVideoCapture.h
//  zegoavkit
//
//  Copyright © 2016 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

typedef NS_ENUM(NSInteger, ZegoVideoFillMode) {
    ZegoVideoFillModeBlackBar,
    ZegoVideoFillModeCrop,
    ZegoVideoFillModeStretch,
};

/** 视频外部采集代理 */
@protocol ZegoVideoCaptureDelegate <NSObject>

/**
 接收视频帧数据

 @param image 采集到的视频数据
 @param time 采集时间戳
 @attention 设置成功视频外部采集对象，并启动采集后，在此通知中获取视频帧数据
 */
- (void)onIncomingCapturedData:(nonnull CVImageBufferRef)image withPresentationTimeStamp:(CMTime)time;

@optional

/**
 
 @warning Deprecated
 */
- (void)onTakeSnapshot:(nonnull CGImageRef)image __attribute__ ((deprecated));

@end


/** 视频外部采集客户端代理 */
@protocol ZegoVideoCaptureClientDelegate <NSObject, ZegoVideoCaptureDelegate>

/**
 销毁
 
 @attention 调用者需要在此 API 中进行相关的销毁操作
 */
- (void)destroy;

/**
 错误信息

 @param reason 错误原因
 */
- (void)onError:(nullable NSString*)reason;

- (void)setFillMode:(ZegoVideoFillMode)mode;

@end


@protocol ZegoSupportsVideoCapture;

/** 视频外部采集设备接口 */
@protocol ZegoVideoCaptureDevice <NSObject, ZegoSupportsVideoCapture>

@required

/**
 初始化采集使用的资源（例如启动线程等）回调

 @param client SDK 实现回调的对象，一定要保存
 @attention 第一次调用开始预览／推流／拉流时调用
 */
- (void)zego_allocateAndStart:(nonnull id<ZegoVideoCaptureClientDelegate>) client;

/**
 停止并且释放采集占用的资源
 
 @attention 在此之后，不能再调用 client 对象的接口
 */
- (void)zego_stopAndDeAllocate;

/**
 启动采集，采集的数据通过 [client -onIncomingCapturedData:withPresentationTimeStamp:] 通知 SDK

 @return 0 表示成功，其他是错误
 @attention 一定要实现，不要做丢帧逻辑，SDK内部已经包含了丢帧策略
 */
- (int)zego_startCapture;

/**
 停止采集

 @return 0 表示成功，其它是错误
 @attention 一定要实现
 */
- (int)zego_stopCapture;

@end


/** 视频外部采集工厂接口 */
@protocol ZegoVideoCaptureFactory <NSObject>

@required

/**
 创建采集设备

 @param deviceId 设备 Id
 @return 采集设备实例
 @attention 一定要实现
 */
- (nonnull id<ZegoVideoCaptureDevice>)zego_create:(nonnull NSString*)deviceId;

/**
 销毁采集设备

 @param device zego_create返回的采集设备实例
 @attention 一定要实现
 */
- (void)zego_destroy:(nonnull id<ZegoVideoCaptureDevice>)device;

@end

/** 视频缓冲区类型 */
typedef NS_ENUM(NSInteger, ZegoVideoBufferType) {
    ZegoVideoBufferTypeUnknown = 0,                     /**< 未知 */
    ZegoVideoBufferTypeAsyncPixelBuffer = 1 << 1,       /**< 异步 */
    ZegoVideoBufferTypeSyncPixelBuffer = 1 << 2,        /**< 同步 */
    ZegoVideoBufferTypeAsyncI420PixelBuffer = 1 << 7,   /**< 异步I420 */
};

/** 外部滤镜内存池协议（用于 SDK 与开发者间相互传递外部滤镜数据） */
@protocol ZegoVideoBufferPool <NSObject>

/**
 SDK 获取 CVPixelBufferRef 对象

 @param width 高度
 @param height 宽度
 @param stride 视频帧数据每一行字节数
 @return CVPixelBufferRef CVPixelBufferRef 对象
 @attention 开发者调用此 API 向 SDK 返回 CVPixelBufferRef 对象，用于保存视频帧数据
 */
- (nullable CVPixelBufferRef)dequeueInputBuffer:(int)width height:(int)height stride:(int)stride;

/**
 异步处理视频帧数据

 @param pixel_buffer 视频帧数据
 @param timestamp_100n 当前时间戳
 @attention 开发者在此 API 中获取采集的视频帧数据
 */
- (void)queueInputBuffer:(nonnull CVPixelBufferRef)pixel_buffer timestamp:(unsigned long long)timestamp_100n;

@end


/** 外部滤镜同步回调 */
@protocol ZegoVideoFilterDelegate <NSObject>
/**
 同步处理视频帧数据

 @param pixel_buffer 视频帧数据
 @param timestamp_100 当前时间戳
 */
- (void)onProcess:(nonnull CVPixelBufferRef)pixel_buffer withTimeStatmp:(unsigned long long)timestamp_100;

@end


/** 外部滤镜客户端接口 */
@protocol ZegoVideoFilterClient <NSObject>

/**
 销毁外部滤镜客户端
 */
- (void)destroy;
@end


/** 外部滤镜 */
@protocol ZegoVideoFilter

@required

/**
 初始化外部滤镜使用的资源

 @param client 外部滤镜客户端，主要用于向 SDK 传递数据
 */
- (void)zego_allocateAndStart:(nonnull id<ZegoVideoFilterClient>) client;

/**
 停止并释放外部滤镜占用的资源
 */
- (void)zego_stopAndDeAllocate;

/**
 支持的 buffer 类型

 @return buffer 类型，参考 ZegoVideoBufferType 定义
 */
- (ZegoVideoBufferType)supportBufferType;

@end


/** 外部滤镜工厂接口 */
@protocol ZegoVideoFilterFactory <NSObject>

@required
/**
 创建外部滤镜

 @return 外部滤镜实例
 */
- (nonnull id<ZegoVideoFilter>)zego_create;

/**
 销毁外部滤镜

 @param filter 外部滤镜
 */
- (void)zego_destroy:(nonnull id<ZegoVideoFilter>)filter;

@end


/** 视频外部采集接口 */
@protocol ZegoSupportsVideoCapture

@optional
/**
 设置视频采样帧率回调

 @param framerate 帧率
 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_setFrameRate:(int)framerate;

/**
 设置视频采集分辨率回调

 @param width 宽
 @param height 高
 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_setWidth:(int)width andHeight:(int)height;

/**
 切换前后摄像头回调

 @param bFront true 表示前摄像头，false 表示后摄像头
 @return 0 切换成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_setFrontCam:(int)bFront;

#if TARGET_OS_IPHONE
/**
 设置采集使用载体视图回调，移动端使用

 @param view 载体视图
 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_setView:(UIView* _Nullable )view;
#elif TARGET_OS_OSX

/**
 设置采集使用载体视图回调，PC 端使用

 @param view 载体视图
 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_setView:(NSView* _Nullable )view;
#endif

/**
 设置采集预览的模式回调

 @param mode 预览模式
 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_setViewMode:(int)mode;

/**
 设置采集预览的逆时针旋转角度回调

 @param rotation 旋转角度
 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_setViewRotation:(int)rotation;

/**
 设置采集 buffer 的顺时针旋转角度回调

 @param rotaion 旋转角度
 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_setCaptureRotation:(int)rotaion;

/**
 启动预览回调

 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_startPreview;

/**
 停止预览回调

 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_stopPreview;

/**
 开启手电筒回调

 @param enable true 开启，false 不开启
 @return 0 设置成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_enableTorch:(bool)enable;

/**
 对采集预览进行截图回调

 @return 0 截图成功，其他值失败
 @attention 调用 SDK 相关接口设置成功后，会通过此 API 通知调用者
 */
- (int)zego_takeSnapshot;

/**
 
 @warning Deprecated
 */
- (int)zego_setPowerlineFreq:(unsigned int)freq __attribute__ ((deprecated));

@end
