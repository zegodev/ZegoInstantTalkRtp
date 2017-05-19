package com.zego.instanttalk2.interfaces;

import java.util.HashMap;

/**
 * Copyright © 2017 Zego. All rights reserved.
 */

public interface OnVideoLiveListener {

    void onPublishSucc(String streamID, HashMap<String, Object> info);

    void onPublishStop(int stateCode, String streamID);

    void onPlaySucc(String streamID);

    void onPlayStop(int stateCode, String streamID);

    void onPublishQulityUpdate(String streamID, int quality, double videoFPS, double videoBitrate);

    void onPlayQualityUpdate(String streamID, int quality, double videoFPS, double videoBitrate);
}
