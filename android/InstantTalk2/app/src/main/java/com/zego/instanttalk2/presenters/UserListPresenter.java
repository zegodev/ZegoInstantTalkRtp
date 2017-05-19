package com.zego.instanttalk2.presenters;

import com.zego.instanttalk2.entities.BizUser;
import com.zego.instanttalk2.interfaces.UserListView;
import com.zego.instanttalk2.utils.PreferenceUtil;
import com.zego.zegoliveroom.constants.ZegoIM;
import com.zego.zegoliveroom.entity.ZegoUserState;

import java.util.ArrayList;
import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public class UserListPresenter {

    private static UserListPresenter sInstance;

    private List<BizUser> mListUser;

    private UserListView mUserListView;

    private UserListPresenter() {
        mListUser = new ArrayList<>();
    }

    public static UserListPresenter getInstance(){
        if(sInstance == null){
            synchronized (UserListPresenter.class){
                if(sInstance == null){
                    sInstance = new UserListPresenter();
                }
            }
        }
        return sInstance;
    }

    public void setUserListView(UserListView userListView){
        mUserListView = userListView;
        if(mUserListView != null){
            mUserListView.onUserListUpdate(mListUser);
        }
    }


    public void updateUserList(ZegoUserState[] listUser, int updateType){
        if (listUser == null || listUser.length == 0) {
            return;
        }

        // 全量更新, 清除本地数据
        if (updateType == ZegoIM.UserUpdateType.Total) {
            mListUser.clear();
        }

        for (ZegoUserState user : listUser) {
            int updateFlag = user.updateFlag;
            String userID = user.userID;

            // 1:add 2:delete 3:update
            if (updateFlag == ZegoIM.UserUpdateFlag.Deleted) {
                removeUser(userID);
            } else {
                if (isSelf(userID)) {
                    continue;
                }
                // 如果本地已经存在该用户信息,先移除
                removeUser(userID);

                BizUser bizUser = new BizUser();
                bizUser.userID = user.userID;
                bizUser.userName = user.userName;
                mListUser.add(bizUser);
            }
        }

        if(mUserListView != null){
            mUserListView.onUserListUpdate(mListUser);
        }
    }


    private boolean isSelf(String userID){
        boolean isSelf = false;

        if(PreferenceUtil.getInstance().getUserID().equals(userID)){
            isSelf = true;
        }

        return isSelf;
    }

    private void removeUser(String userID){
        for(BizUser bizUser : mListUser){
            if(bizUser.userID.equals(userID)){
                mListUser.remove(bizUser);
                break;
            }
        }
    }

    public List<BizUser> getUserList(){
        return mListUser;
    }

    public void clearUserList(){
        mListUser.clear();
    }
}
