package com.zego.instanttalk2.utils;

import com.zego.zegoliveroom.constants.ZegoBeauty;

/**
 * Copyright © 2017 Zego. All rights reserved.
 */
public class ZegoRoomUtil {

    public static String getRoomID(){
        String roomID = "android_room-" + PreferenceUtil.getInstance().getUserID();

        return roomID;
    }

    public static String getPublishStreamID(){
        return "s-" + PreferenceUtil.getInstance().getUserID() + "-" + System.currentTimeMillis();
    }

    public static String getPublishStreamTitle(){
        return "Hello-" + PreferenceUtil.getInstance().getUserName();
    }

    public static int getZegoBeauty(int index){

        int beauty = 0;

        switch (index) {
            case 0:
                beauty = ZegoBeauty.NONE;
                break;
            case 1:
                beauty = ZegoBeauty.POLISH;
                break;
            case 2:
                beauty = ZegoBeauty.WHITEN;
                break;
            case 3:
                beauty = ZegoBeauty.POLISH | ZegoBeauty.WHITEN;
                break;
            case 4:
                beauty = ZegoBeauty.POLISH | ZegoBeauty.SKIN_WHITEN;
                break;
        }

        return beauty;
    }
}
