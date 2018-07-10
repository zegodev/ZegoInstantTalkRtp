package com.zego.instanttalk2;

import android.content.Context;
import android.content.res.Resources;
import android.os.Handler;
import android.os.HandlerThread;

/**
 * Created by realuei on 2017/6/29.
 */

public class ZegoAppHelper {

    /** Please contact ZEGO support to get the AppID and signKey */
    /** 请开发者联系 ZEGO support 获取 APPID 与 key */
    
    static final public long RTMP_APP_ID = 0L;

    static final public long UDP_APP_ID =  10L;

    static final public long INTERNATIONAL_APP_ID = 100L;

    static final private byte[] RTMP_SIGN_KEY = new byte[] { };

    static final private byte[] UDP_SIGN_KEY = new byte[] { };

    static final private byte[] INTERNATIONAL_SIGN_KEY = new byte[] { };

    private static ZegoAppHelper sInstance = new ZegoAppHelper();

    private HandlerThread _backgroundThread = new HandlerThread("zego_background");
    private Handler backgroundHandler;

    private ZegoAppHelper() {
        _backgroundThread.start();
        backgroundHandler = new Handler(_backgroundThread.getLooper());
    }

    /**
     * 在后台执行一个任务，相比普通 Thread，可以对所有待执行的任务排序
     *
     * @param runnable
     */
    static public void postTask(Runnable runnable) {
        sInstance.backgroundHandler.post(runnable);
    }

    /**
     * 移除所有后台任务
     */
    static public void removeTask(Runnable runnable) {
        sInstance.backgroundHandler.removeCallbacks(runnable);
    }

    static public boolean isInternationalProduct(long appId) {
        return appId == INTERNATIONAL_APP_ID;
    }

    static public boolean isUdpProduct(long appId) {
        return appId == UDP_APP_ID;
    }

    static public boolean isRtmpProduct(long appId) {
        return appId == RTMP_APP_ID;
    }

    static public byte[] requestSignKey(long appId) {
        if (isRtmpProduct(appId)) {
            return RTMP_SIGN_KEY;
        } else if (isUdpProduct(appId)) {
            return UDP_SIGN_KEY;
        } else if (isInternationalProduct(appId)) {
            return INTERNATIONAL_SIGN_KEY;
        }
        return null;
    }

    /** Please contact ZEGO support to get the AppID and signKey */
    /** 请开发者联系 ZEGO support 获取 APPID 与 key */
    static public String getAppTitle(long appId, Context context) {
        String appTitle;
        Resources resources = context.getResources();
        if (appId == 0L) {  // RTMP
            appTitle = resources.getString(R.string.app_title, "RTMP");
        } else if (appId == 10L) {   // UDP
            appTitle = resources.getString(R.string.app_title, "UDP");
        } else if (appId == 100L) {   // International
            appTitle = resources.getString(R.string.app_title, "Int'l");
        } else {    // Custom
            appTitle = resources.getString(R.string.app_title, "Customize");
        }
        return appTitle;
    }

    static public String convertSignKey2String(byte[] signKey) {
        StringBuilder buffer = new StringBuilder();
        for (int b : signKey) {
            buffer.append("0x").append(Integer.toHexString((b & 0x000000FF) | 0xFFFFFF00).substring(6)).append(",");
        }
        buffer.setLength(buffer.length() - 1);
        return buffer.toString();
    }

    static public byte[] parseSignKeyFromString(String strSignKey) throws NumberFormatException {
        String[] keys = strSignKey.split(",");
        if (keys.length != 32) {
            throw new NumberFormatException("App Sign Key Illegal");
        }
        byte[] byteSignKey = new byte[32];
        for (int i = 0; i < 32; i++) {
            int data = Integer.valueOf(keys[i].trim().replace("0x", ""), 16);
            byteSignKey[i] = (byte) data;
        }
        return byteSignKey;
    }
}
