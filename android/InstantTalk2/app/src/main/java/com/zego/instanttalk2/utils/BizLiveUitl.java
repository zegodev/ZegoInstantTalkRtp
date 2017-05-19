package com.zego.instanttalk2.utils;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.zego.instanttalk2.ZegoApplication;
import com.zego.instanttalk2.entities.BizUser;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */
public class BizLiveUitl {

    public static final String KEY_TALK_COMMAND = "command";
    public static final String KEY_TALK_FROM_USER = "fromUser";
    public static final String KEY_TALK_TO_USER = "toUser";
    public static final String KEY_TALK_USER_ID = "UserId";
    public static final String KEY_TALK_USER_NAME = "UserName";
    public static final String KEY_TALK_CONTENT = "content";

    public static final String KEY_MESSAGE_COMMAND = "chat";
    public static final String KEY_MESSAGE_SESSION = "session";

    public static final String KEY_VIDEO_REQUEST_COMMAND = "requestTalk";
    public static final String KEY_VIDEO_RESPOND_COMMAND = "respondTalk";
    public static final String KEY_VIDEO_CANCEL_COMMAND = "cancelTalk";
    public static final String KEY_VIDEO_MAGIC = "magic";
    public static final String KEY_VIDEO_ROOMID = "roomID";
    public static final String KEY_VIDEO_AGREE = "yes";
    public static final String KEY_VIDEO_DISAGREE = "no";

    public static Bitmap getAvatarByUserID(String userID) {

        if(TextUtils.isEmpty(userID) || !TextUtils.isDigitsOnly(userID)){
            return null;
        }

        Bitmap avatar = null;

        long userIDValue = Long.valueOf(userID);
        int indexBase = 86;
        int indexEnd = 132;

        String avatarName = "emoji_" + (userIDValue % (indexEnd - indexBase + 1) + indexBase) + ".png";

        AssetManager am = ZegoApplication.sApplicationContext.getAssets();
        try {
            InputStream is = am.open(avatarName);
            avatar = BitmapFactory.decodeStream(is);
            is.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return avatar;
    }

    public static String getChannel(long roomKey, long serverKey) {
        return "0x" + Long.toHexString(roomKey) + "-0x" + Long.toHexString(serverKey);
    }

    public static String generateUserID(){
        String userID = System.currentTimeMillis() + "";
        if(userID.length() > 9){
            userID = userID.substring(userID.length() - 9);
        }

        return userID;
    }

    public static String generateUserName(String userID){
        return "Android-" + userID;
    }


    /**
     * 格式化消息.
     */
    public static String formatVideoChatMsg(String command, List<BizUser> listToUsers, String magic, boolean isAgreed, long roomKey) {

        if (TextUtils.isEmpty(command) || TextUtils.isEmpty(magic)) {
            return null;
        }

        Map<String, Object> sendInfo = new HashMap<>();

        sendInfo.put(KEY_TALK_COMMAND, command);
        sendInfo.put(KEY_VIDEO_MAGIC, magic);

        HashMap<String, String> mapFromUser = new HashMap<>();
        mapFromUser.put(KEY_TALK_USER_ID, PreferenceUtil.getInstance().getUserID());
        mapFromUser.put(KEY_TALK_USER_NAME, PreferenceUtil.getInstance().getUserName());
        sendInfo.put(KEY_TALK_FROM_USER, mapFromUser);

        List<HashMap<String, String>> listMapToUsers = new ArrayList<>();
        for (BizUser user : listToUsers) {
            HashMap<String, String> mapUser = new HashMap<>();
            mapUser.put(KEY_TALK_USER_ID, user.userID);
            mapUser.put(KEY_TALK_USER_NAME, user.userName);
            listMapToUsers.add(mapUser);
        }
        sendInfo.put(KEY_TALK_TO_USER, listMapToUsers);

        if (command.equals(KEY_VIDEO_RESPOND_COMMAND)) {
            String content = KEY_VIDEO_AGREE;
            if (!isAgreed) {
                content = KEY_VIDEO_DISAGREE;
            }
            sendInfo.put(KEY_TALK_CONTENT, content);
        }

        sendInfo.put(KEY_VIDEO_ROOMID, roomKey);

        return (new Gson()).toJson(sendInfo);
    }

    /**
     * 格式化文本消息.
     */
    public static String  formatTextMsg(final String session, final List<BizUser> listToUser, final String content) {
        if (TextUtils.isEmpty(session) || TextUtils.isEmpty(content) || listToUser == null || listToUser.size() == 0) {
            return null;
        }

        Map<String, Object> sendInfo = new HashMap<>();

        sendInfo.put(KEY_TALK_COMMAND, KEY_MESSAGE_COMMAND);
        sendInfo.put(KEY_MESSAGE_SESSION, session);

        HashMap<String, String> mapFromUser = new HashMap<>();
        mapFromUser.put(KEY_TALK_USER_ID, PreferenceUtil.getInstance().getUserID());
        mapFromUser.put(KEY_TALK_USER_NAME, PreferenceUtil.getInstance().getUserName());
        sendInfo.put(KEY_TALK_FROM_USER, mapFromUser);

        List<HashMap<String, String>> listMapToUsers = new ArrayList<>();
        for (BizUser user : listToUser) {
            HashMap<String, String> mapUser = new HashMap<>();
            mapUser.put(KEY_TALK_USER_ID, user.userID);
            mapUser.put(KEY_TALK_USER_NAME, user.userName);
            listMapToUsers.add(mapUser);
        }
        sendInfo.put(KEY_TALK_TO_USER, listMapToUsers);

        sendInfo.put(KEY_TALK_CONTENT, content);

        return (new Gson()).toJson(sendInfo);
    }
}
