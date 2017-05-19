//
//  ZegoMessageTableViewController.h
//  InstantTalk
//
//  Created by Strong on 16/7/11.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZegoMessageTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastMessageLabel;
@property (nonatomic, weak) IBOutlet UILabel *unreadCount;

- (UIEdgeInsets)tableViewCellInsets;

@end

@interface ZegoMessageTableViewController : UITableViewController

@end
