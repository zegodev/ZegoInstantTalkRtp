package com.zego.instanttalk2.utils;

import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public class CommonUtil {
    public  static <T>  boolean isListEmpty(List<T> list){
        return list == null || list.size() == 0;
    }
}
