package com.zego.instanttalk2.entities;

import android.os.Parcel;
import android.os.Parcelable;

import java.io.Serializable;

public class BizUser implements Parcelable, Serializable{
    public String userID;
    public String userName;

    public BizUser(){

    }

    protected BizUser(Parcel in) {
        userID = in.readString();
        userName = in.readString();
    }

    public static final Creator<BizUser> CREATOR = new Creator<BizUser>() {
        @Override
        public BizUser createFromParcel(Parcel in) {
            return new BizUser(in);
        }

        @Override
        public BizUser[] newArray(int size) {
            return new BizUser[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(userID);
        dest.writeString(userName);
    }
}
