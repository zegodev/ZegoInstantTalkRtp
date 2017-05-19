package com.zego.instanttalk2.interfaces;


import com.zego.instanttalk2.entities.BizUser;

import java.util.List;

/**
 * Copyright © 2016 Zego. All rights reserved.
 * des:
 */

public interface UserListView {
    void onUserListUpdate(List<BizUser> listUser);
}
