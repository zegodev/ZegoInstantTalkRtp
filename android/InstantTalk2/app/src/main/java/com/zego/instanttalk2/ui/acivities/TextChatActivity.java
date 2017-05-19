package com.zego.instanttalk2.ui.acivities;

import android.app.Activity;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.zego.instanttalk2.MainActivity;
import com.zego.instanttalk2.R;
import com.zego.instanttalk2.ZegoApiManager;
import com.zego.instanttalk2.adapter.NewChatAdapter;
import com.zego.instanttalk2.constants.IntentExtra;
import com.zego.instanttalk2.entities.BizUser;
import com.zego.instanttalk2.entities.ChatMsg;
import com.zego.instanttalk2.interfaces.OnChatRoomListener;
import com.zego.instanttalk2.interfaces.OnUpdateMsgListListener;
import com.zego.instanttalk2.presenters.BizLivePresenter;
import com.zego.instanttalk2.presenters.TextMessagePresenter;
import com.zego.instanttalk2.ui.base.AbsBaseActivity;
import com.zego.instanttalk2.utils.BackgroundUtil;
import com.zego.instanttalk2.utils.PreferenceUtil;
import com.zego.zegoliveroom.ZegoLiveRoom;
import com.zego.zegoliveroom.callback.chatroom.IZegoCreateGroupChatCallback;
import com.zego.zegoliveroom.callback.chatroom.IZegoVideoTalkCallback;
import com.zego.zegoliveroom.constants.ZegoIM;
import com.zego.zegoliveroom.entity.ZegoUser;

import java.util.ArrayList;
import java.util.List;

import butterknife.Bind;
import butterknife.OnClick;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public class TextChatActivity extends AbsBaseActivity {

    @Bind(R.id.et_massage)
    public EditText etMsg;

    @Bind(R.id.tv_user_name)
    public TextView tvUserName;

    @Bind(R.id.rlv_msg)
    public RecyclerView rlvMsg;

    private ArrayList<BizUser> mListToUser = null;

    private String mGroupID = null;

    private String mGroupName = null;

    private LinearLayoutManager mLinearLayoutManager = null;

    private NewChatAdapter mNewChatAdapter = null;

    protected AlertDialog mDialogHandleRequestPublish = null;

    private ZegoLiveRoom mZegoLiveRoom = null;

    public static void actionStart(Activity activity, ArrayList<BizUser> listToUser, String groupID) {
        Intent intent = new Intent(activity, TextChatActivity.class);
        intent.putParcelableArrayListExtra(IntentExtra.TO_USERS, listToUser);
        intent.putExtra(IntentExtra.SESSION, groupID);
        activity.startActivity(intent);
    }

    @Override
    protected int getContentViewLayout() {
        return R.layout.activity_chat;
    }

    @Override
    protected void initExtraData(Bundle savedInstanceState) {
        Intent intent = getIntent();
        mListToUser = intent.getParcelableArrayListExtra(IntentExtra.TO_USERS);
        mGroupID = intent.getStringExtra(IntentExtra.SESSION);

        if (mListToUser == null || mListToUser.size() == 0) {
            Toast.makeText(TextChatActivity.this, getString(R.string.member_list_is_empty), Toast.LENGTH_SHORT).show();
            finish();
        }
    }

    @Override
    protected void initVariables(Bundle savedInstanceState) {
        mZegoLiveRoom = ZegoApiManager.getInstance().getZegoLiveRoom();
        mNewChatAdapter = new NewChatAdapter(this);
        mLinearLayoutManager = new LinearLayoutManager(this);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        setChatTitle();

        rlvMsg.setLayoutManager(mLinearLayoutManager);
        rlvMsg.setAdapter(mNewChatAdapter);

        TextMessagePresenter.getInstance().setUpdateMsgListListener(mGroupID, mListToUser, new OnUpdateMsgListListener() {
            @Override
            public void onShowAllMsg(String groupID, List<ChatMsg> listMsg) {
                mGroupID = groupID;
                mNewChatAdapter.setMsgList(listMsg);
                rlvMsg.smoothScrollToPosition(listMsg.size() - 1);
            }
        });

        BizLivePresenter.getInstance().setChatRoomListener(new OnChatRoomListener() {

            @Override
            public void onConnectState(int state) {
                if (state == ZegoIM.ChatRoomConnectState.Disconnected) {
                    Toast.makeText(TextChatActivity.this, getString(R.string.you_have_disconnected), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onShowRequestMsg(final int respondSeq, String fromUserID, String fromUserName, final String videoRoomID) {

                if (!BackgroundUtil.getRunningTask(TextChatActivity.this)) {
                    NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

                    NotificationCompat.Builder builder = new NotificationCompat.Builder(TextChatActivity.this);
                    builder.setContentTitle(getString(R.string.notification)).setContentText(getString(R.string.someone_requested_to_chat_with_you, fromUserName)).setSmallIcon(R.mipmap.ic_launcher).setAutoCancel(true);

                    builder.setContentIntent(PendingIntent.getActivity(TextChatActivity.this, 0, new Intent(TextChatActivity.this, MainActivity.class), 0));

                    notificationManager.notify(102, builder.build());
                }

                mDialogHandleRequestPublish = new AlertDialog.Builder(TextChatActivity.this).setTitle(getString(R.string.hint)).
                        setMessage(getString(R.string.someone_is_requesting_to_chat_with_you, fromUserName)).setPositiveButton(getString(R.string.Allow),
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                ZegoApiManager.getInstance().getZegoLiveRoom().respondVideoTalk(respondSeq, true, new IZegoVideoTalkCallback() {
                                    @Override
                                    public void onSendComplete(int errorCode) {
                                        if (errorCode == 0) {
                                            GuestActivity.actionStart(TextChatActivity.this, videoRoomID);
                                            finish();
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
                if (mDialogHandleRequestPublish != null && mDialogHandleRequestPublish.isShowing()) {
                    mDialogHandleRequestPublish.dismiss();

                    Toast.makeText(TextChatActivity.this, getString(R.string.your_friend_has_canceled_the_chat, fromUserName), Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    @Override
    protected void loadData(Bundle savedInstanceState) {
        if (TextUtils.isEmpty(mGroupID)) {
            mGroupName = PreferenceUtil.getInstance().getUserName() + "_GroupTalk";
            mZegoLiveRoom.createGroupChat(mGroupName, getZegoUserList(mListToUser), new IZegoCreateGroupChatCallback() {
                @Override
                public void onCreateGroupChat(int errorCode, String groupID) {
                    if (errorCode == 0) {
                        mGroupID = groupID;
                        TextMessagePresenter.getInstance().openGroup(groupID);
                    } else {
                        Toast.makeText(TextChatActivity.this, getString(R.string.create_chat_group_failed), Toast.LENGTH_SHORT).show();
                        finish();
                    }
                }
            });
        } else {
            TextMessagePresenter.getInstance().openGroup(mGroupID);
        }
    }

    private void setChatTitle() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0, size = mListToUser.size(); i < size; i++) {
            sb.append(mListToUser.get(i).userName);
            if (i != size - 1) {
                sb.append("+");
            }
        }
        tvUserName.setText(sb.toString());
    }


    @OnClick(R.id.btn_send)
    public void sendMsg() {

        String msg = etMsg.getText().toString();
        if (TextUtils.isEmpty(msg)) {
            Toast.makeText(TextChatActivity.this, R.string.you_can_not_send_an_empty_message, Toast.LENGTH_SHORT).show();
            return;
        }
        etMsg.setText("");

        setChatTitle();

        // 用户可能更新了ID或者
        TextMessagePresenter.getInstance().sendGroupMsg(mGroupID, mGroupName, getZegoUserList(mListToUser), msg);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // 关闭会话
        TextMessagePresenter.getInstance().closeGroup(mGroupID);
        // 清空回调
        TextMessagePresenter.getInstance().setUpdateMsgListListener(mGroupID, null, null);
    }

    @OnClick(R.id.tv_video_chat)
    public void startVideoChat() {
        HostActivity.actionStart(this, mListToUser);
//        finish();
    }

    @OnClick(R.id.tv_back)
    public void back() {
        finish();
    }

    private ZegoUser[] getZegoUserList(ArrayList<BizUser> listToUser) {
        if (listToUser == null || listToUser.size() == 0) {
            return null;
        }

        int size = listToUser.size();
        ZegoUser[] zegoUsers = new ZegoUser[size];

        for (int i = 0; i < size; i++) {
            BizUser bizUser = listToUser.get(i);
            ZegoUser zegoUser = new ZegoUser();

            zegoUser.userID = bizUser.userID;
            zegoUser.userName = bizUser.userName;
            zegoUsers[i] = zegoUser;
        }

        return zegoUsers;
    }
}
