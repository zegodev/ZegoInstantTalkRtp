package com.zego.instanttalk2.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.zego.instanttalk2.R;
import com.zego.instanttalk2.entities.ChatMsg;
import com.zego.instanttalk2.utils.BizLiveUitl;

import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public class NewChatAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private LayoutInflater mLayoutInflater;

    private List<ChatMsg> mListMsg;

    public NewChatAdapter(Context context) {
        mLayoutInflater = LayoutInflater.from(context);
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        if(viewType == ChatMsg.VALUE_LEFT_TEXT){
            return new ViewHolderLeftText(mLayoutInflater.inflate(R.layout.list_item_left_text, parent, false));
        }else {
            return new ViewHolderRightText(mLayoutInflater.inflate(R.layout.list_item_right_text, parent, false));
        }
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {

        ChatMsg msg = mListMsg.get(position);

        if(holder instanceof ViewHolderLeftText){
            ((ViewHolderLeftText)holder).ivAvatar.setImageBitmap(BizLiveUitl.getAvatarByUserID(msg.getFromUserID()));
            ((ViewHolderLeftText)holder).tvMsg.setText(msg.getContent());
        }else {
            ((ViewHolderRightText)holder).ivAvatar.setImageBitmap(BizLiveUitl.getAvatarByUserID(msg.getFromUserID()));
            ((ViewHolderRightText)holder).tvMsg.setText(msg.getContent());
        }
    }

    @Override
    public int getItemCount() {
        return mListMsg == null ? 0 : mListMsg.size();
    }

    @Override
    public int getItemViewType(int position) {
        return mListMsg.get(position).getType();
    }

    class ViewHolderLeftText extends RecyclerView.ViewHolder{
        private ImageView ivAvatar;
        private TextView  tvMsg;

        public ViewHolderLeftText(View itemView) {
            super(itemView);
            ivAvatar = (ImageView)itemView.findViewById(R.id.iv_avatar);
            tvMsg = (TextView)itemView.findViewById(R.id.tv_msg);
        }
    }

    public static class ViewHolderRightText extends RecyclerView.ViewHolder{
        private ImageView ivAvatar;
        private TextView  tvMsg;

        public ViewHolderRightText(View itemView) {
            super(itemView);
            ivAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            tvMsg = (TextView)itemView.findViewById(R.id.tv_msg);
        }
    }

    public void setMsgList(List<ChatMsg> listMsg){
        mListMsg = listMsg;
        notifyDataSetChanged();
    }

}
