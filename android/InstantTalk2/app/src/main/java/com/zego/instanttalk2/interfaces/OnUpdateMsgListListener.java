package com.zego.instanttalk2.interfaces;

import com.zego.instanttalk2.entities.ChatMsg;

import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public interface OnUpdateMsgListListener{
        void onShowAllMsg(String grouID, List<ChatMsg> listMsg);
}
