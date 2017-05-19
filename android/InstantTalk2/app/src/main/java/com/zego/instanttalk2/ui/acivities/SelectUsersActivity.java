package com.zego.instanttalk2.ui.acivities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.widget.TextView;
import android.widget.Toast;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.adapter.SelectUsersAdapter;
import com.zego.instanttalk2.adapter.SpaceItemDecoration;
import com.zego.instanttalk2.entities.BizUser;
import com.zego.instanttalk2.ui.base.AbsBaseActivity;
import com.zego.instanttalk2.constants.Constants;
import com.zego.instanttalk2.constants.IntentExtra;
import com.zego.instanttalk2.presenters.UserListPresenter;
import com.zego.zegoliveroom.ZegoLiveRoom;

import java.util.ArrayList;

import butterknife.Bind;
import butterknife.OnClick;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public class SelectUsersActivity extends AbsBaseActivity {

    @Bind(R.id.rlv_user_list)
    public RecyclerView rlvUserList;

    @Bind(R.id.tv_ok)
    public TextView tvOk;

    private SelectUsersAdapter mSelectUsersAdapter;

    private LinearLayoutManager mLinearLayoutManager;

    ArrayList<BizUser> mListSelectedUser = new ArrayList<>();

    private int mChatType = 0;

    public static void actionStart(Activity activity, int chatType){
        Intent intent = new Intent(activity, SelectUsersActivity.class);
        intent.putExtra(IntentExtra.CHAT_TYPE, chatType);
        activity.startActivity(intent);
    }
    @Override
    protected int getContentViewLayout() {
        return R.layout.activity_select_users;
    }

    @Override
    protected void initExtraData(Bundle savedInstanceState) {
        mChatType = getIntent().getIntExtra(IntentExtra.CHAT_TYPE, 0);
    }

    @Override
    protected void initVariables(Bundle savedInstanceState) {
        if(mChatType == Constants.CHAT_TYPE_TEXT){
            mSelectUsersAdapter = new SelectUsersAdapter(this, UserListPresenter.getInstance().getUserList(), 1000);
        }else {
            mSelectUsersAdapter = new SelectUsersAdapter(this, UserListPresenter.getInstance().getUserList(), ZegoLiveRoom.getMaxPlayChannelCount());
        }

        mSelectUsersAdapter.setOnUserSelectListener(new SelectUsersAdapter.OnUserSelectListener() {
            @Override
            public void onUserSelect(boolean isSelected, BizUser bizUser) {
                if (isSelected) {
                    mListSelectedUser.add(bizUser);
                } else {
                    mListSelectedUser.remove(bizUser);
                }

                if (mListSelectedUser.size() > 0) {
                    tvOk.setEnabled(true);
                } else {
                    tvOk.setEnabled(false);
                }
            }

            @Override
            public void onPeopleCountExceedLimit(int limitCount) {
                Toast.makeText(SelectUsersActivity.this, getString(R.string.only_n_friends_can_be_invited_one_time, limitCount + ""), Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        mLinearLayoutManager = new LinearLayoutManager(this);
        rlvUserList.setLayoutManager(mLinearLayoutManager);
        rlvUserList.addItemDecoration(new SpaceItemDecoration(mResources.getDimensionPixelSize(R.dimen.dimen_5)));
        rlvUserList.setAdapter(mSelectUsersAdapter);
    }

    @Override
    protected void loadData(Bundle savedInstanceState) {

    }

    @OnClick(R.id.tv_cancel)
    public void cancel(){
        finish();
    }

    @OnClick(R.id.tv_ok)
    public void ok(){
        if(mChatType == Constants.CHAT_TYPE_TEXT){
            TextChatActivity.actionStart(this, mListSelectedUser, null);
            finish();
        }else if(mChatType == Constants.CHAT_TYPE_VIDEO){
            HostActivity.actionStart(this, mListSelectedUser);
//            finish();
        }
    }
}
