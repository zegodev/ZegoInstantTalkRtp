package com.zego.instanttalk2.ui.fragments;

import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.adapter.ListUserAdapter;
import com.zego.instanttalk2.adapter.SpaceItemDecoration;
import com.zego.instanttalk2.entities.BizUser;
import com.zego.instanttalk2.interfaces.UserListView;
import com.zego.instanttalk2.presenters.UserListPresenter;
import com.zego.instanttalk2.ui.acivities.HostActivity;
import com.zego.instanttalk2.ui.acivities.TextChatActivity;
import com.zego.instanttalk2.ui.base.AbsBaseFragment;

import java.util.ArrayList;
import java.util.List;

import butterknife.Bind;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */
public class UserListFragment extends AbsBaseFragment {

    @Bind(R.id.rlv_user_list)
    public RecyclerView rlvUserList;

    private ListUserAdapter mListUserAdapter;

    private LinearLayoutManager mLinearLayoutManager;

    public static UserListFragment newInstance(){
        return new UserListFragment();
    }

    @Override
    protected int getContentViewLayout() {
        return R.layout.fragment_user_list;
    }

    @Override
    protected void initExtraData() {

    }

    @Override
    protected void initVariables() {
        mListUserAdapter = new ListUserAdapter(mParentActivity);
        mListUserAdapter.setOnItemClickListener(new ListUserAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, BizUser user) {
                ArrayList<BizUser> listToUser = new ArrayList<>();
                listToUser.add(user);
                TextChatActivity.actionStart(mParentActivity, listToUser, null);
            }

            @Override
            public void onVideoTalkClick(View view, BizUser user) {
                ArrayList<BizUser> listToUser = new ArrayList<>();
                listToUser.add(user);
                HostActivity.actionStart(mParentActivity, listToUser);
            }
        });

        UserListPresenter.getInstance().setUserListView(new UserListView() {
            @Override
            public void onUserListUpdate(List<BizUser> listUser) {
                mListUserAdapter.setUserList(listUser);
            }
        });
    }

    @Override
    protected void initViews() {
        mLinearLayoutManager = new LinearLayoutManager(mParentActivity);
        rlvUserList.setLayoutManager(mLinearLayoutManager);
        rlvUserList.addItemDecoration(new SpaceItemDecoration(mResources.getDimensionPixelSize(R.dimen.dimen_5)));
        rlvUserList.setAdapter(mListUserAdapter);

    }

    @Override
    protected void loadData() {

    }

    @Override
    public void onResume() {
        super.onResume();
    }
}
