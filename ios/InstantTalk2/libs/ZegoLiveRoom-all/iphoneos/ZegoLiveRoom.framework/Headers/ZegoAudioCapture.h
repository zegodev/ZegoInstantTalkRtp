//
//  ZegoAudioCapture.h
//  ZegoLiveRoom
//
//  Created by Strong on 2017/3/16.
//  Copyright © 2017年 zego. All rights reserved.
//

#ifndef ZegoAudioCapture_h
#define ZegoAudioCapture_h

#ifndef ZEGOAudioInOutput_h
#define ZEGOAudioInOutput_h

namespace AVE
{
    struct AudioFrame
    {
        int frameType;              /**< 帧类型，只支持 pcm 类型，pcm:0x1001 */
        int samples;                /**< 当前帧中的采样数 */
        int bytesPerSample;         /**< 每份采样中的的字节数，只支持 2 字节 */
        int channels;               /**< 通道数 */
        int sampleRate;             /**< 采样率 */
        void *buffer;               /**< 数据 buffer，调用者负责它的内存分配与释放 */
    };
    
    class IAudioDataInOutput
    {
    public:
        virtual void startCapture() = 0;    /**< 开始音频外部采集 */
        virtual void stopCapture() = 0;     /**< 停止音频外部采集 */
        virtual void startRender() = 0;     /**< 开始音频外部渲染 */
        virtual void stopRender() = 0;      /**< 停止音频外部渲染 */
        
        /**
         外部采集的原始音频数据输入

         @param audioFrame 音频帧数据
         @return true 成功，false 失败
         @attention 开发者调用此 API，将原始音频数据输入
         */
        virtual bool onRecordAudioFrame(AudioFrame& audioFrame) = 0;
        
        /**
         音频数据外部渲染回调

         @param audioFrame 音频帧数据
         @return true 成功，false 失败
         @attention 开发者在此 API 中，获取 SDK 传递出去的原始音频数据
         */
        virtual bool onPlaybackAudioFrame(AudioFrame& audioFrame) = 0;
    };
}

#endif

#endif /* ZegoAudioCapture_h */
