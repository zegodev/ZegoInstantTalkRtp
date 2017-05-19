//
//  ZegoMessageTableViewCell.m
//  InstantTalk
//
//  Created by Strong on 16/7/8.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoChatTableViewCell.h"

@interface ZegoChatTableViewCell ()

@property (nonatomic, strong) UITextView *messageBubbleTextView;
@property (nonatomic, strong) UIImageView *opponentImageView;

@end

@implementation ZegoChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _messageBubbleTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
        self.messageBubbleTextView.font = [UIFont systemFontOfSize:17];
        self.messageBubbleTextView.scrollEnabled = NO;
        self.messageBubbleTextView.editable = NO;
        self.messageBubbleTextView.textContainerInset = UIEdgeInsetsMake(7, 7, 7, 7);
        self.messageBubbleTextView.layer.cornerRadius = 15.0;
        self.messageBubbleTextView.layer.borderWidth = 1.0;
        [self.contentView addSubview:self.messageBubbleTextView];
        
        _opponentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.opponentImageView.hidden = YES;
        self.opponentImageView.bounds = CGRectMake(0, 0, 30, 30);
        
        CGFloat halfWidth = CGRectGetWidth(self.opponentImageView.bounds) / 2.0;
        CGFloat halfHeight = CGRectGetHeight(self.opponentImageView.bounds) / 2.0;
        CGFloat textViewSingleLineCenter = self.messageBubbleTextView.textContainerInset.top + self.messageBubbleTextView.font.lineHeight / 2.0;
        self.opponentImageView.center = CGPointMake(5.0 + halfWidth, textViewSingleLineCenter);
        self.opponentImageView.backgroundColor = [UIColor lightTextColor];
        self.opponentImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.opponentImageView.layer.shouldRasterize = YES;
        self.opponentImageView.layer.cornerRadius = halfHeight;
        self.opponentImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.opponentImageView];
    };
    
    return self;
}

- (CGSize)setupMessage:(NSString *)messageContent oppentImage:(UIImage *)opponentImage
{
    self.messageBubbleTextView.text = messageContent;
    if (opponentImage != nil)
        self.opponentImageView.image = opponentImage;
    
    CGSize size = [self.messageBubbleTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds) * 0.75, CGFLOAT_MAX)];
    if (size.height < 30.0)
        size.height = 30.0;
    
    self.messageBubbleTextView.bounds = CGRectMake(0, 0, size.width, size.height);
    
    BOOL sendByOpponent = opponentImage == nil ? NO: YES;
    [self styleTextViewForSentBy:sendByOpponent];
    
    return size;
}

- (void)styleTextViewForSentBy:(BOOL)sendByOpponent
{
    CGFloat halftTextViewWidth = CGRectGetWidth(self.messageBubbleTextView.bounds) / 2.0;
    CGFloat targetX = halftTextViewWidth + 5.0;
    CGFloat halfTextViewHeight = CGRectGetHeight(self.messageBubbleTextView.bounds) / 2.0;
    
    if (sendByOpponent)
    {
        self.messageBubbleTextView.center = CGPointMake(targetX, halfTextViewHeight);
        self.messageBubbleTextView.layer.borderColor = [UIColor colorWithRed:0.142954 green:0.60323 blue:0.862548 alpha:0.88].CGColor;
        if (self.opponentImageView.image != nil)
        {
            self.opponentImageView.hidden = NO;
            CGFloat centerX = self.messageBubbleTextView.center.x + CGRectGetWidth(self.opponentImageView.bounds) + 5;
            self.messageBubbleTextView.center = CGPointMake(centerX, halfTextViewHeight);
        }
    }
    else
    {
        self.opponentImageView.hidden = YES;
        self.messageBubbleTextView.center = CGPointMake(CGRectGetWidth(self.bounds) - targetX, halfTextViewHeight);
        self.messageBubbleTextView.layer.borderColor = [UIColor colorWithRed:0.14726 green:0.838161 blue:0.533935 alpha:1].CGColor;
    }
}
@end
