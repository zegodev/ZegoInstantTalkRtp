//
//  ZegoChatInput.h
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoStretchyTextView.h"

@class ZegoChatInput;

@protocol ZegoChatInputDelegate <NSObject>

- (void)chatInputDidResize:(ZegoChatInput *)chatInput;
- (void)chatInput:(ZegoChatInput *)chatInput didSendMessage:(NSString *)message;
- (void)chatInputBeginEditing:(ZegoChatInput *)chatInput;
- (void)chatInputEndEditing:(ZegoChatInput *)chatInput;

@end

@interface ZegoChatInput : UIView

@property (nonatomic, weak) id<ZegoChatInputDelegate> delegate;

@property (nonatomic, weak) IBOutlet ZegoStretchyTextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;


@end
