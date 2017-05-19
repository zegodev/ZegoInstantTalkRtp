package com.zego.instanttalk2.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.entities.BizUser;
import com.zego.instanttalk2.utils.BizLiveUitl;

import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * <p>
 * des:  直播列表适配器.
 */
public class SelectUsersAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private LayoutInflater mLayoutInflater;
    private List<BizUser> mListUser;
    private OnUserSelectListener mOnUserSelectListener;
    private int mPeopleLimit = 0;
    private int mPeopleSelected = 0;

    public void setOnUserSelectListener(OnUserSelectListener onUserSelectListener) {
        mOnUserSelectListener = onUserSelectListener;
    }

    public SelectUsersAdapter(Context context, List<BizUser> bizUsers, int peopleLimit) {
        mPeopleLimit = peopleLimit;
        mLayoutInflater = LayoutInflater.from(context);
        mListUser = bizUsers;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new SelectUserHolder(mLayoutInflater.inflate(R.layout.item_select_users, parent, false));
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, final int position) {
        final BizUser user = mListUser.get(position);

        final SelectUserHolder selectUserHolder = (SelectUserHolder) holder;
        selectUserHolder.tvUserName.setText(user.userName);
        selectUserHolder.ivAvatar.setImageBitmap(BizLiveUitl.getAvatarByUserID(user.userID));

        if(mOnUserSelectListener != null){
            selectUserHolder.cbSelect.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if(isChecked){
                        mPeopleSelected += 1;
                    }else {
                        mPeopleSelected -= 1;
                    }

                    if(isChecked && mPeopleSelected  > mPeopleLimit){
                        buttonView.setChecked(false);
                        mPeopleSelected -= 1;
                        mOnUserSelectListener.onPeopleCountExceedLimit(mPeopleLimit);
                        return;
                    }

                    mOnUserSelectListener.onUserSelect(isChecked, user);
                }
            });
        }
    }

    @Override
    public int getItemCount() {
        return mListUser == null ? 0 : mListUser.size();
    }


    public static class SelectUserHolder extends RecyclerView.ViewHolder {
        RelativeLayout rlytItem;
        CheckBox cbSelect;
        ImageView ivAvatar;
        TextView tvUserName;

        public SelectUserHolder(View itemView) {
            super(itemView);
            rlytItem = (RelativeLayout) itemView.findViewById(R.id.rlyt_item);
            cbSelect = (CheckBox)itemView.findViewById(R.id.cb_select);
            ivAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            tvUserName = (TextView) itemView.findViewById(R.id.tv_user_name);
        }
    }

    public interface OnUserSelectListener {
        void onUserSelect(boolean isSelected, BizUser bizUser);
        void onPeopleCountExceedLimit(int limitCount);
    }
}
