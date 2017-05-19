package com.zego.instanttalk2.ui.widgets;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.TextureView;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.zego.instanttalk2.R;
import com.zego.zegoliveroom.ZegoLiveRoom;

/**
 * Copyright © 2017 Zego. All rights reserved.
 * des: 直播view.
 */
public class ViewLive extends RelativeLayout {

    /**
     * 推拉流颜色.
     */
    private TextView mTvQualityColor;

    /**
     * 推拉流质量.
     */
    private TextView mTvQuality;


    /**
     * 用于渲染视频.
     */
    private TextureView mTextureView;

    private int[] mArrColor;

    private String[] mArrLiveQuality;

    private Resources mResources;

    private View mRootView;

    private ZegoLiveRoom mZegoLiveRoom = null;

    /**
     * 推拉流质量.
     */
    private int mLiveQuality = 0;

    private String mStreamID = null;

    private boolean mIsPublishView = false;

    private boolean mIsPlayView = false;


    public ViewLive(Context context) {
        super(context);
    }

    public ViewLive(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ViewLive(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.ViewLive, defStyleAttr, 0);
        boolean isBigView = a.getBoolean(R.styleable.ViewLive_isBigView, false);
        a.recycle();

        initViews(context, isBigView);
    }

    public void setZegoLiveRoom(ZegoLiveRoom zegoLiveRoom) {
        mZegoLiveRoom = zegoLiveRoom;
    }

    private void initViews(Context context, boolean isBigView) {

        mResources = context.getResources();

        mArrColor = new int[4];
        mArrColor[0] = R.drawable.circle_green;
        mArrColor[1] = R.drawable.circle_yellow;
        mArrColor[2] = R.drawable.circle_red;
        mArrColor[3] = R.drawable.circle_gray;

        mArrLiveQuality = mResources.getStringArray(R.array.live_quality);

        if (isBigView) {
            mRootView = LayoutInflater.from(context).inflate(R.layout.view_live_big, this);
        } else {
            mRootView = LayoutInflater.from(context).inflate(R.layout.view_live, this);
        }

        mTextureView = (TextureView) mRootView.findViewById(R.id.textureView);
        mTvQualityColor = (TextView) mRootView.findViewById(R.id.tv_quality_color);
        mTvQuality = (TextView) mRootView.findViewById(R.id.tv_live_quality);
        mTvQuality.setVisibility(View.GONE);
    }

    /**
     * 返回view是否为"空闲"状态.
     */
    public boolean isFree() {
        return TextUtils.isEmpty(mStreamID);
    }

    /**
     * 释放view.
     */
    public void setFree() {
        mLiveQuality = 0;
        setVisibility(View.INVISIBLE);

        mStreamID = null;
        mIsPublishView = false;
        mIsPlayView = false;
    }


    /**
     * 交换view, 通常是跟大的View交换.
     */
    public void toExchangeView(ViewLive vlBigView) {
        // 交换view
        if (vlBigView.isPublishView()) {
            if (mZegoLiveRoom != null) {
                mZegoLiveRoom.setPreviewView(mTextureView);
            }
        } else if (vlBigView.isPlayView()) {
            if (mZegoLiveRoom != null) {
                mZegoLiveRoom.updatePlayView(vlBigView.getStreamID(), mTextureView);
            }
        }

        // 交换view
        if (isPublishView()) {
            if (mZegoLiveRoom != null) {
                mZegoLiveRoom.setPreviewView(vlBigView.getTextureView());
            }
        } else if (isPlayView()) {
            if (mZegoLiveRoom != null) {
                mZegoLiveRoom.updatePlayView(mStreamID, vlBigView.getTextureView());
            }
        }

        // 交换流信息
        String streamIDTemp = mStreamID;
        mStreamID = vlBigView.getStreamID();
        vlBigView.setStreamID(streamIDTemp);

        boolean isPublishViewTemp = mIsPublishView;
        mIsPublishView = vlBigView.isPublishView();
        vlBigView.setPublishView(isPublishViewTemp);

        boolean isPlayViewTemp = mIsPlayView;
        mIsPlayView = vlBigView.isPlayView();
        vlBigView.setPlayView(isPlayViewTemp);

//        // 交换quality
//        int liveQualityOfBigView = vlBigView.getLiveQuality();
//        int liveQualityOfSmallView = mLiveQuality;
//        vlBigView.setLiveQuality(liveQualityOfSmallView);
//        setLiveQuality(liveQualityOfBigView);
    }

    /**
     * 设置播放质量.
     */
    public void setLiveQuality(int quality) {
        if (quality >= 0 && quality <= 3) {
            mLiveQuality = quality;
            mTvQualityColor.setBackgroundResource(mArrColor[quality]);
            mTvQuality.setText(mResources.getString(R.string.live_quality, mArrLiveQuality[quality]));
        }
    }



    public int getLiveQuality() {
        return mLiveQuality;
    }

    public TextureView getTextureView() {
        return mTextureView;
    }


    public void setStreamID(String streamID) {
        mStreamID = streamID;
    }

    public String getStreamID(){
        return mStreamID;
    }

    public boolean isPublishView(){
        return mIsPublishView;
    }

    public boolean isPlayView() {
        return mIsPlayView;
    }

    public void setPublishView(boolean publishView) {
        mIsPublishView = publishView;
    }

    public void setPlayView(boolean playView) {
        mIsPlayView = playView;
    }
}
