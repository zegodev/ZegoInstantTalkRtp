//
//  ZegoCheckBox.m
//  InstantTalk
//
//  Created by Strong on 16/7/13.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoCheckBox.h"

@interface ZegoCheckBox ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *checkMarkLayer;

@end

@implementation ZegoCheckBox
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (UIBezierPath *)pathForCircle
{
    CGFloat radius = CGRectGetWidth(self.bounds) / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:- M_PI_4 endAngle:2 * M_PI - M_PI_4 clockwise:YES];
    
    return path;
}

- (UIBezierPath *)pathForCheckMark
{
    UIBezierPath* checkMarkPath = [UIBezierPath bezierPath];
    
    CGFloat size = CGRectGetWidth(self.bounds);
    [checkMarkPath moveToPoint: CGPointMake(size/3.1578, size/2)];
    [checkMarkPath addLineToPoint: CGPointMake(size/2.0618, size/1.57894)];
    [checkMarkPath addLineToPoint: CGPointMake(size/1.3953, size/2.7272)];
    
    return checkMarkPath;
}

- (void)commonInit
{
    _on = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.circleLayer = [CAShapeLayer layer];
    self.circleLayer.frame = self.bounds;
    self.circleLayer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    self.circleLayer.shouldRasterize = YES;
    self.circleLayer.path = [self pathForCircle].CGPath;
    self.circleLayer.lineWidth = 2.0;
    
    [self.layer addSublayer:self.circleLayer];
    
    [self drawOffBox];
}

- (void)setOn:(BOOL)on
{
    if (_on != on)
    {
        _on = on;
        [self drawCheckBox:on];
    }
}

- (void)drawOnBox
{
    self.circleLayer.fillColor = [UIColor colorWithRed:0 green:122.0/255 blue:1 alpha:1].CGColor;
    self.circleLayer.strokeColor = [UIColor colorWithRed:0 green:122.0/255 blue:1 alpha:1].CGColor;
    
    [self.checkMarkLayer removeFromSuperlayer];
    self.checkMarkLayer = [CAShapeLayer layer];
    self.checkMarkLayer.frame = self.bounds;
    self.checkMarkLayer.path = [self pathForCheckMark].CGPath;
    self.checkMarkLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.checkMarkLayer.lineWidth = 2.0;
    self.checkMarkLayer.fillColor = [UIColor clearColor].CGColor;
    self.checkMarkLayer.lineCap = kCALineCapRound;
    self.checkMarkLayer.lineJoin = kCALineJoinRound;
    
    self.checkMarkLayer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    self.checkMarkLayer.shouldRasterize = YES;
    [self.layer addSublayer:self.checkMarkLayer];
}

- (void)drawOffBox
{
    [self.checkMarkLayer removeFromSuperlayer];
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    self.circleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
}

- (void)drawCheckBox:(BOOL)on
{
    if (on)
    {
        [self drawOnBox];
    }
    else
    {
        [self drawOffBox];
    }
}

@end
