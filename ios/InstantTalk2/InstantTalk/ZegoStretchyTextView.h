//
//  ZegoStretchyTextView.h
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZegoStretchyTextView;

@protocol ZegoStretchyTextViewDelegate <NSObject>

- (void)stretchyTextViewDidChangeSize:(ZegoStretchyTextView *)textView;
- (void)stretchyTextView:(ZegoStretchyTextView *)textView validityDidChange:(BOOL)isValid;
- (void)stretchyTextViewDidPressReturn:(ZegoStretchyTextView *)textView;
- (void)stretchyTextViewDidBeginEditing:(ZegoStretchyTextView *)textView;
- (void)stretchyTextVIewDidEndEditing:(ZegoStretchyTextView *)textView;

@end

@interface ZegoStretchyTextView : UITextView <UITextViewDelegate>

@property (nonatomic, weak) id<ZegoStretchyTextViewDelegate> stretchyTextViewDelegate;

@end
