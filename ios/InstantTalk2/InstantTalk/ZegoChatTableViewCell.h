//
//  ZegoMessageTableViewCell.h
//  InstantTalk
//
//  Created by Strong on 16/7/8.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZegoChatTableViewCell : UITableViewCell

//opponentImageName 为nil时说明为发送消息，否则为接收消息
- (CGSize)setupMessage:(NSString *)messageContent oppentImage:(UIImage *)opponentImage;

@end
