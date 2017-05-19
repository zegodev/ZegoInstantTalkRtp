package com.zego.instanttalk2.entities;


import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */
public class GroupInfo implements Serializable {

    private String mGroupID;

    private String mGroupName;

    private String mNewestContent;

    private String mFromUserID;

    private String mFromUserName;

    private long mCreatedTime;

    private int mUnreadMsgCount;

    private List<BizUser> mListUser = new ArrayList<>();

    private List<ChatMsg> mListMsg = new ArrayList<>();

    public long getCreatedTime() {
        return mCreatedTime;
    }

    public void setCreatedTime(long createdTime) {
        mCreatedTime = createdTime;
    }

    public String getFromUserID() {
        return mFromUserID;
    }

    public void setFromUserID(String fromUserID) {
        mFromUserID = fromUserID;
    }

    public String getFromUserName() {
        return mFromUserName;
    }

    public void setFromUserName(String fromUserName) {
        mFromUserName = fromUserName;
    }

    public String getNewestContent() {
        return mNewestContent;
    }

    public void setNewestContent(String newestContent) {
        mNewestContent = newestContent;
    }

    public int getUnreadMsgCount() {
        return mUnreadMsgCount;
    }

    public void setUnreadMsgCount(int unreadMsgCount) {
        mUnreadMsgCount = unreadMsgCount;
    }

    public List<BizUser> getListUser() {
        return mListUser;
    }

    public void addUser(BizUser bizUser) {
        mListUser.add(bizUser);
    }

    public String getGroupID() {
        return mGroupID;
    }

    public void setGroupID(String groupID) {
        mGroupID = groupID;
    }

    public String getGroupName() {
        return mGroupName;
    }

    public void setGroupName(String groupName) {
        mGroupName = groupName;
    }

    public List<ChatMsg> getListMsg() {
        return mListMsg;
    }

    public void addMsg(ChatMsg msg) {
        mListMsg.add(msg);
    }
}
