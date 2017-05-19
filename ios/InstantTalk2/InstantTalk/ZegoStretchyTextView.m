//
//  ZegoStretchyTextView.m
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoStretchyTextView.h"

#define MAX_INPUT_LENGTH    256

@interface ZegoStretchyTextView ()
@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat maxHeightPortrait;
@property (nonatomic, assign) CGFloat maxHeightLandScape;

//专门用来计算真实高度
@property (nonatomic, strong) UITextView *sizingTextView;

@end

@implementation ZegoStretchyTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self)
    {
//        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
//        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.font = [UIFont systemFontOfSize:17.0];
    self.textContainerInset = UIEdgeInsetsMake(2, 2, 2, 2);
    self.maxHeightPortrait = 160;
    self.maxHeightLandScape = 60.0;
    
    _sizingTextView = [[UITextView alloc] init];
    
    self.delegate = self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (CGFloat)maxHeight
{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
        return self.maxHeightPortrait;
    
    return self.maxHeightLandScape;
}

- (void)setIsValid:(BOOL)isValid
{
    if (_isValid != isValid)
    {
        _isValid = isValid;
        
        if ([self.stretchyTextViewDelegate respondsToSelector:@selector(stretchyTextView:validityDidChange:)])
            [self.stretchyTextViewDelegate stretchyTextView:self validityDidChange:isValid];
    }
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    [self resize];
}

- (CGFloat)targetHeight
{
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), self.maxHeightPortrait);
    self.sizingTextView.textContainerInset = self.textContainerInset;
    self.sizingTextView.font = self.font;
    self.sizingTextView.text = self.text;
    CGSize targetSize = [self.sizingTextView sizeThatFits:maxSize];
    
    if (targetSize.height < self.maxHeight)
        return targetSize.height;
    
    return self.maxHeight;
}

- (void)resize
{
    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, [self targetHeight]);
    if ([self.stretchyTextViewDelegate respondsToSelector:@selector(stretchyTextViewDidChangeSize:)])
        [self.stretchyTextViewDelegate stretchyTextViewDidChangeSize:self];
}

- (void)align
{
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    if (CGRectIsEmpty(caretRect))
    {
        return;
    }
    
    CGFloat topOfLine = CGRectGetMinY(caretRect);
    CGFloat bottomOfLine = CGRectGetMaxY(caretRect);
    
    CGFloat contentOffsetTop = self.contentOffset.y;
    CGFloat bottomOfVisibleTextArea = contentOffsetTop + CGRectGetHeight(self.bounds);
    
    CGFloat caretHeightPlusInsets = CGRectGetHeight(caretRect) + self.textContainerInset.top + self.textContainerInset.bottom;
    if (caretHeightPlusInsets < CGRectGetHeight(self.bounds))
    {
        CGFloat overflow = 0;
        if (topOfLine < contentOffsetTop + self.textContainerInset.top)
            overflow = topOfLine - contentOffsetTop - self.textContainerInset.top;
        else if (bottomOfLine > bottomOfVisibleTextArea - self.textContainerInset.bottom)
            overflow = (bottomOfLine - bottomOfVisibleTextArea) + self.textContainerInset.bottom;
        
        CGFloat offset = self.contentOffset.y;
        self.contentOffset = CGPointMake(self.contentOffset.x, offset + overflow);
    }
}

#pragma mark UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self align];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.isValid = (textView.text.length > 0 && textView.text.length < MAX_INPUT_LENGTH);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nonnull NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        if ([self.stretchyTextViewDelegate respondsToSelector:@selector(stretchyTextViewDidPressReturn:)])
            [self.stretchyTextViewDelegate stretchyTextViewDidPressReturn:self];
        
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.stretchyTextViewDelegate respondsToSelector:@selector(stretchyTextViewDidBeginEditing:)])
        [self.stretchyTextViewDelegate stretchyTextViewDidBeginEditing:self];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.stretchyTextViewDelegate respondsToSelector:@selector(stretchyTextVIewDidEndEditing:)])
        [self.stretchyTextViewDelegate stretchyTextVIewDidEndEditing:self];
}

@end
