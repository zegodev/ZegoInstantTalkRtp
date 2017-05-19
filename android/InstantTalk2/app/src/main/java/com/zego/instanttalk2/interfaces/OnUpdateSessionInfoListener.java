package com.zego.instanttalk2.interfaces;

import com.zego.instanttalk2.entities.GroupInfo;

import java.util.LinkedList;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public interface OnUpdateSessionInfoListener {
    void onUpdateGroupInfo(LinkedList<GroupInfo> listGroupInfo, int unreadMsgTotalCount);
    void onNotifyMsgComing(String fromUserName);
}
