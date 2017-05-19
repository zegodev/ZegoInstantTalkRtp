package com.zego.instanttalk2.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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
public class ListUserAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private LayoutInflater mLayoutInflater;
    private List<BizUser> mListUser;
    private OnItemClickListener mOnItemClickListener;

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        mOnItemClickListener = onItemClickListener;
    }

    public ListUserAdapter(Context context) {
        mLayoutInflater = LayoutInflater.from(context);
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new UserListHolder(mLayoutInflater.inflate(R.layout.item_user, parent, false));
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, final int position) {
        BizUser user = mListUser.get(position);

        final UserListHolder userListHolder = (UserListHolder) holder;
        userListHolder.tvUserName.setText(user.userName);
        userListHolder.ivAvatar.setImageBitmap(BizLiveUitl.getAvatarByUserID(user.userID));

        if (mOnItemClickListener != null) {
            userListHolder.rlytItem.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mOnItemClickListener.onItemClick(userListHolder.rlytItem, mListUser.get(position));
                }
            });

            userListHolder.tvVideoTalk.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mOnItemClickListener.onVideoTalkClick(userListHolder.tvVideoTalk, mListUser.get(position));
                }
            });
        }
    }

    @Override
    public int getItemCount() {
        return mListUser == null ? 0 : mListUser.size();
    }


    public static class UserListHolder extends RecyclerView.ViewHolder {
        RelativeLayout rlytItem;
        ImageView ivAvatar;
        TextView tvUserName;
        TextView tvVideoTalk;

        public UserListHolder(View itemView) {
            super(itemView);
            rlytItem = (RelativeLayout) itemView.findViewById(R.id.rlyt_item);
            ivAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            tvUserName = (TextView) itemView.findViewById(R.id.tv_user_name);
            tvVideoTalk = (TextView) itemView.findViewById(R.id.tv_video_talk);
        }
    }

    public void setUserList(List<BizUser> listUser) {
        mListUser = listUser;
        notifyDataSetChanged();
    }

    public interface OnItemClickListener {
        void onItemClick(View view, BizUser user);

        void onVideoTalkClick(View view, BizUser user);
    }
}
