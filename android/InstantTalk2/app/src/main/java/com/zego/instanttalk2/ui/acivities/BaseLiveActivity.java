package com.zego.instanttalk2.ui.acivities;

import android.Manifest;
import android.app.Service;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.provider.Settings;
import android.support.design.widget.BottomSheetBehavior;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.ZegoApiManager;
import com.zego.instanttalk2.ui.base.AbsBaseLiveActivity;
import com.zego.instanttalk2.ui.widgets.PublishSettingsPannel;
import com.zego.instanttalk2.ui.widgets.ViewLive;
import com.zego.instanttalk2.utils.PreferenceUtil;
import com.zego.instanttalk2.utils.ZegoRoomUtil;
import com.zego.zegoliveroom.ZegoLiveRoom;
import com.zego.zegoliveroom.constants.ZegoVideoViewMode;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import butterknife.OnClick;

/**
 * des: 主页面
 */
public abstract class BaseLiveActivity extends AbsBaseLiveActivity {

    protected LinkedList<ViewLive> mListViewLive = new LinkedList<>();

    protected LinkedList<String> mListLog = new LinkedList<>();

    protected Map<String, Boolean> mMapReplayStreamID = new HashMap<>();

    protected BottomSheetBehavior mBehavior = null;

    protected RelativeLayout mRlytControlHeader = null;

    protected String mPublishTitle = null;

    protected String mPublishStreamID = null;

    protected boolean mIsPublishing = false;

    protected boolean mEnableCamera = true;

    protected boolean mEnableFrontCam = true;

    protected boolean mEnableMic = true;

    protected boolean mEnableTorch = false;

    protected int mSelectedBeauty = 0;

    protected int mSelectedFilter = 0;

    protected boolean mHostHasBeenCalled = false;

    protected ZegoLiveRoom mZegoLiveRoom = null;

    protected String mRoomID = null;

    protected PhoneStateListener mPhoneStateListener = null;

    protected PublishSettingsPannel mSettingsPannel = null;

    private TextView mTvMainMsg = null;

    private TextView mTvSubMsg = null;

    protected abstract void afterPlayingSuccess(String streamID);

    protected abstract void afterPlayingStop(String streamID);

    @Override
    protected int getContentViewLayout() {
        return R.layout.activity_live;
    }

    @Override
    protected void initVariables(final Bundle savedInstanceState) {
        mZegoLiveRoom = ZegoApiManager.getInstance().getZegoLiveRoom();
        // 初始化电话监听器
        initPhoneCallingListener();
    }

    /**
     * 初始化设置面板.
     */
    private void initSettingPannel() {

        mSettingsPannel = (PublishSettingsPannel) findViewById(R.id.publishSettingsPannel);
        mSettingsPannel.initPublishSettings(mEnableCamera, mEnableFrontCam, mEnableMic, mEnableTorch, mSelectedBeauty, mSelectedFilter);
        mSettingsPannel.setPublishSettingsCallback(new PublishSettingsPannel.PublishSettingsCallback() {
            @Override
            public void onEnableCamera(boolean isEnable) {
                mEnableCamera = isEnable;
                mZegoLiveRoom.enableCamera(isEnable);
            }

            @Override
            public void onEnableFrontCamera(boolean isEnable) {
                mEnableFrontCam = isEnable;
                mZegoLiveRoom.setFrontCam(isEnable);
            }

            @Override
            public void onEnableMic(boolean isEnable) {
                mEnableMic = isEnable;
                mZegoLiveRoom.enableMic(isEnable);
            }

            @Override
            public void onEnableTorch(boolean isEnable) {
                mEnableTorch = isEnable;
                mZegoLiveRoom.enableTorch(isEnable);
            }

            @Override
            public void onSetBeauty(int beauty) {
                mSelectedBeauty = beauty;
                mZegoLiveRoom.enableBeautifying(ZegoRoomUtil.getZegoBeauty(beauty));
            }

            @Override
            public void onSetFilter(int filter) {
                mSelectedFilter = filter;
                mZegoLiveRoom.setFilter(filter);
            }
        });

        mBehavior = BottomSheetBehavior.from(mSettingsPannel);
        FrameLayout flytMainContent = (FrameLayout) findViewById(R.id.main_content);
        if (flytMainContent != null) {
            flytMainContent.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mBehavior.getState() == BottomSheetBehavior.STATE_EXPANDED) {
                        mBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
                    }
                }
            });
        }
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {

        mTvMainMsg = (TextView) findViewById(R.id.tv_main_msg);
        mTvSubMsg = (TextView) findViewById(R.id.tv_sub_msg);

        mRlytControlHeader = (RelativeLayout) findViewById(R.id.rlyt_control_header);

        initSettingPannel();

        final ViewLive vlBigView = (ViewLive) findViewById(R.id.vl_big_view);
        if (vlBigView != null) {
            vlBigView.setZegoLiveRoom(mZegoLiveRoom);
            mListViewLive.add(vlBigView);
        }

        initViewList(vlBigView);

        mRlytControlHeader.bringToFront();
    }

    private void initViewList(final ViewLive vlBigView) {

        List<ViewLive> list = new ArrayList<>();

        LinearLayout llViewList = (LinearLayout) findViewById(R.id.ll_viewlist);
        for (int i = 0, llChildListSize = llViewList.getChildCount(); i < llChildListSize; i++) {
            if (llViewList.getChildAt(i) instanceof LinearLayout) {
                LinearLayout llChildList = (LinearLayout) llViewList.getChildAt(i);

                for (int j = 0, viewLiveSize = llChildList.getChildCount(); j < viewLiveSize; j++) {
                    if (llChildList.getChildAt(j) instanceof ViewLive) {
                        final ViewLive viewLive = (ViewLive) llChildList.getChildAt(j);

                        viewLive.setZegoLiveRoom(mZegoLiveRoom);
                        viewLive.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                viewLive.toExchangeView(vlBigView);
                            }
                        });

                        list.add((ViewLive) llChildList.getChildAt(j));
                    }
                }
            }
        }

        for (int size = list.size(), i = size - 1; i >= 0; i--) {
            mListViewLive.add(list.get(i));
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        PreferenceUtil.getInstance().setObjectToString(LogListActivity.KEY_LIST_LOG, mListLog);
    }

    /**
     * 电话状态监听.
     */
    protected void initPhoneCallingListener() {
        mPhoneStateListener = new PhoneStateListener() {
            @Override
            public void onCallStateChanged(int state, String incomingNumber) {
                super.onCallStateChanged(state, incomingNumber);
                switch (state) {
                    case TelephonyManager.CALL_STATE_IDLE:
                        if (mHostHasBeenCalled) {
                            mHostHasBeenCalled = false;
                            recordLog(getString(R.string.myself, ": call state idle"));
                            // 登陆频道
                            for (ViewLive viewLive : mListViewLive) {
                                if (viewLive.isPublishView()) {
                                    startPublish();
                                } else if (viewLive.isPlayView()) {
                                    startPlay(viewLive.getStreamID());
                                }
                            }
                        }

                        break;
                    case TelephonyManager.CALL_STATE_RINGING:
                        recordLog(getString(R.string.myself, ": call state ringing"));
                        mHostHasBeenCalled = true;
                        // 来电停止发布与播放
                        stopAllStream();
                        break;

                    case TelephonyManager.CALL_STATE_OFFHOOK:
                        break;
                }
            }
        };

        TelephonyManager tm = (TelephonyManager) getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneStateListener, PhoneStateListener.LISTEN_CALL_STATE);
    }

    /**
     * 获取空闲的View用于播放或者发布.
     *
     * @return
     */
    protected ViewLive getFreeViewLive() {
        ViewLive vlFreeView = null;
        for (int i = 0, size = mListViewLive.size(); i < size; i++) {
            ViewLive viewLive = mListViewLive.get(i);
            if (viewLive.isFree()) {
                vlFreeView = viewLive;
                vlFreeView.setVisibility(View.VISIBLE);
                break;
            }
        }
        return vlFreeView;
    }

    /**
     * 释放View用于再次播放.
     *
     * @param streamID
     */
    protected void releaseLiveView(String streamID) {
        if (TextUtils.isEmpty(streamID)) {
            return;
        }

        for (int i = 0, size = mListViewLive.size(); i < size; i++) {
            ViewLive currentViewLive = mListViewLive.get(i);
            if (streamID.equals(currentViewLive.getStreamID())) {
                int j = i;
                for (; j < size - 1; j++) {
                    ViewLive nextViewLive = mListViewLive.get(j + 1);
                    if (nextViewLive.isFree()) {
                        break;
                    }

                    if (nextViewLive.isPublishView()) {
                        mZegoLiveRoom.setPreviewView(currentViewLive.getTextureView());
                    } else {
                        mZegoLiveRoom.updatePlayView(nextViewLive.getStreamID(), currentViewLive.getTextureView());
                    }

                    currentViewLive.toExchangeView(nextViewLive);
                    currentViewLive = nextViewLive;
                }
                // 标记最后一个View可用
                mListViewLive.get(j).setFree();
                break;
            }
        }
    }

    /**
     * 通过streamID查找正在publish或者play的ViewLive.
     *
     * @param streamID
     * @return
     */
    protected ViewLive getViewLiveByStreamID(String streamID) {
        if (TextUtils.isEmpty(streamID)) {
            return null;
        }

        ViewLive viewLive = null;
        for (ViewLive vl : mListViewLive) {
            if (streamID.equals(vl.getStreamID())) {
                viewLive = vl;
                break;
            }
        }

        return viewLive;
    }

    protected void recordLog(String msg) {
        mListLog.addFirst(msg);
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        switch (requestCode) {
            case 101:
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
                    new Handler().post(new Runnable() {
                        @Override
                        public void run() {
                            publishStream();
                        }
                    });
                } else {


                    if (grantResults[0] == PackageManager.PERMISSION_DENIED) {
                        Toast.makeText(this, R.string.allow_camera_permission, Toast.LENGTH_LONG).show();
                    }
                    if (grantResults[1] == PackageManager.PERMISSION_DENIED) {
                        Toast.makeText(this, R.string.open_recorder_permission, Toast.LENGTH_LONG).show();
                    }

                    Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                    intent.setData(Uri.parse("package:" + getPackageName()));
                    startActivity(intent);
                }
                break;
        }
    }

    /**
     * 开始发布.
     */
    protected void startPublish() {
        // 6.0及以上的系统需要在运行时申请CAMERA RECORD_AUDIO权限
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
                    || ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, new String[]{
                        Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO}, 101);
            } else {
                publishStream();
            }
        } else {
            publishStream();
        }
    }

    protected void publishStream() {

        if (TextUtils.isEmpty(mPublishStreamID)) {
            return;
        }

        ViewLive freeViewLive = getFreeViewLive();
        if (freeViewLive == null) {
            return;
        }

        // 设置流信息
        freeViewLive.setStreamID(mPublishStreamID);
        freeViewLive.setPublishView(true);

        // 输出发布状态
        recordLog(getString(R.string.myself, getString(R.string.start_to_publish_stream, mPublishStreamID)));

        // 开始播放
        mZegoLiveRoom.setPreviewView(freeViewLive.getTextureView());
        mZegoLiveRoom.startPreview();
        mZegoLiveRoom.startPublishing(mPublishStreamID, mPublishTitle, 0);
        mZegoLiveRoom.setPreviewViewMode(ZegoVideoViewMode.ScaleAspectFill);
    }

    private boolean isStreamExisted(String streamID) {
        if (TextUtils.isEmpty(streamID)) {
            return true;
        }

        boolean isExisted = false;

        for (ViewLive viewLive : mListViewLive) {
            if (streamID.equals(viewLive.getStreamID())) {
                isExisted = true;
                break;
            }
        }

        return isExisted;
    }

    /**
     * 开始播放流.
     */
    protected void startPlay(String streamID) {

        if (isStreamExisted(streamID)) {
            Toast.makeText(this, getString(R.string.stream_existed, streamID), Toast.LENGTH_SHORT).show();
            recordLog(getString(R.string.stream_existed, streamID));
            return;
        }

        ViewLive freeViewLive = getFreeViewLive();
        if (freeViewLive == null) {
            return;
        }

        // 设置流信息
        freeViewLive.setStreamID(streamID);
        freeViewLive.setPlayView(true);

        // 输出播放状态
        recordLog(getString(R.string.myself, getString(R.string.start_to_play_stream, streamID)));

        // 播放
        mZegoLiveRoom.startPlayingStream(streamID, freeViewLive.getTextureView());
        mZegoLiveRoom.setViewMode(ZegoVideoViewMode.ScaleAspectFill, streamID);
    }

    protected void stopPublish() {
        if (mIsPublishing) {
            recordLog(getString(R.string.myself, getString(R.string.stop_publising_stream, mPublishStreamID)));

            mZegoLiveRoom.stopPreview();
            mZegoLiveRoom.stopPublishing();
            mZegoLiveRoom.setPreviewView(null);

            handlePublishStop(1, mPublishStreamID);
        }
    }

    protected void stopPlay(String streamID) {
        if (!TextUtils.isEmpty(streamID)) {
            recordLog(getString(R.string.myself, getString(R.string.stop_playing_stream, streamID)));

            mZegoLiveRoom.stopPlayingStream(streamID);

            handlePlayStop(1, streamID);
        }
    }



    protected void logout() {
        AlertDialog dialog = new AlertDialog.Builder(this).setMessage(getString(R.string.do_you_really_want_to_leave_the_chat_room)).setTitle(getString(R.string.hint)).setPositiveButton(getString(R.string.Yes), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                stopAllStream();
                dialog.dismiss();
                finish();
            }
        }).setNegativeButton(getString(R.string.No), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        }).create();

        dialog.show();
    }


    protected void stopAllStream() {
        for (ViewLive viewLive : mListViewLive) {
            if (viewLive.isPublishView()) {
                stopPublish();
            } else if (viewLive.isPlayView()) {
                stopPlay(viewLive.getStreamID());
            }
            // 释放view
            viewLive.setFree();
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (mBehavior.getState() == BottomSheetBehavior.STATE_EXPANDED) {
                mBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
                return false;
            } else {
                // 退出
                logout();
            }

        }
        return super.onKeyDown(keyCode, event);
    }

    @OnClick(R.id.tv_log_list)
    public void openLogList() {
        LogListActivity.actionStart(this);
    }

    @OnClick(R.id.tv_publish_settings)
    public void publishSettings() {
        if (mBehavior.getState() == BottomSheetBehavior.STATE_COLLAPSED) {
            mBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        } else {
            mBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
        }
    }

    @OnClick(R.id.tv_close)
    public void close() {
        logout();
    }

    public void showMainMsg(String msg){
        mTvMainMsg.setText(msg);
    }

    public void showSubMsg(String msg){
        mTvSubMsg.setText(msg);
    }

    /**
     * 推流成功.
     */
    protected void handlePublishSucc(String streamID) {
        mIsPublishing = true;
        recordLog(getString(R.string.myself, getString(R.string.publish_stream_success, streamID)));

//        mRlytControlHeader.bringToFront();
    }

    /**
     * 停止推流.
     */
    protected void handlePublishStop(int stateCode, String streamID) {
        mIsPublishing = false;
        recordLog(getString(R.string.myself, getString(R.string.publish_stream_failed, streamID, stateCode + "")));

        // 释放View
        releaseLiveView(streamID);

//        mRlytControlHeader.bringToFront();
    }


    /**
     * 拉流成功.
     */
    protected void handlePlaySucc(String streamID) {
        recordLog(getString(R.string.myself, getString(R.string.play_stream_success, streamID)));
        // 记录流ID用于play失败后重新play
        mMapReplayStreamID.put(streamID, false);

        afterPlayingSuccess(streamID);

        mRlytControlHeader.bringToFront();
    }

    /**
     * 停止拉流.
     */
    protected void handlePlayStop(int stateCode, String streamID) {
        recordLog(getString(R.string.myself, getString(R.string.play_stream_failed, streamID, stateCode + "")));

        // 释放View
        releaseLiveView(streamID);

        // 当一条流play失败后重新play一次
        if (stateCode == 2 && !TextUtils.isEmpty(streamID)) {
            if (!mMapReplayStreamID.get(streamID)) {
                mMapReplayStreamID.put(streamID, true);
                startPlay(streamID);
            }
        }

        afterPlayingStop(streamID);

        mRlytControlHeader.bringToFront();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        // 注销电话监听
        TelephonyManager tm = (TelephonyManager) getSystemService(Service.TELEPHONY_SERVICE);
        tm.listen(mPhoneStateListener, PhoneStateListener.LISTEN_CALL_STATE);
        mPhoneStateListener = null;
    }
}
