package com.zego.instanttalk2.ui.acivities;

import android.os.Bundle;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.interfaces.OnLiveRoomListener;
import com.zego.instanttalk2.interfaces.OnVideoLiveListener;
import com.zego.instanttalk2.presenters.BizLivePresenter;
import com.zego.zegoliveroom.entity.ZegoStreamInfo;

import java.util.HashMap;

/**
 * Copyright © 2017 Zego. All rights reserved.
 */

public abstract class BaseVideoTalkActivity extends BaseLiveActivity {

    protected int mPlayCount = 0;

    protected HashMap<String, String> mMapStreamToUser = new HashMap<>();

    @Override
    protected void initVariables(Bundle savedInstanceState) {
        super.initVariables(savedInstanceState);

        initCallback();
    }

    private void initCallback(){
        BizLivePresenter.getInstance().setLiveRoomListener(new OnLiveRoomListener() {
            @Override
            public void onDisconnect(int errorCode, String roomID) {
                showMainMsg(getString(R.string.you_have_disconnected));
                recordLog(getString(R.string.myself, getString(R.string.you_have_disconnected)));
            }

            @Override
            public void onStreamAdded(ZegoStreamInfo[] listStream, String roomID) {
                for (ZegoStreamInfo streamInfo : listStream) {
                    recordLog(getString(R.string.someone_created_stream, streamInfo.userName, streamInfo.streamID));
                    startPlay(streamInfo.streamID);
                    // 存储流信息
                    mMapStreamToUser.put(streamInfo.streamID, streamInfo.userName);
                }
            }

            @Override
            public void onStreamDeleted(ZegoStreamInfo[] listStream, String roomID) {
                if (listStream != null && listStream.length > 0) {
                    for (ZegoStreamInfo zegoStreamInfo : listStream) {
                        recordLog(getString(R.string.someone_deleted_stream, zegoStreamInfo.userName, zegoStreamInfo.streamID));
                        stopPlay(zegoStreamInfo.streamID);
                    }
                }
            }
        });

        BizLivePresenter.getInstance().setVideoLiveListener(new OnVideoLiveListener() {
            @Override
            public void onPublishSucc(String streamID, HashMap<String, Object> info) {
                handlePublishSucc(streamID);
            }

            @Override
            public void onPublishStop(int stateCode, String streamID) {
                handlePublishStop(stateCode, streamID);
            }

            @Override
            public void onPlaySucc(String streamID) {
                handlePlaySucc(streamID);
            }

            @Override
            public void onPlayStop(int stateCode, String streamID) {
                handlePlayStop(stateCode, streamID);
            }

            @Override
            public void onPublishQulityUpdate(String streamID, final int quality, final double videoFPS, final double videoBitrate) {
//                ViewLive viewLive = getViewLiveByStreamID(streamID);
//                if (viewLive != null) {
//                    viewLive.setLiveQuality(quality);
//                }
            }

            @Override
            public void onPlayQualityUpdate(String streamID, int quality, double videoFPS, double videoBitrate) {
//                ViewLive viewLive = getViewLiveByStreamID(streamID);
//                if (viewLive != null) {
//                    viewLive.setLiveQuality(quality);
//                }
            }
        });
    }

    @Override
    protected void doBusiness(Bundle savedInstanceState) {
        // 设置视频聊天状态, 此时不接受其它聊天请求
        BizLivePresenter.getInstance().setVideoChatState(true);
    }

    @Override
    protected void afterPlayingSuccess(String streamID) {
        mPlayCount++;
        showSubMsg(getString(R.string.someone_has_entered_the_room, mMapStreamToUser.get(streamID)));
        showMainMsg(getString(R.string.chatting));
    }

    @Override
    protected void afterPlayingStop(String streamID) {
        mPlayCount--;
        showSubMsg(getString(R.string.someone_has_left_the_room, mMapStreamToUser.get(streamID)));
        if (mPlayCount <= 0) {
            showMainMsg(getString(R.string.chat_finished));
            showSubMsg(getString(R.string.all_friends_have_left_the_room));
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // 离开房间
        BizLivePresenter.getInstance().setVideoChatState(false);

        BizLivePresenter.getInstance().setLiveRoomListener(null);
        BizLivePresenter.getInstance().setVideoLiveListener(null);
    }
}
