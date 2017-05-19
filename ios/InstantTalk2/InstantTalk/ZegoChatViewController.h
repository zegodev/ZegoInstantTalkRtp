//
//  ZegoChatViewController.h
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoAVKitManager.h"

@interface ZegoChatViewController : UIViewController

@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, strong) NSMutableArray<ZegoUser *> *userList;
@property (nonatomic, copy) NSString *chatTheme;

@end
