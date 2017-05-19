package com.zego.instanttalk2.ui.acivities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.Toast;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.constants.IntentExtra;
import com.zego.instanttalk2.utils.PreferenceUtil;
import com.zego.instanttalk2.utils.ZegoRoomUtil;
import com.zego.zegoliveroom.callback.IZegoLoginCompletionCallback;
import com.zego.zegoliveroom.constants.ZegoConstants;
import com.zego.zegoliveroom.entity.ZegoStreamInfo;

/**
 * Copyright © 2017 Zego. All rights reserved.
 */

public class GuestActivity extends BaseVideoTalkActivity {

    /**
     * 启动入口.
     *
     * @param activity 源activity
     */
    public static void actionStart(Activity activity, String  roomID) {
        Intent intent = new Intent(activity, GuestActivity.class);
        intent.putExtra(IntentExtra.ROOM_ID, roomID);
        activity.startActivity(intent);
    }

    @Override
    protected void initExtraData(Bundle savedInstanceState) {
        mRoomID = getIntent().getStringExtra(IntentExtra.ROOM_ID);
        if(TextUtils.isEmpty(mRoomID)){
            Toast.makeText(this, getString(R.string.room_id_is_empty), Toast.LENGTH_SHORT).show();
            finish();
        }
    }

    @Override
    protected void doBusiness(Bundle savedInstanceState) {
        super.doBusiness(savedInstanceState);

        // 登陆房间
        showMainMsg(getString(R.string.start_to_login_room, mRoomID));
        recordLog(getString(R.string.myself, getString(R.string.start_to_login_room, mRoomID)));
        mZegoLiveRoom.loginRoom(mRoomID, ZegoConstants.RoomRole.Audience, new IZegoLoginCompletionCallback() {
            @Override
            public void onLoginCompletion(int errorCode, ZegoStreamInfo[] zegoStreamInfos) {
                if(errorCode == 0){
                    showMainMsg(getString(R.string.login_room_success, mRoomID));
                    recordLog(getString(R.string.myself, getString(R.string.login_room_success, mRoomID)));

                    mPublishStreamID = ZegoRoomUtil.getPublishStreamID();
                    mPublishTitle = ZegoRoomUtil.getPublishStreamTitle();

                    // 开始推流
                    startPublish();

                    if(zegoStreamInfos != null && zegoStreamInfos.length > 0){
                        for(ZegoStreamInfo info : zegoStreamInfos){
                            startPlay(info.streamID);

                            mMapStreamToUser.put(info.streamID, info.userName);
                        }
                    }
                }else {
                    showMainMsg(getString(R.string.login_room_success, mRoomID));
                    recordLog(getString(R.string.myself, getString(R.string.login_room_success, mRoomID)));
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // 退出房间
        mZegoLiveRoom.logoutRoom();
    }
}
