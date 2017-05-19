package com.zego.instanttalk2.ui.acivities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.constants.IntentExtra;
import com.zego.instanttalk2.entities.BizUser;
import com.zego.instanttalk2.interfaces.OnChatRoomListener;
import com.zego.instanttalk2.presenters.BizLivePresenter;
import com.zego.instanttalk2.utils.CommonUtil;
import com.zego.instanttalk2.utils.PreferenceUtil;
import com.zego.instanttalk2.utils.ZegoRoomUtil;
import com.zego.zegoliveroom.callback.IZegoLoginCompletionCallback;
import com.zego.zegoliveroom.callback.chatroom.IZegoVideoTalkCallback;
import com.zego.zegoliveroom.constants.ZegoConstants;
import com.zego.zegoliveroom.entity.ZegoStreamInfo;
import com.zego.zegoliveroom.entity.ZegoUser;

import java.util.ArrayList;

/**
 * Copyright © 2017 Zego. All rights reserved.
 */

public class HostActivity extends BaseVideoTalkActivity {

    private ArrayList<BizUser> mListToUser = null;

    private int mRefusedCount = 0;

    private int mRequestSeq = - 1;

    /**
     * 启动入口.
     *
     * @param activity 源activity
     */
    public static void actionStart(Activity activity, ArrayList<BizUser> listToUser) {
        Intent intent = new Intent(activity, HostActivity.class);
        intent.putParcelableArrayListExtra(IntentExtra.TO_USERS, listToUser);
        activity.startActivity(intent);
    }


    @Override
    protected void initExtraData(Bundle savedInstanceState) {
        if (savedInstanceState == null) {
            mListToUser = getIntent().getParcelableArrayListExtra(IntentExtra.TO_USERS);
            if (CommonUtil.isListEmpty(mListToUser)) {
                Toast.makeText(this, getString(R.string.member_list_is_empty), Toast.LENGTH_SHORT).show();
                finish();
            }
        }
    }

    @Override
    protected void initVariables(Bundle savedInstanceState) {
        super.initVariables(savedInstanceState);

        BizLivePresenter.getInstance().setChatRoomListener(new OnChatRoomListener() {
            @Override
            public void onConnectState(int state) {

            }

            @Override
            public void onShowRequestMsg(int respondSeq, String fromUserID, String fromUserName, String videoRoomID) {

            }

            @Override
            public void onShowRespondMsg(int respondSeq, String fromUserID, String fromUserName, boolean result) {
                if (result) {
                    showSubMsg(getString(R.string.someone_accepted_your_request, fromUserName));
                    recordLog(getString(R.string.someone_accepted_your_request, fromUserName));
                } else {
                    showSubMsg(getString(R.string.someone_refused_your_request, fromUserName));
                    recordLog(getString(R.string.someone_refused_your_request, fromUserName));

                    mRefusedCount++;
                    if (mRefusedCount == mListToUser.size()) {
                        showMainMsg(getString(R.string.chat_finished));
                        showSubMsg(getString(R.string.all_friends_refused_your_request));
                        recordLog(getString(R.string.myself, getString(R.string.all_friends_refused_your_request)));
                    }
                }
            }

            @Override
            public void onCancelChat(int respondSeq, String fromUserID, String fromUserName) {
            }
        });
    }

    @Override
    protected void doBusiness(Bundle savedInstanceState) {
        super.doBusiness(savedInstanceState);

        mRoomID = ZegoRoomUtil.getRoomID();

        // 登陆房间
        showMainMsg(getString(R.string.start_to_login_room, mRoomID));
        recordLog(getString(R.string.myself, getString(R.string.start_to_login_room, mRoomID)));
        mZegoLiveRoom.loginRoom(mRoomID, ZegoConstants.RoomRole.Anchor, new IZegoLoginCompletionCallback() {
            @Override
            public void onLoginCompletion(int errorCode, ZegoStreamInfo[] zegoStreamInfos) {
                if(errorCode == 0){
                    showMainMsg(getString(R.string.login_room_success, mRoomID));
                    recordLog(getString(R.string.myself, getString(R.string.login_room_success, mRoomID)));

                    mPublishStreamID = ZegoRoomUtil.getPublishStreamID();
                    mPublishTitle = ZegoRoomUtil.getPublishStreamTitle();

                    // 开始推流
                    startPublish();

                    // 请求视频聊天
                    requestVideoTalk();
                }else {
                    showMainMsg(getString(R.string.login_room_success, mRoomID));
                    recordLog(getString(R.string.myself, getString(R.string.login_room_success, mRoomID)));
                }
            }
        });
    }

    private void requestVideoTalk(){

        ZegoUser [] list = new ZegoUser[mListToUser.size()];
        for(int i = 0, size = list.length; i < size; i++){
            ZegoUser zegoUser = new ZegoUser();
            zegoUser.userID = mListToUser.get(i).userID;
            zegoUser.userName = mListToUser.get(i).userName;
            list[i] = zegoUser;
        }

        showMainMsg(getString(R.string.waiting_for_response));
        recordLog(getString(R.string.myself, getString(R.string.waiting_for_response)));
        mRequestSeq = mZegoLiveRoom.requestVideoTalk(list, mRoomID, new IZegoVideoTalkCallback() {
            @Override
            public void onSendComplete(int errorCode) {
                if(errorCode != 0){
                    recordLog(getString(R.string.myself, ": requestVideoTalk failed, errorCode:" + errorCode));
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        mZegoLiveRoom.cancelVideoTalk(mRequestSeq, new IZegoVideoTalkCallback() {
            @Override
            public void onSendComplete(int errorCode) {
                if(errorCode != 0){
                    recordLog(getString(R.string.myself, ": cancelVideoTalk failed, errorCode:" + errorCode));
                }
            }
        });

        // 退出房间
        mZegoLiveRoom.logoutRoom();
    }
}
