package com.zego.instanttalk2.adapter;

import android.content.Context;
import android.content.res.Resources;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.entities.BizUser;
import com.zego.instanttalk2.entities.GroupInfo;
import com.zego.instanttalk2.utils.BizLiveUitl;
import com.zego.instanttalk2.utils.TimeUtil;

import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * <p>
 * des:  直播列表适配器.
 */
public class ListSessionAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private LayoutInflater mLayoutInflater;
    private List<GroupInfo> mListGroupInfo;
    private OnItemClickListener mOnItemClickListener;
    private Resources mResources;

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        mOnItemClickListener = onItemClickListener;
    }

    public ListSessionAdapter(Context context) {
        mLayoutInflater = LayoutInflater.from(context);
        mResources = context.getResources();
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (viewType == 1) {
            return new SessionListHolder(mLayoutInflater.inflate(R.layout.item_session_1, parent, false));
        } else if (viewType == 2) {
            return new SessionListHolder2(mLayoutInflater.inflate(R.layout.item_session_2, parent, false));
        } else if (viewType == 3) {
            return new SessionListHolder3(mLayoutInflater.inflate(R.layout.item_session_3, parent, false));
        } else {
            return new SessionListHolder4(mLayoutInflater.inflate(R.layout.item_session_4, parent, false));
        }
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, final int position) {
        final GroupInfo groupInfo = mListGroupInfo.get(position);

        if (holder instanceof SessionListHolder) {
            final SessionListHolder sessionListHolder = (SessionListHolder) holder;

            List<BizUser> sessionMembers = groupInfo.getListUser();
            sessionListHolder.tvUserName.setText(sessionMembers.get(0).userName);
            sessionListHolder.tvMsg.setText(groupInfo.getFromUserName() + ": " + groupInfo.getNewestContent());
            sessionListHolder.tvCreatedTime.setText(TimeUtil.getRelativeTime(mResources, groupInfo.getCreatedTime(), true));
            sessionListHolder.ivAvatar.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(0).userID));

            if (groupInfo.getUnreadMsgCount() > 0) {
                sessionListHolder.tvUnreadMsgCount.setVisibility(View.VISIBLE);
                sessionListHolder.tvUnreadMsgCount.setText(groupInfo.getUnreadMsgCount() + "");
            } else {
                sessionListHolder.tvUnreadMsgCount.setVisibility(View.INVISIBLE);
            }

            if (mOnItemClickListener != null) {
                sessionListHolder.rlytItem.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        groupInfo.setUnreadMsgCount(0);
                        sessionListHolder.tvUnreadMsgCount.setVisibility(View.INVISIBLE);
                        mOnItemClickListener.onItemClick(sessionListHolder.rlytItem, mListGroupInfo.get(position));
                    }
                });

                sessionListHolder.rlytItem.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        mOnItemClickListener.onItemLongClick(mListGroupInfo.get(position));
                        return false;
                    }
                });
            }

        } else if (holder instanceof SessionListHolder2) {
            final SessionListHolder2 sessionListHolder2 = (SessionListHolder2) holder;

            List<BizUser> sessionMembers = groupInfo.getListUser();
            sessionListHolder2.tvUserName.setText(sessionMembers.get(0).userName + "," + sessionMembers.get(1).userName);
            sessionListHolder2.tvMsg.setText(groupInfo.getFromUserName() + ": " + groupInfo.getNewestContent());
            sessionListHolder2.tvCreatedTime.setText(TimeUtil.getRelativeTime(mResources, groupInfo.getCreatedTime(), true));
            sessionListHolder2.ivAvatar1.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(0).userID));
            sessionListHolder2.ivAvatar2.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(1).userID));

            if (groupInfo.getUnreadMsgCount() > 0) {
                sessionListHolder2.tvUnreadMsgCount.setVisibility(View.VISIBLE);
                sessionListHolder2.tvUnreadMsgCount.setText(groupInfo.getUnreadMsgCount() + "");
            } else {
                sessionListHolder2.tvUnreadMsgCount.setVisibility(View.INVISIBLE);
            }

            if (mOnItemClickListener != null) {
                sessionListHolder2.rlytItem.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        groupInfo.setUnreadMsgCount(0);
                        sessionListHolder2.tvUnreadMsgCount.setVisibility(View.INVISIBLE);
                        mOnItemClickListener.onItemClick(sessionListHolder2.rlytItem, mListGroupInfo.get(position));
                    }
                });

                sessionListHolder2.rlytItem.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        mOnItemClickListener.onItemLongClick(mListGroupInfo.get(position));
                        return false;
                    }
                });
            }

        } else if (holder instanceof SessionListHolder3) {
            final SessionListHolder3 sessionListHolder3 = (SessionListHolder3) holder;

            List<BizUser> sessionMembers = groupInfo.getListUser();
            sessionListHolder3.tvUserName.setText(sessionMembers.get(0).userName + "," + sessionMembers.get(1).userName +
                    "," + sessionMembers.get(2).userName);
            sessionListHolder3.tvMsg.setText(groupInfo.getFromUserName() + ": " + groupInfo.getNewestContent());
            sessionListHolder3.tvCreatedTime.setText(TimeUtil.getRelativeTime(mResources, groupInfo.getCreatedTime(), true));
            sessionListHolder3.ivAvatar1.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(0).userID));
            sessionListHolder3.ivAvatar2.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(1).userID));
            sessionListHolder3.ivAvatar3.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(2).userID));

            if (groupInfo.getUnreadMsgCount() > 0) {
                sessionListHolder3.tvUnreadMsgCount.setVisibility(View.VISIBLE);
                sessionListHolder3.tvUnreadMsgCount.setText(groupInfo.getUnreadMsgCount() + "");
            } else {
                sessionListHolder3.tvUnreadMsgCount.setVisibility(View.INVISIBLE);
            }

            if (mOnItemClickListener != null) {
                sessionListHolder3.rlytItem.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        groupInfo.setUnreadMsgCount(0);
                        sessionListHolder3.tvUnreadMsgCount.setVisibility(View.INVISIBLE);
                        mOnItemClickListener.onItemClick(sessionListHolder3.rlytItem, mListGroupInfo.get(position));
                    }
                });

                sessionListHolder3.rlytItem.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        mOnItemClickListener.onItemLongClick(mListGroupInfo.get(position));
                        return false;
                    }
                });
            }

        } else if (holder instanceof SessionListHolder4) {
            final SessionListHolder4 sessionListHolder4 = (SessionListHolder4) holder;

            List<BizUser> sessionMembers = groupInfo.getListUser();
            sessionListHolder4.tvUserName.setText(sessionMembers.get(0).userName + "," + sessionMembers.get(1).userName +
                    "," + sessionMembers.get(2).userName + "," + sessionMembers.get(3).userName);
            sessionListHolder4.tvMsg.setText(groupInfo.getFromUserName() + ": " + groupInfo.getNewestContent());
            sessionListHolder4.tvCreatedTime.setText(TimeUtil.getRelativeTime(mResources, groupInfo.getCreatedTime(), true));
            sessionListHolder4.ivAvatar1.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(0).userID));
            sessionListHolder4.ivAvatar2.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(1).userID));
            sessionListHolder4.ivAvatar3.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(2).userID));
            sessionListHolder4.ivAvatar4.setImageBitmap(BizLiveUitl.getAvatarByUserID(sessionMembers.get(3).userID));


            if (groupInfo.getUnreadMsgCount() > 0) {
                sessionListHolder4.tvUnreadMsgCount.setVisibility(View.VISIBLE);
                sessionListHolder4.tvUnreadMsgCount.setText(groupInfo.getUnreadMsgCount() + "");
            } else {
                sessionListHolder4.tvUnreadMsgCount.setVisibility(View.INVISIBLE);
            }

            if (mOnItemClickListener != null) {
                sessionListHolder4.rlytItem.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        groupInfo.setUnreadMsgCount(0);
                        sessionListHolder4.tvUnreadMsgCount.setVisibility(View.INVISIBLE);
                        mOnItemClickListener.onItemClick(sessionListHolder4.rlytItem, mListGroupInfo.get(position));
                    }
                });

                sessionListHolder4.rlytItem.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View v) {
                        mOnItemClickListener.onItemLongClick(mListGroupInfo.get(position));
                        return false;
                    }
                });
            }
        }
    }

    @Override
    public int getItemViewType(int position) {
        return mListGroupInfo.get(position).getListUser().size();
    }

    @Override
    public int getItemCount() {
        return mListGroupInfo == null ? 0 : mListGroupInfo.size();
    }


    public static class SessionListHolder extends RecyclerView.ViewHolder {
        RelativeLayout rlytItem;
        ImageView ivAvatar;
        TextView tvUserName;
        TextView tvMsg;
        TextView tvCreatedTime;
        TextView tvUnreadMsgCount;

        public SessionListHolder(View itemView) {
            super(itemView);
            rlytItem = (RelativeLayout) itemView.findViewById(R.id.rlyt_item);
            ivAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            tvUserName = (TextView) itemView.findViewById(R.id.tv_user_name);
            tvMsg = (TextView) itemView.findViewById(R.id.tv_msg);
            tvCreatedTime = (TextView) itemView.findViewById(R.id.tv_created_time);
            tvUnreadMsgCount = (TextView) itemView.findViewById(R.id.tv_unread_count);
        }
    }

    public static class SessionListHolder2 extends RecyclerView.ViewHolder {
        RelativeLayout rlytItem;
        ImageView ivAvatar1;
        ImageView ivAvatar2;
        TextView tvUserName;
        TextView tvMsg;
        TextView tvCreatedTime;
        TextView tvUnreadMsgCount;

        public SessionListHolder2(View itemView) {
            super(itemView);
            rlytItem = (RelativeLayout) itemView.findViewById(R.id.rlyt_item);
            ivAvatar1 = (ImageView) itemView.findViewById(R.id.iv_avatar_1);
            ivAvatar2 = (ImageView) itemView.findViewById(R.id.iv_avatar_2);
            tvUserName = (TextView) itemView.findViewById(R.id.tv_user_name);
            tvMsg = (TextView) itemView.findViewById(R.id.tv_msg);
            tvCreatedTime = (TextView) itemView.findViewById(R.id.tv_created_time);
            tvUnreadMsgCount = (TextView) itemView.findViewById(R.id.tv_unread_count);
        }
    }

    public static class SessionListHolder3 extends RecyclerView.ViewHolder {
        RelativeLayout rlytItem;
        ImageView ivAvatar1;
        ImageView ivAvatar2;
        ImageView ivAvatar3;
        TextView tvUserName;
        TextView tvMsg;
        TextView tvCreatedTime;
        TextView tvUnreadMsgCount;

        public SessionListHolder3(View itemView) {
            super(itemView);
            rlytItem = (RelativeLayout) itemView.findViewById(R.id.rlyt_item);
            ivAvatar1 = (ImageView) itemView.findViewById(R.id.iv_avatar_1);
            ivAvatar2 = (ImageView) itemView.findViewById(R.id.iv_avatar_2);
            ivAvatar3 = (ImageView) itemView.findViewById(R.id.iv_avatar_3);
            tvUserName = (TextView) itemView.findViewById(R.id.tv_user_name);
            tvMsg = (TextView) itemView.findViewById(R.id.tv_msg);
            tvCreatedTime = (TextView) itemView.findViewById(R.id.tv_created_time);
            tvUnreadMsgCount = (TextView) itemView.findViewById(R.id.tv_unread_count);
        }
    }

    public static class SessionListHolder4 extends RecyclerView.ViewHolder {
        RelativeLayout rlytItem;
        ImageView ivAvatar1;
        ImageView ivAvatar2;
        ImageView ivAvatar3;
        ImageView ivAvatar4;
        TextView tvUserName;
        TextView tvMsg;
        TextView tvCreatedTime;
        TextView tvUnreadMsgCount;

        public SessionListHolder4(View itemView) {
            super(itemView);
            rlytItem = (RelativeLayout) itemView.findViewById(R.id.rlyt_item);
            ivAvatar1 = (ImageView) itemView.findViewById(R.id.iv_avatar_1);
            ivAvatar2 = (ImageView) itemView.findViewById(R.id.iv_avatar_2);
            ivAvatar3 = (ImageView) itemView.findViewById(R.id.iv_avatar_3);
            ivAvatar4 = (ImageView) itemView.findViewById(R.id.iv_avatar_4);
            tvUserName = (TextView) itemView.findViewById(R.id.tv_user_name);
            tvMsg = (TextView) itemView.findViewById(R.id.tv_msg);
            tvCreatedTime = (TextView) itemView.findViewById(R.id.tv_created_time);
            tvUnreadMsgCount = (TextView) itemView.findViewById(R.id.tv_unread_count);
        }
    }

    public void setSessionList(List<GroupInfo> listSessionInfo) {
        mListGroupInfo = listSessionInfo;
        notifyDataSetChanged();
    }

    public interface OnItemClickListener {
        void onItemClick(View view, GroupInfo groupInfo);
        void onItemLongClick(GroupInfo groupInfo);
    }
}
