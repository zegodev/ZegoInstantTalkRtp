package com.zego.instanttalk2;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.app.NotificationCompat;
import android.support.v4.view.ViewPager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.Toolbar;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Toast;

import com.tencent.tauth.Tencent;
import com.zego.instanttalk2.constants.Constants;
import com.zego.instanttalk2.interfaces.OnChatRoomListener;
import com.zego.instanttalk2.presenters.BizLivePresenter;
import com.zego.instanttalk2.ui.acivities.GuestActivity;
import com.zego.instanttalk2.ui.acivities.SelectUsersActivity;
import com.zego.instanttalk2.ui.base.AbsBaseActivity;
import com.zego.instanttalk2.ui.base.AbsBaseFragment;
import com.zego.instanttalk2.ui.fragments.SelectChatFragmentDialog;
import com.zego.instanttalk2.ui.fragments.SessionListFragment;
import com.zego.instanttalk2.ui.fragments.UserListFragment;
import com.zego.instanttalk2.ui.widgets.NavigationBar;
import com.zego.instanttalk2.utils.BackgroundUtil;
import com.zego.zegoliveroom.callback.chatroom.IZegoVideoTalkCallback;
import com.zego.zegoliveroom.constants.ZegoIM;

import java.util.ArrayList;
import java.util.List;

import butterknife.Bind;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */
public class MainActivity extends AbsBaseActivity implements NavigationBar.NavigationBarListener{

    private List<AbsBaseFragment> mFragments;

    private FragmentPagerAdapter mPagerAdapter;

    protected AlertDialog mDialogHandleRequestPublish = null;

    @Bind(R.id.toolbar)
    public Toolbar toolBar;

    @Bind(R.id.drawerlayout)
    public DrawerLayout drawerLayout;

    private OnSetConfigsCallback mSetConfigsCallback;

    @Bind(R.id.nb)
    public NavigationBar navigationBar;

    @Bind(R.id.vp)
    public ViewPager viewPager;


    @Override
    protected int getContentViewLayout() {
        return R.layout.acvitity_main;
    }

    @Override
    protected void initExtraData(Bundle savedInstanceState) {

    }

    @Override
    protected void initVariables(Bundle savedInstanceState) {
        mFragments = new ArrayList<>();
        mFragments.add(UserListFragment.newInstance());
        mFragments.add(SessionListFragment.newInstance());

        mPagerAdapter = new FragmentPagerAdapter(getSupportFragmentManager()) {
            @Override
            public Fragment getItem(int position) {
                return mFragments.get(position);
            }

            @Override
            public int getCount() {
                return mFragments.size();
            }
        };

        mSetConfigsCallback = (OnSetConfigsCallback) getSupportFragmentManager().findFragmentById(R.id.setting_fragment);

        drawerLayout.addDrawerListener(new DrawerLayout.DrawerListener() {
            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {

            }

            @Override
            public void onDrawerOpened(View drawerView) {
                toolBar.setTitle(getString(R.string.action_settings));
            }

            @Override
            public void onDrawerClosed(View drawerView) {
                toolBar.setTitle(getString(R.string.app_name));
                // 当侧边栏关闭时, set配置
                if(mSetConfigsCallback != null){
                    mSetConfigsCallback.onSetConfig();
                }
            }

            @Override
            public void onDrawerStateChanged(int newState) {

            }
        });

        setSupportActionBar(toolBar);

        toolBar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (drawerLayout.isDrawerOpen(Gravity.LEFT)) {
                    drawerLayout.closeDrawer(Gravity.LEFT);
                } else {
                    drawerLayout.openDrawer(Gravity.LEFT);
                }
            }
        });
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        navigationBar.setNavigationBarListener(this);

        viewPager.setAdapter(mPagerAdapter);
        navigationBar.selectTab(0);
        viewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                navigationBar.selectTab(position);
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    @Override
    protected void loadData(Bundle savedInstanceState) {
        BizLivePresenter.getInstance().loginChatRoom();
    }

    @Override
    protected void onResume() {
        super.onResume();

        BizLivePresenter.getInstance().setChatRoomListener(new OnChatRoomListener() {

            @Override
            public void onConnectState(int state) {
                if(state == ZegoIM.ChatRoomConnectState.Disconnected){
                    Toast.makeText(MainActivity.this, getString(R.string.you_have_disconnected), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onShowRequestMsg(final int respondSeq, String fromUserID, String fromUserName, final String videoRoomID) {

                if(!BackgroundUtil.getRunningTask(MainActivity.this)){
                    NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

                    NotificationCompat.Builder builder = new NotificationCompat.Builder(MainActivity.this);
                    builder.setContentTitle(getString(R.string.notification)).setContentText(getString(R.string.someone_requested_to_chat_with_you, fromUserName)).setSmallIcon(R.mipmap.ic_launcher).setAutoCancel(true);

                    builder.setContentIntent(PendingIntent.getActivity(MainActivity.this, 0, new Intent(MainActivity.this, MainActivity.class), 0));

                    notificationManager.notify(102, builder.build());
                }
                mDialogHandleRequestPublish = new AlertDialog.Builder(MainActivity.this).setTitle(getString(R.string.hint)).
                        setMessage(getString(R.string.someone_is_requesting_to_chat_with_you, fromUserName)).setPositiveButton(getString(R.string.Allow),
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                ZegoApiManager.getInstance().getZegoLiveRoom().respondVideoTalk(respondSeq, true, new IZegoVideoTalkCallback() {
                                    @Override
                                    public void onSendComplete(int errorCode) {
                                        if(errorCode == 0){
                                            GuestActivity.actionStart(MainActivity.this, videoRoomID);
                                        }
                                    }
                                });
                                dialog.dismiss();
                            }
                        }).setNegativeButton(getString(R.string.Deny), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        ZegoApiManager.getInstance().getZegoLiveRoom().respondVideoTalk(respondSeq, false, new IZegoVideoTalkCallback() {
                            @Override
                            public void onSendComplete(int errorCode) {

                            }
                        });
                        dialog.dismiss();
                    }
                }).create();

                mDialogHandleRequestPublish.show();
            }

            @Override
            public void onShowRespondMsg(int respondSeq, String fromUserID, String fromUserName, boolean result) {

            }

            @Override
            public void onCancelChat(int respondSeq, String fromUserID, String fromUserName) {
                // 聊天发起人取消了此次聊天
                if(mDialogHandleRequestPublish != null && mDialogHandleRequestPublish.isShowing()){
                    mDialogHandleRequestPublish.dismiss();

                    Toast.makeText(MainActivity.this, getString(R.string.your_friend_has_canceled_the_chat, fromUserName), Toast.LENGTH_SHORT).show();
                }
            }

        });
    }

    @Override
    public void onTabSelect(int tabIndex) {
        viewPager.setCurrentItem(tabIndex, true);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            exit();
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 用户连续点击两次返回键可以退出应用的时间间隔.
     */
    public static final long EXIT_INTERVAL = 1000;

    private long mBackPressedTime;

    /**
     * 退出.
     */
    private void exit() {

        /* 连按两次退出 */
        long currentTime = System.currentTimeMillis();
        if (currentTime - mBackPressedTime > EXIT_INTERVAL) {
            Toast.makeText(this, "再按一次退出程序", Toast.LENGTH_SHORT).show();
            mBackPressedTime = currentTime;
        } else {

            // 退出聊天室
            BizLivePresenter.getInstance().logoutChatRoom();

            // 释放Zego sdk
            ZegoApiManager.getInstance().releaseSDK();

            System.exit(0);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();


        if(id == R.id.action_contact_us){
            Tencent.createInstance("", MainActivity.this).startWPAConversation(MainActivity.this, "84328558", "");
            return true;
        }

        if(id == R.id.action_multi_users){
            final SelectChatFragmentDialog selectChatFragmentDialog = new SelectChatFragmentDialog();
            selectChatFragmentDialog.setSelectChatListener(new SelectChatFragmentDialog.OnSelectChatListener() {
                @Override
                public void onSelectMultiUsersChat() {
                    SelectUsersActivity.actionStart(MainActivity.this, Constants.CHAT_TYPE_TEXT);
                }

                @Override
                public void onSelectMultiUsersVideoChat() {
                    SelectUsersActivity.actionStart(MainActivity.this, Constants.CHAT_TYPE_VIDEO);
                }
            });
            selectChatFragmentDialog.show(getFragmentManager(), "selectChatDialog");
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public interface OnSetConfigsCallback{
        void onSetConfig();
    }

    public NavigationBar getNavigationBar(){
        return navigationBar;
    }
}
