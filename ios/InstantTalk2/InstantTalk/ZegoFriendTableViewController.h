//
//  ZegoFriendTableViewController.h
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZegoFriendTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;

- (UIEdgeInsets)tableViewCellInsets;

@end

@interface ZegoFriendTableViewController : UITableViewController

@end
