//
//  ZegoTabBarViewController.h
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoDataCenter.h"

@interface ZegoTabBarViewController : UITabBarController

- (void)addObserver;
- (void)removeObserver;
- (void)showRequestVideoAlert:(ZegoRequestTalkInfo *)request;

@end
