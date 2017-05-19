package com.zego.instanttalk2.interfaces;

import com.zego.zegoliveroom.entity.ZegoStreamInfo;

/**
 * Copyright © 2017 Zego. All rights reserved.
 */

public interface OnLiveRoomListener {

    void onDisconnect(int errorCode, String roomID);

    void onStreamAdded(final ZegoStreamInfo[] listStream, final String roomID);

    void onStreamDeleted(final ZegoStreamInfo[] listStream, final String roomID);

}
