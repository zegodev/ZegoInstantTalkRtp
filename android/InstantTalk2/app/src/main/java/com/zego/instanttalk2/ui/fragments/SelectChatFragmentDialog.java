package com.zego.instanttalk2.ui.fragments;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.zego.instanttalk2.R;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public class SelectChatFragmentDialog extends DialogFragment {

    private TextView mTvMultiUsersChat;
    private TextView mTvMultiUsersVideoChat;
    private OnSelectChatListener mSelectChatListener;

    public void setSelectChatListener(OnSelectChatListener listener){
        mSelectChatListener = listener;
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {

        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

        LayoutInflater inflater = getActivity().getLayoutInflater();
        View view = inflater.inflate(R.layout.fragment_dialog_select_chat, null);

        mTvMultiUsersChat = (TextView) view.findViewById(R.id.tv_multi_users_chat);
        mTvMultiUsersChat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mSelectChatListener != null){
                    dismiss();
                    mSelectChatListener.onSelectMultiUsersChat();
                }
            }
        });

        mTvMultiUsersVideoChat = (TextView) view.findViewById(R.id.tv_multi_users_video_chat);
        mTvMultiUsersVideoChat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mSelectChatListener != null){
                    dismiss();
                    mSelectChatListener.onSelectMultiUsersVideoChat();
                }
            }
        });

        builder.setView(view);

        return builder.create();
    }

    public interface OnSelectChatListener{
        void onSelectMultiUsersChat();
        void onSelectMultiUsersVideoChat();
    }
}
