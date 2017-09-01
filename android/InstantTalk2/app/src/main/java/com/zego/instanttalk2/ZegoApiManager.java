package com.zego.instanttalk2;


import android.text.TextUtils;
import android.widget.Toast;

import com.zego.instanttalk2.presenters.BizLivePresenter;
import com.zego.instanttalk2.utils.PreferenceUtil;
import com.zego.instanttalk2.utils.SystemUtil;
import com.zego.zegoliveroom.ZegoLiveRoom;
import com.zego.zegoliveroom.constants.ZegoAvConfig;


/**
 * des: zego api管理器.
 */
public class ZegoApiManager {

    private static ZegoApiManager sInstance = null;

    private ZegoLiveRoom mZegoLiveRoom = null;

    private ZegoAvConfig mZegoAvConfig;

    /**
     *  测试环境开关.
     */
    private boolean mUseTestEvn = false;

    private boolean mUseHardwareEncode = false;

    private boolean mUseHardwareDecode = false;

    private long mAppID = 0;
    private byte[] mAppSignKey = null;

    private ZegoApiManager() {
        mZegoLiveRoom = new ZegoLiveRoom();
    }

    public static ZegoApiManager getInstance() {
        if (sInstance == null) {
            synchronized (ZegoApiManager.class) {
                if (sInstance == null) {
                    sInstance = new ZegoApiManager();
                }
            }
        }
        return sInstance;
    }

    private void initUserInfo(){
        // 初始化用户信息
        String userID = PreferenceUtil.getInstance().getUserID();
        String userName = PreferenceUtil.getInstance().getUserName();

        if (TextUtils.isEmpty(userID) || TextUtils.isEmpty(userName)) {
            long ms = System.currentTimeMillis();
            userID = ms + "";
            userName = "Android_" + SystemUtil.getOsInfo() + "-" + ms;

            // 保存用户信息
            PreferenceUtil.getInstance().setUserID(userID);
            PreferenceUtil.getInstance().setUserName(userName);
        }
        // 必须设置用户信息
        ZegoLiveRoom.setUser(userID, userName);
    }


    private void init(long appID, byte[] signKey){

        initUserInfo();

        // 测试环境开关
        if(mUseTestEvn){
            ZegoLiveRoom.setTestEnv(true);
        }else {
            ZegoLiveRoom.setTestEnv(false);
        }

        mAppID = appID;
        mAppSignKey = signKey;
        PreferenceUtil.getInstance().setAppId(mAppID);
        PreferenceUtil.getInstance().setAppKey(mAppSignKey);

        // 业务类型
        ZegoLiveRoom.setBusinessType(2);

        // 聊天室开关
        ZegoLiveRoom.setUseChatRoom(true);

        // 初始化sdk
        boolean ret = mZegoLiveRoom.initSDK(appID, signKey, ZegoApplication.sApplicationContext);
        if(!ret){
            // sdk初始化失败
            Toast.makeText(ZegoApplication.sApplicationContext, "Zego SDK初始化失败!", Toast.LENGTH_LONG).show();
        }

        if (appID == 1739272706 || appID == 3322882036L) {
            mZegoLiveRoom.setLatencyMode(1);
        }

        // 初始化设置级别为"High"
        mZegoAvConfig = new ZegoAvConfig(ZegoAvConfig.Level.High);
        mZegoLiveRoom.setAVConfig(mZegoAvConfig);


        // 开发者根据需求定制
        // 硬件编码
        setUseHardwareEncode(mUseHardwareEncode);
        // 硬件解码
        setUseHardwareDecode(mUseHardwareDecode);

        BizLivePresenter.getInstance().init();
    }

    /**
     * 此方法是通过 appId 模拟获取与之对应的 signKey，强烈建议 signKey 不要存储在本地，而是加密存储在云端，通过网络接口获取
     * @param appId
     * @return
     */
    private byte[] requestSignKey(long appId) {
        return ZegoAppHelper.requestSignKey(appId);
    }

    /**
     * 初始化sdk.
     */
    public void initSDK(){
        // 即构分配的key与id, 默认使用 UDP 协议的 AppId
        if (mAppID <= 0) {
            long storedAppId = PreferenceUtil.getInstance().getAppId();
            if (storedAppId > 0) {
                mAppID = storedAppId;
                mAppSignKey = PreferenceUtil.getInstance().getAppKey();
            } else {
                mAppID = ZegoAppHelper.UDP_APP_ID;
                mAppSignKey = requestSignKey(mAppID);
            }
        }

        init(mAppID, mAppSignKey);
    }

    public void reInitSDK(long appID, byte[] signKey) {
        init(appID, signKey);
    }

    public void releaseSDK() {
        mZegoLiveRoom.unInitSDK();
    }

    public ZegoLiveRoom getZegoLiveRoom() {
        return mZegoLiveRoom;
    }

    public void setZegoConfig(ZegoAvConfig config) {
        mZegoAvConfig = config;
        mZegoLiveRoom.setAVConfig(config);
    }


    public ZegoAvConfig getZegoAvConfig(){
        return  mZegoAvConfig;
    }


    public void setUseTestEvn(boolean useTestEvn) {
        mUseTestEvn = useTestEvn;
    }

    public void setUseHardwareEncode(boolean useHardwareEncode) {
        mUseHardwareEncode = useHardwareEncode;
        ZegoLiveRoom.requireHardwareEncoder(useHardwareEncode);
    }

    public void setUseHardwareDecode(boolean useHardwareDecode) {
        mUseHardwareDecode = useHardwareDecode;
        ZegoLiveRoom.requireHardwareDecoder(useHardwareDecode);
    }

    public long getAppID() {
        return mAppID;
    }

    public byte[] getAppSignKey() {
        return mAppSignKey;
    }

}
