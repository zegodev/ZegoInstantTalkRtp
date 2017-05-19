//
//  ZegoFriendSelectViewController.h
//  InstantTalk
//
//  Created by Strong on 16/7/13.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoCheckBox.h"
#import "ZegoSettings.h"

@protocol ZegoFriendSelectDelegate <NSObject>

- (void)onSelectedFriends:(NSArray<ZegoUser *> *)selectedUsers videoSelector:(BOOL)videoSelector;

@end

@interface ZegoFriendSelectTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, weak) IBOutlet ZegoCheckBox *checkBox;

@end

@interface ZegoFriendSelectViewController : UIViewController

@property (nonatomic, weak) id<ZegoFriendSelectDelegate> delegate;
@property (nonatomic, assign) BOOL videoSelector;
@end
