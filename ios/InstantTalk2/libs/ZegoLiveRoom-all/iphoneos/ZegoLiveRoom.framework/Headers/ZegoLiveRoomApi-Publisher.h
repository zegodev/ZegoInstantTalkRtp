//
//  ZegoLiveRoomApi-Publisher.h
//  ZegoLiveRoom
//
//  Created by Randy Qiu on 2017/1/24.
//  Copyright © 2017年 zego. All rights reserved.
//


#import "ZegoLiveRoomApi.h"
#import "ZegoLiveRoomApiDefines-Publisher.h"
#import "ZegoVideoCapture.h"

@protocol ZegoLivePublisherDelegate;


@interface ZegoLiveRoomApi (Publisher)

/**
 设置 Publisher 代理对象

 @param publisherDelegate 遵循 ZegoLivePublisherDelegate 协议的代理对象
 @return true 成功，false 失败
 @attention 使用 Publisher 功能，初始化相关视图控制器时需要设置代理对象
 @note 未设置代理对象，或对象设置错误，可能导致无法正常收到相关回调
 */
- (bool)setPublisherDelegate:(id<ZegoLivePublisherDelegate>)publisherDelegate;

/**
 设置本地预览视图

 @param view 用于渲染本地预览视频的视图
 @return true 成功，false 失败
 @attention 建议本地预览结束后，调用该 API 设置预览视图为 nil
 */
- (bool)setPreviewView:(ZEGOView *)view;

/**
 启动本地预览

 @return true 成功，false 失败
 @attention 启动本地预览前，要调用 [ZegoLiveRoomApi (Publisher) -setPreviewView:] 设置本地预览视图
 */
- (bool)startPreview;

/**
 结束本地预览

 @return true 成功，false 失败
 @attention 建议停止推流，或本地预览结束后，调用该 API 停止本地预览
 */
- (bool)stopPreview;

/**
 开始发布直播

 @param streamID 流 ID
 @param title 直播名称，可选，默认为主播用户名
 @param flag 直播属性，参考 ZegoApiPublishFlag 定义
 @return true 成功，false 失败
 @attention 发布直播成功后，等待 [ZegoLivePublisherDelegate -onPublishStateUpdate:streamID:streamInfo:] 通知
 */
- (bool)startPublishing:(NSString *)streamID title:(NSString *)title flag:(int)flag;

/**
 开始发布直播

 @param streamID 流 ID
 @param title 直播名称，可选，默认为主播用户名
 @param flag 直播属性，参考 ZegoApiPublishFlag 定义
 @param extraInfo 流附加信息
 @return true 成功，false 失败
 @attention 发布直播成功后，等待 [ZegoLivePublisherDelegate -onPublishStateUpdate:streamID:streamInfo:] 通知
 */
- (bool)startPublishing:(NSString *)streamID title:(NSString *)title flag:(int)flag extraInfo:(NSString *)extraInfo;

/**
 更新流附加信息

 @param extraInfo 流附加信息
 @return true 成功，false 失败
 @attention 通常在主播方的 [ZegoLivePublisherDelegate -onPublishStateUpdate:streamID:streamInfo:] 通知中，或其他需更新流附加信息的场合下调用
 @note 更新流附加信息成功后，除调用方外，同一房间内的其他人会收到 [ZegoLiveRoomDelegate -onStreamExtraInfoUpdated:roomID] 通知
 */
- (bool)updateStreamExtraInfo:(NSString *)extraInfo;

/**
 停止直播
 
 @return true 成功，false 失败
 @attention 注意混流结束后，要先调用 [-updateMixInputStreams] 将流列表清空结束混流，然后调用 stopPublishing 结束直播
 */
- (bool)stopPublishing;

/**
 自定义推流配置

 @param config 配置信息 key-value，目前 key 仅支持 kPublishCustomTarget ，value 为用户自定义的转推 RTMP 地址。参考 ZegoLiveRoomApiDefines.h 中相关定义
 @attention 开发者如果使用自定义转推功能，推流开始前，必须调用此接口设置转推 RTMP 地址（SDK 推流方式必须为 UDP，转推地址必须为 RTMP），否则可能导致转推失败。
 */
- (void)setPublishConfig:(NSDictionary *)config;

/**
 响应连麦请求

 @param seq 连麦请求序列号，标识当次连麦请求
 @param rspResult 响应结果，0 表示同意连麦
 @return true 成功，false 失败
 @attention 主播端通过 [ZegoLivePublisherDelegate -onJoinLiveRequest:fromUserID:fromUserName:seq:] 收到观众连麦申请，再调用本 API 响应
 */
- (bool)respondJoinLiveReq:(int)seq result:(int)rspResult;

/**
 邀请连麦

 @param userID 准备邀请的用户 ID
 @param blk 邀请成功后，通过 blk 回调结果
 @return true 成功，false 失败
 @attention 主播邀请连麦成功后，被邀请的观众收到  [ZegoLivePlayerDelegate -onInviteJoinLiveRequest:fromUserID:fromUserName:roomID:] 通知
 */
- (bool)inviteJoinLive:(NSString *)userID responseBlock:(ZegoResponseBlock)blk;


/**
 结束连麦

 @param userId 指定UserId停止连麦
 @param block 信令发送结果
 @return true 成功，false 失败
 */
- (bool)endJoinLive:(NSString *)userId completionBlock:(ZegoCustomCommandBlock)block;

/**
 设置混流数据配置

 @param config 配置，目前支持的配置有kZegoMixStreamIDKey，kZegoMixStreamResolution，详见 ZegoLiveRoomApiDefines.h
 @return true 成功，false 失败
 @attention 如果主播选择发布混流模式，发布直播前，需调用此 API 进行混流设置
 @note 设置成功后，调用者会收到 [ZegoLivePublisherDelegate -onMixStreamConfigUpdate:mixStream:streamInfo:] 回调
 */
- (bool)setMixStreamConfig:(NSDictionary *)config;

/**
 更新混流配置

 @param lstMixStreamInfo 混流配置列表，按列表顺序叠加涂层
 @return true 成功，false 失败。更新成功后，等待异步回调调用方的 [ZegoLivePublisherDelegate -onMixStreamConfigUpdate:mixStream:streamInfo:]
 @attention 主播发布混流模式直播，在新增流、删除流、及结束混流时，要调用此 API 更新混流配置
 @note 混流结束后，要先调用此 API 将流列表清空结束混流，然后调用 [ZegoLiveRoomApi (Publisher) stopPublishing] 结束直播。
 */
- (bool)updateMixInputStreams:(NSArray<ZegoMixStreamInfo*> *)lstMixStreamInfo;


/**
 开始混流

 @param completeMixConfig 混流配置
 @param seq 请求序号，回调会带回次 seq
 @return true 成功，等待回调，false 失败
 @note 每次需要更新混流配置时，都可以调用此接口；如果需要多次调用，可以通过传入不同的 seq 区分回调
 */
- (bool)mixStream:(ZegoCompleteMixStreamConfig *)completeMixConfig seq:(int)seq;

/**
 硬件编码开关

 @param bRequire true 开启，false 关闭。默认 false
 @return true 成功，false 失败
 @attention 如果要打开，需要在推流前设置
 @note 打开硬编硬解开关需后台可控，避免碰到版本升级或者硬件升级时出现硬编硬解失败的问题
 */
+ (bool)requireHardwareEncoder:(bool)bRequire;

/**
 设置视频配置

 @param config 配置参数（视频编码输出分辨率、视频采集分辨率、视频帧率、视频码率），参考 ZegoAVConfig 定义
 @return true 成功，false 失败
 @attention 推流开始前调用本 API 进行视频采集参数配置
 */
- (bool)setAVConfig:(ZegoAVConfig *)config;

#if TARGET_OS_IPHONE
/**
 设置手机方向

 @param orientation 手机方向
 @return true 成功，false 失败
 @attention 本设置用于校正主播输出视频朝向
 */
- (bool)setAppOrientation:(UIInterfaceOrientation)orientation;
#endif

/**
 主播方开启美颜功能

 @param feature 美颜特性，参考 ZegoBeautifyFeature 定义。默认无美颜
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 */
- (bool)enableBeautifying:(int)feature;

/**
 设置美颜磨皮的采样步长

 @param step 采样步长，取值范围[1,16]。默认 4.0
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置。设置时需确保对应美颜特性开启
 */
- (bool)setPolishStep:(float)step;

/**
 设置美颜采样颜色阈值

 @param factor 采样颜色阈值，取值范围[0,16]。默认 4.0
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置。设置时需确保对应美颜特性开启
 
 */
- (bool)setPolishFactor:(float)factor;

/**
 设置美颜美白的亮度修正参数

 @param factor 亮度修正参数，取值范围[0,1]，值越大亮度越暗。默认 0.5
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置。设置时需确保对应美颜特性开启
 */
- (bool)setWhitenFactor:(float)factor;

/**
 设置锐化参数

 @param factor 锐化参数，取值范围[0,2]，值越大锐化越强。默认 0.2
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置。设置时需确保对应美颜特性开启
 */
- (bool)setSharpenFactor:(float)factor;

/**
 设置滤镜

 @param filter 滤镜种类，参考 ZegoFilter 定义。默认不使用滤镜
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 */
- (bool)setFilter:(ZegoFilter)filter;

/**
 设置本地预览视频视图的模式

 @param mode 模式，参考 ZegoVideoViewMode 定义。默认 ZegoVideoViewModeScaleAspectFill
 @return true 成功，false 失败
 @attention 推流开始前调用本 API 进行参数配置
 */
- (bool)setPreviewViewMode:(ZegoVideoViewMode)mode;

/**
 设置预览渲染朝向

 @param rotate 旋转角度。默认 0
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 @note 使用 setAppOrientation 替代
 */
- (bool)setPreviewRotation:(int)rotate;

/**
 是否启用预览镜像

 @param enable true 启用，false 不启用。默认 true
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 */
- (bool)enablePreviewMirror:(bool)enable;

/**
 是否启用摄像头采集结果镜像

 @param enable true 启用，false 不启用。默认 false
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 */
- (bool)enableCaptureMirror:(bool)enable;

/**
 是否开启码率控制

 @param enable true 启用，false 不启用。默认不启用
 @return true 成功，false 失败
 @attention 开启后，在带宽不足的情况下码率自动适应当前带宽
 */
- (bool)enableRateControl:(bool)enable;

/**
 是否使用前置摄像头

 @param bFront true 使用，false 不使用。默认 true
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 */
- (bool)setFrontCam:(bool)bFront;

/**
 开启关闭麦克风

 @param bEnable true 打开，false 关闭。默认 false
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 */
- (bool)enableMic:(bool)bEnable;

/**
 开启视频采集

 @param bEnable true 打开，false 关闭。默认 true
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 */
- (bool)enableCamera:(bool)bEnable;

/**
 开关手电筒

 @param bEnable true 打开，false 关闭。默认 false
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置
 */
- (bool)enableTorch:(bool) bEnable;

/**
 预览截图

 @param blk 截图结果通过 blk 回调
 @return true 成功，false 失败
 */
- (bool)takePreviewSnapshot:(ZegoSnapshotCompletionBlock)blk;

/**
 开启采集监听

 @param bEnable true 打开，false 关闭。默认 false
 @return true 成功，false 失败
 @attention 推流时可调用本 API 进行参数配置。
 @note 开启采集监听，主播方讲话后，会听到自己的声音
 @note 建议开发者开启采集监听功能时，要求用户连接耳麦，否则会使手机扬声器发出的声音被反复采集
 */
- (bool)enableLoopback:(bool)bEnable;

/**
 设置采集监听音量

 @param volume 音量大小，取值（0, 100）。默认 100
 @attention 推流时可调用本 API 进行参数配置
 */
- (void)setLoopbackVolume:(int)volume;

/**
 混音开关

 @param enable true 启用混音输入，false 关闭混音输入。默认 false
 @return true 成功，false 失败
 @attention 推流开始前调用本 API 进行参数配置
 @note 主播端开启混音后，SDK 在 [ZegoLiveRoomApi (Publisher) -onAuxCallback:dataLen:sampleRate:channelCount:] 中获取混音输入数据
 */
- (bool)enableAux:(BOOL)enable;

/**
 混音静音开关

 @param bMute true: aux 输入播放静音，false: 不静音。默认 false
 @return true 成功，false 失败
 @attention 推流开始前调用本 API 进行参数配置
 */
- (bool)muteAux:(bool)bMute;

/**
 获取当前采集的音量

 @return 当前采集的音量值
 */
- (float)getCaptureSoundLevel;

/**
 设置水印的图片路径

 @param filePath 图片路径。如果是完整路径则添加 file: 前缀，如：@"file:/var/image.png"；资产则添加 asset: 前缀，如：@"asset:watermark"
 @attention 推流开始前调用本 API 进行参数配置
 */
- (void)setWaterMarkImagePath:(NSString *)filePath;

/**
 设置水印在采集视频中的位置

 @param waterMarkRect 水印的位置与尺寸
 @attention 推流开始前调用本 API 进行参数配置
 @note 左上角为坐标系原点，区域不能超过编码分辨率设置的大小
 */
- (void)setPublishWaterMarkRect:(CGRect)waterMarkRect;

/**
 设置水印在预览视频中的位置

 @param waterMarkRect 水印的位置与尺寸
 @attention 推流开始前调用本 API 进行参数配置
 @note 左上角为坐标系原点，区域不能超过预览视图的大小
 */
- (void)setPreviewWaterMarkRect:(CGRect)waterMarkRect;

/**
 设置音频码率
 
 @param bitrate 码率
 @return true 成功 false 失败
 */
- (bool)setAudioBitrate:(int)bitrate;

/**
 设置音频设备模式
 
 @param mode 模式
 @note 在 Init 前调用
 */
+ (void)setAudioDeviceMode:(ZegoAPIAudioDeviceMode) mode;

/**
 回声消除开关

 @param bEnable true 打开 false 关闭
 @return true 成功 false 失败
 */
- (bool)enableAEC:(bool)enable;

/**
 音频采集自动增益开关

 @param enable 是否开启
 @return true 成功，false 失败
 @note 默认关闭
 */
- (bool)enableAGC:(bool)enable;

/**
 设置外部采集模块
 
 @param factory 工厂对象，遵循 ZegoVideoCaptureFactory 协议的对象
 @attention 必须在 InitSDK 前调用，并且不能置空
 */
+ (void)setVideoCaptureFactory:(id<ZegoVideoCaptureFactory>)factory;

/**
 设置外部滤镜模块

 @param factory 工厂对象，遵循 ZegoVideoFilterFactory 协议的对象
 @attention 必须在 Init 前调用，并且不能置空
 */
+ (void)setVideoFilterFactory:(id<ZegoVideoFilterFactory>)factory;

/**
 发送媒体次要信息开关

 @param start true 开启, false 关闭
 @param onlyAudioPublish true 纯音频直播，不传输视频数据, false 音视频直播，传输视频数据
 @attention onlyAudioPublish 开关在 start 开关开启时才生效
 */
- (void)setMediaSideFlags:(bool)start onlyAudioPublish:(bool)onlyAudioPublish;

/**
 发送媒体次要信息

 @param inData 媒体次要信息数据
 @param dataLen 数据长度
 @param packet 是否外部已经打包好包头，true 已打包, false 未打包
 @attention 主播端开启媒体次要信息开关，并调用此 API 发送媒体次要信息后，观众端在 [ZegoLiveRoomApi (Player) -setMediaSideCallback:] 设置的回调中获取媒体次要信息
 */
- (void)sendMediaSideInfo:(const unsigned char *)inData dataLen:(int)dataLen packet:(bool)packet;

/**
 设置延迟模式

 @param mode 延迟模式，默认 ZEGOAPI_LATENCY_MODE_NORMAL
 @note 在推流前调用
 */
- (void)setLatencyMode:(ZegoAPILatencyMode)mode;

/**
 设置混音音量

 @param volume 0~100
 */
- (void)setAuxVolume:(int)volume;

/**
 是否开启离散音频包发送

 @param enable true 开启，此时关闭麦克风后，不会发送静音包；false 关闭，此时关闭麦克风后会发送静音包
                    默认状态下，关闭麦克风后会发送静音包
 @note 在推流前调用，只有纯 UDP 方案才可以调用此接口
 */
- (void)enableDTX:(bool)enable;

/**
 是否开启流量控制
 
 @param enable true 开启；false 关闭
 @param properties 流量控制属性 (帧率，分辨率）可以多选, 参考ZegoAPITrafficControlProperty定义
 @note 在推流前调用，在纯 UDP 方案才可以调用此接口
 @note 默认开启流量控制，property为ZEGOAPI_TRAFFIC_FPS
*/
- (void)enableTrafficControl:(bool)enable properties:(NSUInteger)properties;

@end


@protocol ZegoLivePublisherDelegate <NSObject>

/**
 推流状态更新

 @param stateCode 状态码
 @param streamID 流 ID
 @param info 推流信息
 @attention 主播调用 [ZegoLiveRoomApi (Publisher) -startPublishing:title:flag:] 推流成功后，通过该 API 通知主播方
 @note 推流状态码及其含义如下：
 stateCode = 0，直播开始
 stateCode = 3，直播遇到严重问题（如出现，请联系 ZEGO 技术支持）
 stateCode = 4，创建直播流失败
 stateCode = 5，获取流信息失败
 stateCode = 6，无流信息
 stateCode = 7，媒体服务器连接失败（请确认推流端是否正常推流、正式环境和测试环境是否设置同一个、网络是否正常）
 stateCode = 8，DNS 解析失败
 stateCode = 9，未登录就直接拉流
 stateCode = 10，逻辑服务器网络错误(网络断开时间过长时容易出现此错误)
 stateCode = 105，发布流名被占用
 */
- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary *)info;

@optional

/**
 收到连麦请求

 @param seq 连麦请求序列号，标识当次连麦请求
 @param userId 来源用户 ID
 @param userName 来源用户名
 @param roomID 房间 ID
 @attention 观众调用 [ZegoLiveRoomApi (Player) -requestJoinLive] 申请连麦后，主播端会收到本通知
 */
- (void)onJoinLiveRequest:(int)seq fromUserID:(NSString *)userId fromUserName:(NSString *)userName roomID:(NSString *)roomID;

/**
 发布质量更新

 @param quality 发布质量，0 ~ 3 分别对应优、良、中、差
 @param streamID 发布流 ID
 @param fps 帧率(frame rate)
 @param kbs 码率(bit rate) kb/s
 @note 调用者可以在此回调中获取当前的视频质量数据，加以处理
 @attention 不建议使用，请用 onPublishQualityUpdate:quality: 代替
 */
- (void)onPublishQualityUpdate:(int)quality stream:(NSString *)streamID videoFPS:(double)fps videoBitrate:(double)kbs;


/**
 发布质量更新

 @param streamID streamID 发布流 ID
 @param quality quality 参考ZegoApiPublishQuality定义
 @attention startPublish 后，该 API 会被多次回调
 @note 调用者可以在此回调中获取当前的视频质量数据，加以处理
 */
- (void)onPublishQualityUpdate:(NSString *)streamID quality:(ZegoApiPublishQuality)quality;

/**
 采集视频的宽度和高度变化通知

 @param size 视频大小
 @attention 发布直播成功后，当视频尺寸变化时，发布者会收到此通知
 */
- (void)onCaptureVideoSizeChangedTo:(CGSize)size;

/**
 混流配置更新结果回调

 @param errorCode 错误码，0 表示没有错误
 @param mixStreamID 混流ID
 @param info 混流播放信息
 @attention 调用 [ZegoLiveRoomApi (Publisher) -setMixStreamConfig:] 设置混流配置，及 [ZegoLiveRoomApi (Publisher) -updateMixInputStreams:] 更新混流配置后，通过此 API 通知调用方
 @note 常见错误码及其含义如下：
 errorCode = 150，混流的输入流不存在
 errorCode = 151，混流失败
 errorCode = 152，停止混流失败
 errorCode = 153，输入参数错误
 errorCode = 154，输出参数错误
 errorCode = 155，输入分辨率格式错误
 errorCode = 156，输出分辨率格式错误
 errorCode = 157，混流没开
 */
- (void)onMixStreamConfigUpdate:(int)errorCode mixStream:(NSString *)mixStreamID streamInfo:(NSDictionary *)info;

/**
 混音数据输入回调

 @param pData 混音数据
 @param pDataLen 缓冲区长度。实际填充长度必须为 0 或是缓冲区长度。0 代表无混音数据
 @param pSampleRate 混音数据采样率，支持16k、32k、44.1k、48k
 @param pChannelCount 混音数据声道数，支持1、2
 @attention 用户调用该 API 将混音数据传递给 SDK
 @note 混音数据 bit depth 必须为 16
 */
- (void)onAuxCallback:(void *)pData dataLen:(int *)pDataLen sampleRate:(int *)pSampleRate channelCount:(int *)pChannelCount;

@end

