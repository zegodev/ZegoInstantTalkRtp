//
//  ZegoLiveViewController.m
//  LiveDemo3
//
//  Created by Strong on 16/6/28.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoLiveViewController.h"
#import "ZegoAnchorOptionViewController.h"
#import "ZegoSettings.h"
#import "ZegoLogTableViewController.h"

@interface ZegoLiveViewController ()

@property (nonatomic, assign) NSUInteger subViewSpace;
@property (nonatomic, assign) NSUInteger subViewWidth;
@property (nonatomic, assign) NSUInteger subViewHeight;
@property (nonatomic, assign) NSUInteger subViewPerRow;

@end

@implementation ZegoLiveViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _maxStreamCount = [ZegoLiveRoomApi getMaxPlayChannelCount];
    self.subViewSpace = 10;
    if (self.maxStreamCount <= 3)
    {
        self.subViewWidth = 140;
        self.subViewHeight = 210;
        self.subViewPerRow = 2;
    }
    else
    {
        self.subViewWidth = 90;
        self.subViewHeight = 135;
        self.subViewPerRow = 3;
    }
    
    self.useFrontCamera = YES;
    self.enableTorch = NO;
    self.beautifyFeature = ZEGO_BEAUTIFY_POLISH | ZEGO_BEAUTIFY_WHITEN;
    self.filter = ZEGO_FILTER_NONE;
    
    self.enableMicrophone = YES;
    self.viewMode = ZegoVideoViewModeScaleAspectFill;
    self.enableCamera = YES;
    
    self.logArray = [NSMutableArray array];
    self.qualityLogArray = [NSMutableArray array];
    
    // 设置当前的手机方向
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [[ZegoInstantTalk api] setAppOrientation:orientation];
    
    // 监听电话事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionWasInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    
    //彩蛋
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onShowStaticsViewController:)];
    [self.view addGestureRecognizer:longPressGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setIdelTimerDisable:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setIdelTimerDisable:NO];
    
    if (self.isBeingDismissed)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Event response

- (void)audioSessionWasInterrupted:(NSNotification *)notification
{
    NSLog(@"%s: %@", __func__, notification);
    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        // 暂停音频设备
        [[ZegoInstantTalk api] pauseModule:ZEGOAPI_MODULE_AUDIO];
    }
    else if(AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        // 恢复音频设备
        [[ZegoInstantTalk api] resumeModule:ZEGOAPI_MODULE_AUDIO];
    }
}

- (void)onShowStaticsViewController:(UIGestureRecognizer *)gesture
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"logNavigationID"];
    
    ZegoLogTableViewController *logViewController = (ZegoLogTableViewController *)[navigationController.viewControllers firstObject];
    logViewController.logArray = self.qualityLogArray;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Public method

- (void)setAnchorConfig:(UIView *)publishView
{
    ZegoAVConfig *config = [ZegoSettings sharedInstance].currentConfig;
    
    CGFloat height = config.videoEncodeResolution.height;
    CGFloat width = config.videoEncodeResolution.width;
    
    // 如果开播前横屏，则切换视频采集分辨率的宽高
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        // * adjust width/height for landscape
        config.videoEncodeResolution = CGSizeMake(MAX(height, width), MIN(height, width));
    }
    else
    {
        config.videoEncodeResolution = CGSizeMake(MIN(height, width), MAX(height, width));
    }
    
    config.videoCaptureResolution = config.videoEncodeResolution;
    
    int ret = [[ZegoInstantTalk api] setAVConfig:config];
    assert(ret == 1);
    
    bool b = [[ZegoInstantTalk api] setFrontCam:self.useFrontCamera];
    assert(b);
    
    b = [[ZegoInstantTalk api] enableMic:self.enableMicrophone];
    assert(b);
    
    b = [[ZegoInstantTalk api] enableBeautifying:self.beautifyFeature];
    assert(b);
    
    [self enablePreview:YES LocalView:publishView];
    [[ZegoInstantTalk api] setPreviewViewMode:self.viewMode];
}

- (void)showPublishOption
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZegoAnchorOptionViewController *optionController = (ZegoAnchorOptionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"anchorOptionID"];
    
    optionController.useFrontCamera = self.useFrontCamera;
    optionController.enableMicrophone = self.enableMicrophone;
    optionController.enableTorch = self.enableTorch;
    optionController.beautifyRow = self.beautifyFeature;
    optionController.filterRow = self.filter;
    optionController.enableCamera = self.enableCamera;
    
    optionController.delegate = self;
    
    self.definesPresentationContext = YES;
    if (![self isDeviceiOS7])
        optionController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    else
        optionController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    optionController.view.backgroundColor = [UIColor clearColor];
    [self presentViewController:optionController animated:YES completion:nil];
}

- (BOOL)isDeviceiOS7
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        return YES;
    
    return NO;
}

- (void)setIdelTimerDisable:(BOOL)disable
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:disable];
}

- (NSString *)getCurrentTime
{
    //    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH-mm-ss:SSS";
    return [formatter stringFromDate:[NSDate date]];
}

- (void)addLogString:(NSString *)logString
{
    if (logString.length != 0)
    {
        NSString *totalString = [NSString stringWithFormat:@"%@: %@", [self getCurrentTime], logString];
        [self.logArray insertObject:totalString atIndex:0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logUpdateNotification" object:self userInfo:nil];
    }
}

- (void)updateQuality:(int)quality detail:(NSString *)detail onView:(UIView *)playerView
{
    if (playerView == nil)
        return;
    
    CALayer *qualityLayer = nil;
    CATextLayer *textLayer = nil;
    
    for (CALayer *layer in playerView.layer.sublayers)
    {
        if ([layer.name isEqualToString:@"quality"])
            qualityLayer = layer;
        
        if ([layer.name isEqualToString:@"indicate"])
            textLayer = (CATextLayer *)layer;
    }
    
    int originQuality = 0;
    if (qualityLayer != nil)
    {
        if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor greenColor].CGColor))
            originQuality = 0;
        else if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor yellowColor].CGColor))
            originQuality = 1;
        else if (CGColorEqualToColor(qualityLayer.backgroundColor, [UIColor redColor].CGColor))
            originQuality = 2;
        else
            originQuality = 3;
        
        //        if (quality == originQuality)
        //            return;
    }
    
    UIFont *textFont = [UIFont systemFontOfSize:12];
    
    if (qualityLayer == nil)
    {
        qualityLayer = [CALayer layer];
        qualityLayer.name = @"quality";
        [playerView.layer addSublayer:qualityLayer];
        qualityLayer.frame = CGRectMake(12, 22, 10, 10);
        qualityLayer.contentsScale = [UIScreen mainScreen].scale;
        qualityLayer.cornerRadius = 5.0f;
    }
    
    if (textLayer == nil)
    {
        textLayer = [CATextLayer layer];
        textLayer.name = @"indicate";
        [playerView.layer addSublayer:textLayer];
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        textLayer.wrapped = YES;
        textLayer.font = (__bridge CFTypeRef)textFont.fontName;
        textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        textLayer.fontSize = textFont.pointSize;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    
    UIColor *qualityColor = nil;
    NSString *text = nil;
    if (quality == 0)
    {
        qualityColor = [UIColor greenColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"优", nil)];
    }
    else if (quality == 1)
    {
        qualityColor = [UIColor yellowColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"良", nil)];
    }
    else if (quality == 2)
    {
        qualityColor = [UIColor redColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"中", nil)];
    }
    else
    {
        qualityColor = [UIColor grayColor];
        text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"当前质量:", nil), NSLocalizedString(@"差", nil)];
    }
    
    qualityLayer.backgroundColor = qualityColor.CGColor;
    
    NSString *totalString = [NSString stringWithFormat:@"%@  %@", text, detail];
    
    //    CGSize textSize = [totalString sizeWithAttributes:@{NSFontAttributeName: textFont}];
    
    CGSize textSize = [totalString boundingRectWithSize:CGSizeMake(playerView.bounds.size.width - 30, 0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:textFont}
                                                context:nil].size;
    
    CGRect textFrame = CGRectMake(CGRectGetMaxX(qualityLayer.frame) + 3,
                                  CGRectGetMinY(qualityLayer.frame) - 3,
                                  ceilf(textSize.width),
                                  ceilf(textSize.height) + 10);
    textLayer.frame = textFrame;
    textLayer.string = totalString;
}

- (NSString *)addStaticsInfo:(BOOL)publish stream:(NSString *)streamID fps:(double)fps kbs:(double)kbs rtt:(int)rtt pktLostRate:(int)pktLostRate
{
    if (streamID.length == 0)
        return nil;
    
    // 丢包率的取值为 0~255，需要除以 256.0 得到丢包率百分比
    NSString *qualityString = [NSString stringWithFormat:NSLocalizedString(@"[%@] 帧率: %.3f, 视频码率: %.3f kb/s, 延时: %d ms, 丢包率: %.3f%%", nil), publish ? NSLocalizedString(@"推流", nil): NSLocalizedString(@"拉流", nil), fps, kbs, rtt, pktLostRate/256.0 * 100];
    NSString *totalString =[NSString stringWithFormat:NSLocalizedString(@"[%@] 流ID: %@, 帧率: %.3f, 视频码率: %.3f kb/s, 延时: %d ms, 丢包率: %.3f%%", nil), publish ? NSLocalizedString(@"推流", nil): NSLocalizedString(@"拉流", nil), streamID, fps, kbs, rtt, pktLostRate/256.0 * 100];
    [self.qualityLogArray insertObject:totalString atIndex:0];
    
    // 通知 log 界面更新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logUpdateNotification" object:self userInfo:nil];
    
    return qualityString;
}

#pragma mark -- Constraints

- (BOOL)setContainerConstraints:(UIView *)view containerView:(UIView *)containerView viewCount:(NSUInteger)viewCount
{
    [self addPlayViewConstraints:view containerView:containerView viewIndex:viewCount];
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    return YES;
}

// 点击切换视图，约束更新
- (void)updateContainerConstraintsForTap:(UIView *)tapView containerView:(UIView *)containerView
{
    UIView *bigView = [self getFirstViewInContainer:containerView];
    
    // 点击大视图，不做切换
    if (bigView == tapView || tapView == nil)
        return;
    
    // 点击小视图，在将小视图与大视图交换
    NSUInteger tapIndex = [self getViewIndex:tapView containerView:containerView];
    [containerView removeConstraints:containerView.constraints];
    [containerView exchangeSubviewAtIndex:0 withSubviewAtIndex:tapIndex];
    
    // 重新对每个视图进行约束设置
    for (int i = 0; i < containerView.subviews.count; i++)
    {
        UIView *view = containerView.subviews[i];
        [self addPlayViewConstraints:view containerView:containerView viewIndex:i];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}

// 流删减后视图，约束更新
- (void)updateContainerConstraintsForRemove:(UIView *)removeView containerView:(UIView *)containerView
{
    if (removeView == nil)
        return;
    
    NSUInteger removeIndex = [self getViewIndex:removeView containerView:containerView];
    [containerView removeConstraints:containerView.constraints];
    
    for (UIView *view in containerView.subviews)
    {
        NSUInteger viewIndex = [self getViewIndex:view containerView:containerView];
        if (viewIndex == 0 && removeIndex != 0)
            [self addFirstPlayViewConstraints:view containerView:containerView];
        else if (viewIndex > removeIndex)
            [self addPlayViewConstraints:view containerView:containerView viewIndex:viewIndex - 1];
        else if (viewIndex < removeIndex)
            [self addPlayViewConstraints:view containerView:containerView viewIndex:viewIndex];
    }
    
    [removeView removeFromSuperview];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Private method

#pragma mark -- Constraint 

- (void)addFirstPlayViewConstraints:(UIView *)firstView containerView:(UIView *)containerView
{
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[firstView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstView)]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[firstView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstView)]];
}

- (UIView *)getFirstViewInContainer:(UIView *)containerView
{
    for (UIView *subview in containerView.subviews)
    {
        if (CGRectGetWidth(subview.frame) == CGRectGetWidth(containerView.frame))
            return subview;
    }
    
    return nil;
}

// 为预览视图设置约束
- (void)addPlayViewConstraints:(UIView *)view containerView:(UIView *)containerView viewIndex:(NSUInteger)viewIndex
{
    // 只有一个预览 view
    if (viewIndex == 0)
        [self addFirstPlayViewConstraints:view containerView:containerView];
    else
    {
        NSUInteger xIndex = (viewIndex - 1) % self.subViewPerRow;
        NSUInteger yIndex = (viewIndex - 1) / self.subViewPerRow;
        
        CGFloat xToLeftConstraints = xIndex * (self.subViewSpace + self.subViewWidth) + self.subViewSpace;
        CGFloat yToBottomConstraints = yIndex * (self.subViewSpace + self.subViewHeight) + self.subViewSpace;
        
        // 推流分辨率，height 大于 width 时（竖屏推流）
        NSLayoutConstraint *widthConstraints;
        NSLayoutConstraint *heightConstraints;
        
        widthConstraints = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:self.subViewWidth];
        heightConstraints = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:self.subViewHeight];
        
        NSLayoutConstraint *leftConstraints = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:xToLeftConstraints];
        NSLayoutConstraint *bottomConstraints = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:yToBottomConstraints];
    
        [containerView addConstraints:@[widthConstraints, heightConstraints, leftConstraints, bottomConstraints]];
    }
}

- (NSUInteger)getViewIndex:(UIView *)view containerView:(UIView *)containerView
{
    if (CGRectGetWidth(view.frame) == CGRectGetWidth(containerView.frame) &&
        CGRectGetHeight(view.frame) == CGRectGetHeight(containerView.frame))
        return 0;
    else
    {
        CGFloat deltaHeight = CGRectGetHeight(containerView.frame) - CGRectGetMaxY(view.frame) - self.subViewSpace;
        CGFloat deltaWidth = CGRectGetWidth(containerView.frame) - CGRectGetMaxX(view.frame) - self.subViewSpace;
        
        NSUInteger xIndex = deltaWidth / (self.subViewSpace + self.subViewWidth);
        NSUInteger yIndex = deltaHeight / (self.subViewSpace + self.subViewHeight);
        
        return yIndex * self.subViewPerRow + xIndex + 1;
    }
}

#pragma mark - ZegoAnchorOptionDelegate

- (void)onUseFrontCamera:(BOOL)use
{
    self.useFrontCamera = use;
}

- (void)onEnableMicrophone:(BOOL)enabled
{
    self.enableMicrophone = enabled;
}

- (void)onEnableTorch:(BOOL)enable
{
    self.enableTorch = enable;
}

- (void)onSelectedBeautify:(NSInteger)row
{
    self.beautifyFeature = row;
}

- (void)onSelectedFilter:(NSInteger)row
{
    self.filter = row;
}

- (void)onEnableCamera:(BOOL)enabled
{
    self.enableCamera = enabled;
}

#pragma mark - Setter

- (void)setBeautifyFeature:(ZegoBeautifyFeature)beautifyFeature
{
    if (_beautifyFeature == beautifyFeature)
        return;
    
    _beautifyFeature = beautifyFeature;
    [[ZegoInstantTalk api] enableBeautifying:beautifyFeature];
}

- (void)setFilter:(ZegoFilter)filter
{
    if (_filter == filter)
        return;
    
    _filter = filter;
    [[ZegoInstantTalk api] setFilter:filter];
}

- (void)setUseFrontCamera:(BOOL)useFrontCamera
{
    if (_useFrontCamera == useFrontCamera)
        return;
    
    _useFrontCamera = useFrontCamera;
    [[ZegoInstantTalk api] setFrontCam:useFrontCamera];
}

- (void)setEnableMicrophone:(BOOL)enableMicrophone
{
    if (_enableMicrophone == enableMicrophone)
        return;
    
    _enableMicrophone = enableMicrophone;
    [[ZegoInstantTalk api] enableMic:enableMicrophone];
}

- (void)setEnableTorch:(BOOL)enableTorch
{
    if (_enableTorch == enableTorch)
        return;
    
    _enableTorch = enableTorch;
    [[ZegoInstantTalk api] enableTorch:enableTorch];
}

- (void)setEnableCamera:(BOOL)enableCamera
{
    if (_enableCamera == enableCamera)
        return;
    
    _enableCamera = enableCamera;
    [[ZegoInstantTalk api] enableCamera:enableCamera];
}

- (void)enablePreview:(BOOL)enable LocalView:(UIView *)view
{
    if (enable && view)
    {
        [[ZegoInstantTalk api] setPreviewView:view];
        [[ZegoInstantTalk api] startPreview];
    }
    else
    {
        [[ZegoInstantTalk api] setPreviewView:nil];
        [[ZegoInstantTalk api] stopPreview];
    }
}

@end
