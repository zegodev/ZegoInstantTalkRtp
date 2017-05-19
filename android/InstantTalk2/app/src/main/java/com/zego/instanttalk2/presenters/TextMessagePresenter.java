package com.zego.instanttalk2.presenters;

import android.text.TextUtils;

import com.zego.instanttalk2.ZegoApiManager;
import com.zego.instanttalk2.entities.BizUser;
import com.zego.instanttalk2.entities.ChatMsg;
import com.zego.instanttalk2.entities.GroupInfo;
import com.zego.instanttalk2.interfaces.OnUpdateMsgListListener;
import com.zego.instanttalk2.interfaces.OnUpdateSessionInfoListener;
import com.zego.instanttalk2.utils.PreferenceUtil;
import com.zego.zegoliveroom.ZegoLiveRoom;
import com.zego.zegoliveroom.callback.chatroom.IZegoGroupChatInfoCallback;
import com.zego.zegoliveroom.callback.chatroom.IZegoGroupChatMessageCallback;
import com.zego.zegoliveroom.constants.ZegoIM;
import com.zego.zegoliveroom.entity.ZegoConversationInfo;
import com.zego.zegoliveroom.entity.ZegoConversationMessage;
import com.zego.zegoliveroom.entity.ZegoUser;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */
public class TextMessagePresenter {

    private static TextMessagePresenter sInstance = null;

    private LinkedList<GroupInfo> mListGroupInfo = new LinkedList<>();

    private OnUpdateSessionInfoListener mUpdateSessionInfoListener = null;

    private OnUpdateMsgListListener mUpdateMsgListListener = null;

    private int mUnreadMessageTotalCount = 0;

    private ZegoLiveRoom mZegoLiveRoom = null;

    private String mCurrentGroupID = null;

    private TextMessagePresenter() {
        mZegoLiveRoom = ZegoApiManager.getInstance().getZegoLiveRoom();
    }

    public static TextMessagePresenter getInstance() {
        if (sInstance == null) {
            synchronized (TextMessagePresenter.class) {
                if (sInstance == null) {
                    sInstance = new TextMessagePresenter();
                }
            }
        }
        return sInstance;
    }

    public void openGroup(String groupID) {
        if (!TextUtils.isEmpty(groupID)) {
            mCurrentGroupID = groupID;
        }
    }

    public void closeGroup(String groupID) {
        if (!TextUtils.isEmpty(groupID) && groupID.equals(mCurrentGroupID)) {
            mCurrentGroupID = null;
        }
    }

    public void deleteGroup(String groupID) {

        // 删除sessionInfo以及相应的消息列表
        for (GroupInfo groupInfo : mListGroupInfo) {
            if (groupInfo.getGroupID().equals(groupID)) {
                mListGroupInfo.remove(groupInfo);
                break;
            }
        }

        // 更新界面
        if (mUpdateSessionInfoListener != null) {
            mUpdateSessionInfoListener.onUpdateGroupInfo(mListGroupInfo, mUnreadMessageTotalCount);
        }
    }

    public void setUpdateSessionInfoListener(final OnUpdateSessionInfoListener listener) {
        mUpdateSessionInfoListener = listener;

        if (listener != null) {
            mUpdateSessionInfoListener.onUpdateGroupInfo(mListGroupInfo, mUnreadMessageTotalCount);
        }
    }

    public void setUpdateMsgListListener(final String groupID, ArrayList<BizUser> listToUser, final OnUpdateMsgListListener listener) {
        mUpdateMsgListListener = listener;
        if (listener != null) {
            GroupInfo groupInfo = getGroupInfoByID(groupID);

            if(groupInfo == null && listToUser != null && listToUser.size() == 1){
                for (GroupInfo group : mListGroupInfo){
                    if(group.getListUser().size() == 1){
                        if(group.getListUser().get(0).userID.equals(listToUser.get(0).userID)){
                            groupInfo = group;
                            break;
                        }
                    }
                }
            }
            if (groupInfo != null) {
                mUpdateMsgListListener.onShowAllMsg(groupInfo.getGroupID(), groupInfo.getListMsg());
            }
        }
    }

    public OnUpdateMsgListListener getUpdateMsgListListener() {
        return mUpdateMsgListListener;
    }

    public void readAllMessage() {
        mUnreadMessageTotalCount = 0;
    }

    private GroupInfo getGroupInfoByID(String groupID) {

        GroupInfo targetGroupInfo = null;
        for (GroupInfo groupInfo : mListGroupInfo) {
            if (groupInfo.getGroupID().equals(groupID)) {
                targetGroupInfo = groupInfo;
                break;
            }
        }

        return targetGroupInfo;
    }

    private GroupInfo createGroup(String groupID, String groupName, ZegoUser[] listMember) {
        GroupInfo groupInfo = new GroupInfo();

        groupInfo.setGroupID(groupID);
        groupInfo.setGroupName(groupName);
        if (listMember != null) {
            for (ZegoUser zegoUser : listMember) {
                BizUser bizUser = new BizUser();
                bizUser.userID = zegoUser.userID;
                bizUser.userName = zegoUser.userName;
                groupInfo.addUser(bizUser);
            }
        }

        return groupInfo;
    }

    private void updateGroupInfo(GroupInfo groupInfo, String fromUserID, final String fromUserName, String content, long time, int unReadMsgCount) {
        if (groupInfo == null) {
            return;
        }

        groupInfo.setFromUserID(fromUserID);
        groupInfo.setFromUserName(fromUserName);
        groupInfo.setNewestContent(content);
        groupInfo.setCreatedTime(time);
        groupInfo.setUnreadMsgCount(unReadMsgCount);

        if (!groupInfo.getGroupID().equals(mCurrentGroupID)) {
            mUnreadMessageTotalCount += 1;
            groupInfo.setUnreadMsgCount(unReadMsgCount + 1);
        }

        // 通知界面更新消息
        if (mUpdateSessionInfoListener != null) {
            mUpdateSessionInfoListener.onUpdateGroupInfo(mListGroupInfo, mUnreadMessageTotalCount);
            mUpdateSessionInfoListener.onNotifyMsgComing(fromUserName);
        }
    }

    private void updateMsg(final GroupInfo groupInfo, String fromUserID, String fromUserName, String content, int type) {
        if (groupInfo == null) {
            return;
        }

        ChatMsg newMsg = new ChatMsg();
        newMsg.setFromUserID(fromUserID);
        newMsg.setFromUserName(fromUserName);
        newMsg.setContent(content);
        newMsg.setType(type);
        newMsg.setGroupID(groupInfo.getGroupID());

        // 增加最新消息
        groupInfo.addMsg(newMsg);

        // 通知界面更新消息
        final List<ChatMsg> listMsg = groupInfo.getListMsg();
        if (mUpdateMsgListListener != null) {
            mUpdateMsgListListener.onShowAllMsg(groupInfo.getGroupID(), listMsg);
        }
    }


    public void receiveGroupMsg(String groupID, final ZegoConversationMessage message) {

        GroupInfo targetGroupInfo = getGroupInfoByID(groupID);
        if (targetGroupInfo == null) {
            mZegoLiveRoom.getGroupChatInfo(groupID, new IZegoGroupChatInfoCallback() {
                @Override
                public void onGetGroupChatInfo(int errorCode, String groupID, ZegoConversationInfo info) {
                    if (errorCode == 0) {
                        // 创建新的session
                        GroupInfo newGroupInfo = createGroup(groupID, info.conversationName, info.listMember);
                        mListGroupInfo.addFirst(newGroupInfo);
                        updateGroupInfo(newGroupInfo, message.fromUserID, message.fromUserName, message.content, message.sendTime, 0);
                        updateMsg(newGroupInfo, message.fromUserID, message.fromUserName, message.content, ChatMsg.VALUE_RIGHT_TEXT);
                    } else {
                        // Todo print log
                    }
                }
            });
        } else {
            mListGroupInfo.remove(targetGroupInfo);
            mListGroupInfo.addFirst(targetGroupInfo);
            updateGroupInfo(targetGroupInfo, message.fromUserID, message.fromUserName, message.content, message.sendTime, targetGroupInfo.getUnreadMsgCount());
            updateMsg(targetGroupInfo, message.fromUserID, message.fromUserName, message.content, ChatMsg.VALUE_LEFT_TEXT);
        }
    }


    public void sendGroupMsg(final String groupID, String groupName, ZegoUser[] listToUser, final String content) {

        GroupInfo targetGroupInfo = getGroupInfoByID(groupID);
        final String fromUserID = PreferenceUtil.getInstance().getUserID();
        final String fromUserName = PreferenceUtil.getInstance().getUserName();

        mZegoLiveRoom.sendGroupChatMessage(ZegoIM.MessageType.Text, groupID, content, new IZegoGroupChatMessageCallback() {
            @Override
            public void onSendGroupChatMessage(int errorCode, String groupID, long messageID) {

            }
        });

        if (targetGroupInfo == null) {

            GroupInfo newGroupInfo = createGroup(groupID, groupName, listToUser);

            mListGroupInfo.addFirst(newGroupInfo);
            updateGroupInfo(newGroupInfo, fromUserID, fromUserName, content, System.currentTimeMillis() / 1000, 0);
            updateMsg(newGroupInfo, fromUserID, fromUserName, content, ChatMsg.VALUE_RIGHT_TEXT);

        } else {
            mListGroupInfo.remove();
            mListGroupInfo.addFirst(targetGroupInfo);

            updateGroupInfo(targetGroupInfo, fromUserID, fromUserName, content, System.currentTimeMillis() / 1000, targetGroupInfo.getUnreadMsgCount());
            updateMsg(targetGroupInfo, fromUserID, fromUserName, content, ChatMsg.VALUE_RIGHT_TEXT);
        }
    }
}
