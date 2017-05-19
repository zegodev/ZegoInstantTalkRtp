//
//  ZegoMenuViewController.h
//  InstantTalk
//
//  Created by Strong on 16/7/20.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZegoMenuViewControllerDelegate <NSObject>

- (void)onVideoTalkSelected;
- (void)onMessageTalkSelected;

@end

@interface ZegoMenuViewController : UIViewController

@property (nonatomic, weak) id<ZegoMenuViewControllerDelegate> delegate;

@end
