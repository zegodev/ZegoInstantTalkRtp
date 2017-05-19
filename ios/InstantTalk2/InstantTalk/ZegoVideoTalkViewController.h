//
//  ZegoVideoTalkViewController.h
//  InstantTalk
//
//  Created by Strong on 16/7/11.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoSettings.h"
#import "ZegoLiveViewController.h"

@interface ZegoVideoTalkViewController : ZegoLiveViewController

//YES 请求方， NO 应答方
@property (nonatomic, assign) BOOL isRequester;
@property (nonatomic, strong) NSArray<ZegoUser *> *userList;
@property (nonatomic, assign) NSString *videoRoomId;

@end
