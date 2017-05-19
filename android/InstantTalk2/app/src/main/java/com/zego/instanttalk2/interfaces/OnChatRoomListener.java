package com.zego.instanttalk2.interfaces;


/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */
public interface OnChatRoomListener {

    void onConnectState(int state);

    void onShowRequestMsg(int respondSeq, String fromUserID, String fromUserName, String videoRoomID);

    void onShowRespondMsg(int respondSeq, String fromUserID, String fromUserName, boolean result);

    void onCancelChat(int respondSeq, String fromUserID, String fromUserName);
}
