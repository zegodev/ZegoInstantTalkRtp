package com.zego.instanttalk2.utils;

import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.text.TextUtils;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des: 检测app是否处于后台的工具类.
 */

public class BackgroundUtil {

    public static boolean getRunningTask(Context context) {

        if(context == null){
            return false;
        }

        String packageName = context.getPackageName();

        ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        ComponentName cn = am.getRunningTasks(1).get(0).topActivity;

        return !TextUtils.isEmpty(packageName) && packageName.equals(cn.getPackageName());
    }
}
