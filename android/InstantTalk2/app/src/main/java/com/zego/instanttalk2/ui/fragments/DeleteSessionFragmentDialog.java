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

public class DeleteSessionFragmentDialog extends DialogFragment {

    private TextView mTvDeleteSession;
    private OnDeleteSessionListener mOnDeleteSessionListener;

    public void setOnDeleteSessionListener(OnDeleteSessionListener listener){
        mOnDeleteSessionListener = listener;
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {

        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

        LayoutInflater inflater = getActivity().getLayoutInflater();
        View view = inflater.inflate(R.layout.fragment_dialog_delete_session, null);

        mTvDeleteSession = (TextView) view.findViewById(R.id.tv_delete_session);
        mTvDeleteSession.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnDeleteSessionListener != null){
                    dismiss();
                    mOnDeleteSessionListener.onDeleteSession();
                }
            }
        });

        builder.setView(view);

        return builder.create();
    }

    public interface OnDeleteSessionListener{
       void onDeleteSession();
    }
}
