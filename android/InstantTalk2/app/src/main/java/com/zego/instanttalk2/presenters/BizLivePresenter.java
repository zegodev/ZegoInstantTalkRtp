package com.zego.instanttalk2.presenters;

import android.widget.Toast;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.ZegoApiManager;
import com.zego.instanttalk2.ZegoApplication;
import com.zego.instanttalk2.interfaces.OnChatRoomListener;
import com.zego.instanttalk2.interfaces.OnLiveRoomListener;
import com.zego.instanttalk2.interfaces.OnVideoLiveListener;
import com.zego.zegoliveroom.ZegoLiveRoom;
import com.zego.zegoliveroom.callback.IZegoLivePlayerCallback;
import com.zego.zegoliveroom.callback.IZegoLivePublisherCallback;
import com.zego.zegoliveroom.callback.IZegoRoomCallback;
import com.zego.zegoliveroom.callback.chatroom.IZegoChatRoomCallback;
import com.zego.zegoliveroom.callback.chatroom.IZegoLoginChatRoomCallback;
import com.zego.zegoliveroom.callback.chatroom.IZegoVideoTalkCallback;
import com.zego.zegoliveroom.constants.ZegoConstants;
import com.zego.zegoliveroom.entity.AuxData;
import com.zego.zegoliveroom.entity.ZegoConversationMessage;
import com.zego.zegoliveroom.entity.ZegoRoomMessage;
import com.zego.zegoliveroom.entity.ZegoStreamInfo;
import com.zego.zegoliveroom.entity.ZegoUserState;

import java.util.HashMap;


/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */
public class BizLivePresenter {

    private static BizLivePresenter sInstance;

    /**
     * 业务类实例.
     */
    private ZegoLiveRoom mZegoLiveRoom;

    /**
     * 公共房间监听器.
     */
    private volatile OnChatRoomListener mChatRoomListener = null;

    private volatile OnVideoLiveListener mVideoLiveListener = null;

    private volatile OnLiveRoomListener mLiveRoomListener = null;

    private volatile boolean mIsVideoChatting = false;

    private volatile boolean mHaveBeenLogined = false;

    private BizLivePresenter() {
        mZegoLiveRoom = ZegoApiManager.getInstance().getZegoLiveRoom();
    }

    public static BizLivePresenter getInstance() {
        if (sInstance == null) {
            synchronized (BizLivePresenter.class) {
                if (sInstance == null) {
                    sInstance = new BizLivePresenter();
                }
            }
        }
        return sInstance;
    }

    public void setChatRoomListener(OnChatRoomListener chatRoomListener) {
        mChatRoomListener = chatRoomListener;
    }

    public void setVideoLiveListener(OnVideoLiveListener videoLiveListener) {
        mVideoLiveListener = videoLiveListener;
    }

    public void setLiveRoomListener(OnLiveRoomListener liveRoomListener) {
        mLiveRoomListener = liveRoomListener;
    }

    public void init() {
        initCallback();
    }

    private void initCallback() {
        mZegoLiveRoom.setZegoChatRoomCallback(new IZegoChatRoomCallback() {
            @Override
            public void onKickOutChatRoom(int reason) {
                final OnChatRoomListener chatRoomListener = mChatRoomListener;
                if (chatRoomListener != null) {

                }
            }

            @Override
            public void onConnectState(int state) {
                final OnChatRoomListener chatRoomListener = mChatRoomListener;
                if (chatRoomListener != null) {
                    chatRoomListener.onConnectState(state);
                }
            }

            @Override
            public void onChatRoomUserUpdate(ZegoUserState[] listUser, int updateType) {
                UserListPresenter.getInstance().updateUserList(listUser, updateType);
            }

            @Override
            public void onRecvBroadMessage(ZegoRoomMessage[] listMessage) {
                final OnChatRoomListener chatRoomListener = mChatRoomListener;
                if (chatRoomListener != null) {

                }
            }

            @Override
            public void onRecvGroupChatMessage(String groupID, ZegoConversationMessage message) {
                TextMessagePresenter.getInstance().receiveGroupMsg(groupID, message);
            }

            @Override
            public void onRecvRequestVideoTalk(final int respondSeq, final String fromUserID, final String fromUserName, final String videoRoomID) {
                // 用户正在视频中，拒绝其他聊天请求
                if (mIsVideoChatting) {
                    mZegoLiveRoom.respondVideoTalk(respondSeq, false, new IZegoVideoTalkCallback() {
                        @Override
                        public void onSendComplete(int errorCode) {
                        }
                    });
                } else {
                    final OnChatRoomListener chatRoomListener = mChatRoomListener;
                    if (chatRoomListener != null) {
                        chatRoomListener.onShowRequestMsg(respondSeq, fromUserID, fromUserName, videoRoomID);
                    }
                }
            }

            @Override
            public void onRecvCancelVideoTalk(final int respondSeq, final String fromUserID, final String fromUserName) {
                final OnChatRoomListener chatRoomListener = mChatRoomListener;
                if (chatRoomListener != null) {
                    chatRoomListener.onCancelChat(respondSeq, fromUserID, fromUserName);
                }
            }

            @Override
            public void onRecvRespondVideoTalk(int respondSeq, String fromUserID, String fromUserName, boolean result) {
                final OnChatRoomListener chatRoomListener = mChatRoomListener;
                if (chatRoomListener != null) {
                    chatRoomListener.onShowRespondMsg(respondSeq, fromUserID, fromUserName, result);
                }
            }
        });

        mZegoLiveRoom.setZegoLivePublisherCallback(new IZegoLivePublisherCallback() {
            @Override
            public void onPublishStateUpdate(int stateCode, String streamID, HashMap<String, Object> streamInfo) {
                final OnVideoLiveListener videoLiveListener = mVideoLiveListener;
                if (videoLiveListener != null) {
                    if (stateCode == 0) {
                        videoLiveListener.onPublishSucc(streamID, streamInfo);
                    } else {
                        videoLiveListener.onPublishStop(stateCode, streamID);
                    }
                }
            }

            @Override
            public void onJoinLiveRequest(final int seq, String fromUserID, String fromUserName, String roomID) {
            }

            @Override
            public void onPublishQualityUpdate(String streamID, int quality, double videoFPS, double videoBitrate) {
                final OnVideoLiveListener videoLiveListener = mVideoLiveListener;
                if (videoLiveListener != null) {
                    videoLiveListener.onPublishQulityUpdate(streamID, quality, videoFPS, videoBitrate);
                }
            }

            @Override
            public AuxData onAuxCallback(int dataLen) {
                return null;
            }

            @Override
            public void onCaptureVideoSizeChangedTo(int width, int height) {

            }

            @Override
            public void onMixStreamConfigUpdate(int errorCode, String streamID, HashMap<String, Object> streamInfo) {

            }
        });

        mZegoLiveRoom.setZegoLivePlayerCallback(new IZegoLivePlayerCallback() {
            @Override
            public void onPlayStateUpdate(int stateCode, String streamID) {
                final OnVideoLiveListener videoLiveListener = mVideoLiveListener;
                if (videoLiveListener != null) {
                    if (stateCode == 0) {
                        videoLiveListener.onPlaySucc(streamID);
                    } else {
                        videoLiveListener.onPlayStop(stateCode, streamID);
                    }
                }
            }

            @Override
            public void onPlayQualityUpdate(String streamID, int quality, double videoFPS, double videoBitrate) {
                final OnVideoLiveListener videoLiveListener = mVideoLiveListener;
                if (videoLiveListener != null) {
                    videoLiveListener.onPlayQualityUpdate(streamID, quality, videoFPS, videoBitrate);
                }
            }

            @Override
            public void onInviteJoinLiveRequest(int seq, String fromUserID, String fromUserName, String roomID) {

            }

            @Override
            public void onVideoSizeChangedTo(String streamID, int width, int height) {
            }
        });

        mZegoLiveRoom.setZegoRoomCallback(new IZegoRoomCallback() {
            @Override
            public void onKickOut(int reason, String roomID) {

            }

            @Override
            public void onDisconnect(int errorCode, String roomID) {
                final OnLiveRoomListener liveRoomListener = mLiveRoomListener;
                if (liveRoomListener != null) {
                    liveRoomListener.onDisconnect(errorCode, roomID);
                }
            }

            @Override
            public void onStreamUpdated(final int type, final ZegoStreamInfo[] listStream, final String roomID) {
                final OnLiveRoomListener liveRoomListener = mLiveRoomListener;
                if (liveRoomListener != null) {
                    if (type == ZegoConstants.StreamUpdateType.Added) {
                        liveRoomListener.onStreamAdded(listStream, roomID);
                    } else if (type == ZegoConstants.StreamUpdateType.Deleted) {
                        liveRoomListener.onStreamDeleted(listStream, roomID);
                    }
                }
            }

            @Override
            public void onStreamExtraInfoUpdated(ZegoStreamInfo[] zegoStreamInfos, String s) {

            }

            @Override
            public void onRecvCustomCommand(String userID, String userName, String content, String roomID) {

            }
        });

    }

    public void setVideoChatState(boolean isVideoChatting) {
        mIsVideoChatting = isVideoChatting;
    }

    public void loginChatRoom() {
        // 登录聊天室
        ZegoApiManager.getInstance().getZegoLiveRoom().loginChatRoomWithCompletion(new IZegoLoginChatRoomCallback() {
            @Override
            public void onLoginChatRoom(int errorCode) {
                if (errorCode == 0) {
                    mHaveBeenLogined = true;
                    Toast.makeText(ZegoApplication.sApplicationContext, ZegoApplication.sApplicationContext.getString(R.string.login_chat_room_success), Toast.LENGTH_SHORT).show();
                } else {
                    mHaveBeenLogined = false;
                    Toast.makeText(ZegoApplication.sApplicationContext, ZegoApplication.sApplicationContext.getString(R.string.login_chat_room_fail), Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    public void logoutChatRoom(){
        if(mHaveBeenLogined){
            mHaveBeenLogined = false;
            mZegoLiveRoom.logoutChatRoom();
        }
    }
}