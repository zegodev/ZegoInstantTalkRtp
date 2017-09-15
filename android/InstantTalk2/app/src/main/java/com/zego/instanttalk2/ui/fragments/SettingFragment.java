package com.zego.instanttalk2.ui.fragments;

import android.content.Context;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.SeekBar;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.zego.instanttalk2.MainActivity;
import com.zego.instanttalk2.R;
import com.zego.instanttalk2.ZegoApiManager;
import com.zego.instanttalk2.ZegoAppHelper;
import com.zego.instanttalk2.presenters.BizLivePresenter;
import com.zego.instanttalk2.ui.acivities.AboutZegoActivity;
import com.zego.instanttalk2.ui.base.AbsBaseFragment;
import com.zego.instanttalk2.utils.BizLiveUitl;
import com.zego.instanttalk2.utils.PreferenceUtil;
import com.zego.instanttalk2.utils.ShareUtils;
import com.zego.instanttalk2.utils.SystemUtil;
import com.zego.zegoliveroom.ZegoLiveRoom;
import com.zego.zegoliveroom.constants.ZegoAvConfig;
import com.zego.zegoavkit2.utils.ZegoLogUtil;

import java.io.File;
import java.io.FilenameFilter;

import butterknife.Bind;
import butterknife.OnCheckedChanged;
import butterknife.OnClick;


/**
 * des: 设置页面.
 */
public class SettingFragment extends AbsBaseFragment implements MainActivity.OnSetConfigsCallback {

    @Bind(R.id.tv_sdk_version)
    public TextView tvsdkVersion;

    @Bind(R.id.et_user_account)
    public EditText etUserAccount;

    @Bind(R.id.et_user_name)
    public EditText etUserName;

    @Bind(R.id.iv_avatar)
    public ImageView ivAvatar;

    @Bind(R.id.sp_resolutions)
    public Spinner spinnerResolutions;

    @Bind(R.id.tv_resolution)
    public TextView tvResolution;

    @Bind(R.id.sb_resolution)
    public SeekBar seekbarResolution;

    @Bind(R.id.tv_fps)
    public TextView tvFps;

    @Bind(R.id.sb_fps)
    public SeekBar seekBarFps;

    @Bind(R.id.tv_bitrate)
    public TextView tvBitrate;

    @Bind(R.id.sb_bitrate)
    public SeekBar seekBarBitrate;

    @Bind(R.id.tv_demo_version)
    public TextView tvDemoVersion;

    @Bind(R.id.llyt_hide_operation)
    public LinearLayout llytHideOperation;

    @Bind(R.id.tb_modify_test_env)
    public ToggleButton tbTestEnv;

    @Bind(R.id.sp_app_flavor)
    public Spinner spAppFlavors;

    @Bind(R.id.et_appid)
    public EditText etAppID;

    @Bind(R.id.ll_app_key)
    public LinearLayout llAppKey;

    @Bind(R.id.et_appkey)
    public EditText etAppKey;

    @Bind(R.id.sv)
    public ScrollView scrollView;

    @Bind(R.id.tb_hardware_encode)
    public ToggleButton tbHardwareEncode;

    @Bind(R.id.tb_hardware_decode)
    public ToggleButton tbHardwareDecode;

    @Bind(R.id.container)
    public LinearLayout llContainer;

    // 分辨率text
    private String mResolutionTexts[];

    private int mCount = 0;

    private final int[][] VIDEO_RESOLUTIONS = new int[][]{{320, 240}, {352, 288}, {640, 360},
            {640, 360}, {1280, 720}, {1920, 1080}};

    private boolean mNeedToReInitSDK = false;

    private Runnable reInitTask;

    @Override
    protected int getContentViewLayout() {
        return R.layout.fragment_setting;
    }

    @Override
    protected void initExtraData() {

    }

    @Override
    protected void initVariables() {
        mResolutionTexts = mResources.getStringArray(R.array.resolutions);

    }

    @Override
    protected void initViews() {
        // 用户信息
        tvsdkVersion.setText(ZegoLiveRoom.version());

        etUserAccount.setText(PreferenceUtil.getInstance().getUserID());
        etUserName.setText(PreferenceUtil.getInstance().getUserName());
        ivAvatar.setImageBitmap(BizLiveUitl.getAvatarByUserID(PreferenceUtil.getInstance().getUserID()));

        tvDemoVersion.setText(SystemUtil.getAppVersionName(mParentActivity));

        final SeekBar.OnSeekBarChangeListener seekBarChangeListener = new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                switch (seekBar.getId()) {
                    case R.id.sb_resolution:
                        tvResolution.setText(getString(R.string.resolution_prefix, mResolutionTexts[progress]));
                        break;
                    case R.id.sb_fps:
                        tvFps.setText(getString(R.string.fps_prefix, progress + ""));
                        break;
                    case R.id.sb_bitrate:
                        tvBitrate.setText(getString(R.string.bitrate_prefix, progress + ""));
                        break;
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                spinnerResolutions.setSelection(5);
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        };

        // 默认设置级别为"高"
        int defaultLevel = ZegoAvConfig.Level.High;

        // 初始化分辨率, 默认为640x480
        seekbarResolution.setMax(5);
        seekbarResolution.setProgress(defaultLevel);
        seekbarResolution.setOnSeekBarChangeListener(seekBarChangeListener);
        tvResolution.setText(getString(R.string.resolution_prefix, mResolutionTexts[defaultLevel]));

        // 初始化帧率, 默认为15
        seekBarFps.setMax(30);
        seekBarFps.setProgress(15);
        seekBarFps.setOnSeekBarChangeListener(seekBarChangeListener);
        tvFps.setText(getString(R.string.fps_prefix, "15"));

        // 初始化码率, 默认为600 * 1000
        seekBarBitrate.setMax(1000000);
        seekBarBitrate.setProgress(ZegoAvConfig.VIDEO_BITRATES[defaultLevel]);
        seekBarBitrate.setOnSeekBarChangeListener(seekBarChangeListener);
        tvBitrate.setText(getString(R.string.bitrate_prefix, "" + ZegoAvConfig.VIDEO_BITRATES[defaultLevel]));

        spinnerResolutions.setSelection(defaultLevel);
        spinnerResolutions.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position <= ZegoAvConfig.Level.VeryHigh) {
                    int level = position;
                    seekbarResolution.setProgress(level);
                    // 预设级别中,帧率固定为"15"
                    seekBarFps.setProgress(15);
                    seekBarBitrate.setProgress(ZegoAvConfig.VIDEO_BITRATES[level]);

                    seekbarResolution.setEnabled(false);
                    seekBarFps.setEnabled(false);
                    seekBarBitrate.setEnabled(false);
                } else {
                    seekbarResolution.setEnabled(true);
                    seekBarFps.setEnabled(true);
                    seekBarBitrate.setEnabled(true);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        long appId = ZegoApiManager.getInstance().getAppID();
        if (ZegoAppHelper.isUdpProduct(appId)) {
            spAppFlavors.setSelection(0);
        } else if (ZegoAppHelper.isRtmpProduct(appId)) {
            spAppFlavors.setSelection(1);
        } else if (ZegoAppHelper.isInternationalProduct(appId)) {
            spAppFlavors.setSelection(2);
        } else {
            spAppFlavors.setSelection(3);
        }

        spAppFlavors.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position == 3) {
                    etAppID.setText("");
                    etAppID.setEnabled(true);

                    etAppKey.setText("");
                    llAppKey.setVisibility(View.VISIBLE);
                } else {
                    long appId = 0;
                    switch (position) {
                        case 0:
                            appId = ZegoAppHelper.UDP_APP_ID;
                            break;
                        case 1:
                            appId = ZegoAppHelper.RTMP_APP_ID;
                            break;
                        case 2:
                            appId = ZegoAppHelper.INTERNATIONAL_APP_ID;
                            break;
                    }

                    etAppID.setEnabled(false);
                    etAppID.setText(String.valueOf(appId));

                    byte[] signKey = ZegoAppHelper.requestSignKey(appId);
                    etAppKey.setText(ZegoAppHelper.convertSignKey2String(signKey));
                    llAppKey.setVisibility(View.GONE);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        seekbarResolution.setEnabled(false);
        seekBarFps.setEnabled(false);
        seekBarBitrate.setEnabled(false);

        llContainer.setOnClickListener(new View.OnClickListener() {

            private long[] mHits = new long[5];

            @Override
            public void onClick(View v) {
                System.arraycopy(mHits, 1, mHits, 0, mHits.length - 1);
                mHits[mHits.length - 1] = SystemClock.uptimeMillis();
                if (mHits[0] >= SystemClock.uptimeMillis() - 700) {
                    sendLog2App();

                    for (int i = 0; i < mHits.length; i++) {
                        mHits[i] = 0;
                    }
                }
            }
        });
    }

    @Override
    protected void loadData() {

    }

    @OnClick(R.id.tv_switch_avatar)
    public void switchAvatar(){

        long ms = System.currentTimeMillis();
        String userID = ms + "";
        String userName = "Android_" + SystemUtil.getOsInfo() + "-" + ms;

        PreferenceUtil.getInstance().setUserID(userID);
        PreferenceUtil.getInstance().setUserName(userName);

        etUserAccount.setText(userID);
        etUserName.setText(userName);

        // 更新用户头像
        ivAvatar.setImageBitmap(BizLiveUitl.getAvatarByUserID(userID));

        // 退出聊天室
        BizLivePresenter.getInstance().logoutChatRoom();

        // 更新用户信息
        ZegoLiveRoom.setUser(userID, userName);

        // 重新登录聊天室
        BizLivePresenter.getInstance().loginChatRoom();
    }


    @OnClick(R.id.tv_demo_version)
    public void showHideOperation() {
        mCount++;
        if (mCount % 3 == 0) {
            if (llytHideOperation.getVisibility() == View.GONE) {
                llytHideOperation.setVisibility(View.VISIBLE);
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        scrollView.fullScroll(ScrollView.FOCUS_DOWN);
                    }
                });
            } else {
                llytHideOperation.setVisibility(View.GONE);
            }
        }
    }

    @OnClick(R.id.tv_advanced)
    public void showAdvanced() {
        llytHideOperation.setVisibility(View.VISIBLE);
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                scrollView.fullScroll(ScrollView.FOCUS_DOWN);
            }
        });
    }


    @OnClick(R.id.tv_upload_log)
    public void uploadLog() {
        ZegoLiveRoom.uploadLog();
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(mParentActivity, R.string.upload_log_successfully, Toast.LENGTH_SHORT).show();
            }
        }, 2000);
    }

    @OnClick(R.id.tv_about)
    public void openAboutPage() {
        AboutZegoActivity.actionStart(mParentActivity);
    }

    @Override
    public int onSetConfig() {
        if (reInitTask != null) {
            ZegoAppHelper.removeTask(reInitTask);
        }

        InputMethodManager imm = (InputMethodManager) mParentActivity.getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mParentActivity.getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);

        ZegoAvConfig zegoAvConfig = null;
        switch (spinnerResolutions.getSelectedItemPosition()) {
            case 0:
                zegoAvConfig = new ZegoAvConfig(ZegoAvConfig.Level.VeryLow);
                break;
            case 1:
                zegoAvConfig = new ZegoAvConfig(ZegoAvConfig.Level.Low);
                break;
            case 2:
                zegoAvConfig = new ZegoAvConfig(ZegoAvConfig.Level.Generic);
                break;
            case 3:
                zegoAvConfig = new ZegoAvConfig(ZegoAvConfig.Level.High);
                break;
            case 4:
                zegoAvConfig = new ZegoAvConfig(ZegoAvConfig.Level.VeryHigh);
                break;
            case 5:
                // 自定义设置
                zegoAvConfig = new ZegoAvConfig(ZegoAvConfig.Level.High);
                int progress = seekbarResolution.getProgress();
                zegoAvConfig.setVideoEncodeResolution(VIDEO_RESOLUTIONS[progress][0], VIDEO_RESOLUTIONS[progress][1]);
                zegoAvConfig.setVideoCaptureResolution(VIDEO_RESOLUTIONS[progress][0], VIDEO_RESOLUTIONS[progress][1]);
                zegoAvConfig.setVideoFPS(seekBarFps.getProgress());
                zegoAvConfig.setVideoBitrate(seekBarBitrate.getProgress());
                break;
        }

        if (zegoAvConfig != null) {
            ZegoApiManager.getInstance().setZegoConfig(zegoAvConfig);
        }

        String newUserName = etUserName.getText().toString();
        if (!newUserName.equals(PreferenceUtil.getInstance().getUserName())) {
            PreferenceUtil.getInstance().setUserName(newUserName);
            mNeedToReInitSDK = true;
        }

        String strAppID = etAppID.getText().toString().trim();
        String strSignKey = etAppKey.getText().toString().trim();
        if (TextUtils.isEmpty(strAppID) || TextUtils.isEmpty(strSignKey)) {
            Toast.makeText(mParentActivity, "AppId 或者 SignKey 格式非法", Toast.LENGTH_LONG).show();
            return -1;
        }

        // appID必须是数字
        if (!TextUtils.isDigitsOnly(strAppID)) {
            Toast.makeText(mParentActivity, "AppId 格式非法", Toast.LENGTH_LONG).show();
            etAppID.requestFocus();
            return -1;
        }
        // appKey长度必须等于32位
        byte[] byteSignKey;
        try {
            byteSignKey = ZegoAppHelper.parseSignKeyFromString(strSignKey);
        } catch (NumberFormatException e) {
            Toast.makeText(mParentActivity, "SignKey 格式非法", Toast.LENGTH_LONG).show();
            etAppKey.requestFocus();
            return -1;
        }

        final long newAppId = Long.valueOf(strAppID);
        final byte[] newSignKey = byteSignKey;

        if (newAppId != ZegoApiManager.getInstance().getAppID() && newSignKey != ZegoApiManager.getInstance().getAppSignKey()) {
            mNeedToReInitSDK = true;
        }

        int returnCode = mNeedToReInitSDK ? 1 : 0;
        if (mNeedToReInitSDK) {
            mNeedToReInitSDK = false;

            // 退出聊天室
            BizLivePresenter.getInstance().logoutChatRoom();

            reInitTask = new Runnable() {
                @Override
                public void run() {
                    ZegoApiManager.getInstance().releaseSDK();
                    ZegoApiManager.getInstance().reInitSDK(newAppId, newSignKey);
                }
            };
            ZegoAppHelper.postTask(reInitTask);
        }

        return returnCode;
    }

    @OnCheckedChanged({R.id.tb_modify_test_env, R.id.tb_hardware_encode, R.id.tb_hardware_decode})
    public void onCheckedChanged1(CompoundButton compoundButton, boolean checked) {
        // "非点击按钮"时不触发回调
        if (!compoundButton.isPressed()) return;

        switch (compoundButton.getId()) {
            case R.id.tb_modify_test_env:
                // 标记需要"重新初始化sdk"
                mNeedToReInitSDK = true;
                ZegoApiManager.getInstance().setUseTestEvn(checked);
                break;
            case R.id.tb_hardware_encode:
                ZegoApiManager.getInstance().setUseHardwareEncode(checked);
                break;
            case R.id.tb_hardware_decode:
                ZegoApiManager.getInstance().setUseHardwareDecode(checked);
                break;
        }
    }

    private void sendLog2App() {
        String rootPath = ZegoLogUtil.getLogPath(getActivity());
        File rootDir = new File(rootPath);
        File[] logFiles = rootDir.listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return !TextUtils.isEmpty(name) && name.startsWith("zegoavlog") && name.endsWith(".txt");
            }
        });

        if (logFiles.length > 0) {
            ShareUtils.sendFiles(logFiles, getActivity());
        } else {
            Log.w("SettingFragment", "not found any log files.");
        }
    }
}
