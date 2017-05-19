//
//  ZegoChatInput.m
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoChatInput.h"

@interface ZegoChatInput () <ZegoStretchyTextViewDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *blurredView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *sendButtonHeightConstraint;

@end

@implementation ZegoChatInput

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
       
    }
    
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.textView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.textView.layer.shouldRasterize = YES;
    self.textView.layer.cornerRadius = 5.0;
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    self.textView.stretchyTextViewDelegate = self;
}

- (IBAction)sendButtonPressed:(id)sender
{
    if (self.textView.text.length > 0)
    {
        if ([self.delegate respondsToSelector:@selector(chatInput:didSendMessage:)])
            [self.delegate chatInput:self didSendMessage:self.textView.text];
        
        self.textView.text = @"";
    }
}

#pragma mark ZegoStretchyTextViewDelegate
- (void)stretchyTextViewDidChangeSize:(ZegoStretchyTextView *)textView
{
    CGFloat textViewHeight = CGRectGetHeight(textView.bounds);
    if (textView.text.length == 0)
        self.sendButtonHeightConstraint.constant = textViewHeight;
    
    CGFloat targetConstant = textViewHeight + 10;
    self.heightConstraint.constant = targetConstant;
    
    if ([self.delegate respondsToSelector:@selector(chatInputDidResize:)])
        [self.delegate chatInputDidResize:self];
}

- (void)stretchyTextView:(ZegoStretchyTextView *)textView validityDidChange:(BOOL)isValid
{
    self.sendButton.enabled = isValid;
}

- (void)stretchyTextViewDidPressReturn:(ZegoStretchyTextView *)textView
{
    [self sendButtonPressed:nil];
}

- (void)stretchyTextViewDidBeginEditing:(ZegoStretchyTextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(chatInputBeginEditing:)])
        [self.delegate chatInputBeginEditing:self];
}

- (void)stretchyTextVIewDidEndEditing:(ZegoStretchyTextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(chatInputEndEditing:)])
        [self.delegate chatInputEndEditing:self];
}
@end
