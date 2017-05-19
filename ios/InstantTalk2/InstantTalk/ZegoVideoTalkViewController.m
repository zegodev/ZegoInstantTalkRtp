//
//  ZegoVideoTalkViewController.m
//  InstantTalk
//
//  Created by Strong on 16/7/11.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoVideoTalkViewController.h"
#import "ZegoAVKitManager.h"
#import "ZegoDataCenter.h"
#import "ZegoLogTableViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ZegoVideoTalkViewController () <ZegoLivePlayerDelegate, ZegoLivePublisherDelegate, ZegoRoomDelegate>

@property (nonatomic, weak) IBOutlet UIView *playContainerView;
@property (nonatomic, weak) IBOutlet UILabel *tipsLabel;

@property (nonatomic, strong) NSMutableArray<ZegoStream *> *playStreamList;
@property (nonatomic, strong) NSMutableDictionary *viewContainersDict;

@property (nonatomic, copy) NSString *liveStreamID;

@property (nonatomic, strong) UIView *publishView;

@property (nonatomic, assign) BOOL firstPlayStream;
@property (nonatomic, assign) BOOL loginRoomSuccess;

@property (nonatomic, assign) NSUInteger refuseUserNumber;

@property (nonatomic, assign) BOOL isPublishing;
@property (nonatomic, assign) BOOL shouldInterrutped;

@property (nonatomic, strong) NSMutableArray *retryStreamList;
@property (nonatomic, strong) NSMutableArray *failedStreamList;

@end

@implementation ZegoVideoTalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewContainersDict = [[NSMutableDictionary alloc] initWithCapacity:self.maxStreamCount];
    _playStreamList = [[NSMutableArray alloc] init];
    _retryStreamList = [[NSMutableArray alloc] init];
    _failedStreamList = [[NSMutableArray alloc] init];
    
    BOOL videoAuthorization = [self checkVideoAuthorization];
    BOOL audioAuthorization = [self checkAudioAuthorization];
    
    if (videoAuthorization == YES)
    {
        if (audioAuthorization == NO)
        {
            [self showAuthorizationAlert:NSLocalizedString(@"直播视频,访问麦克风", nil) title:NSLocalizedString(@"需要访问麦克风", nil)];
        }
    }
    else
    {
        [self showAuthorizationAlert:NSLocalizedString(@"直播视频,访问相机", nil) title:NSLocalizedString(@"需要访问相机", nil)];
    }
    
    [self setupLiveKit];
    
    //先创建一个小view进行preview
    UIView *publishView = [self createPublishView];
    if (publishView)
    {
        [self setAnchorConfig:publishView];
        [[ZegoInstantTalk api] setPreviewView:publishView];
        self.publishView = publishView;
    }

    if (self.isRequester)
    {
        [self setVideoTalkRoom];
        
        //登录房间，登录成功后，等待对方回应
        self.tipsLabel.text = NSLocalizedString(@"开始登录房间...", nil);
        [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"开始登录房间 %@", nil), self.videoRoomId]];
        
        [[ZegoInstantTalk api] loginRoom:self.videoRoomId role:ZEGO_AUDIENCE withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
            if (errorCode == 0)
            {
                self.loginRoomSuccess = YES;
                [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"登录房间成功 %@", nil), self.videoRoomId]];
                [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"发送视频通话信令", nil)]];
                
                //发送信令请求
                [[ZegoDataCenter sharedInstance] requestVideoTalk:self.userList videoRoomId:self.videoRoomId completion:^(int errorCode) {
                    if (errorCode != 0)
                    {
                        self.tipsLabel.text = NSLocalizedString(@"请求视频通话失败...", nil);
                        [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"请求视频通话失败, errorCode %d", nil), errorCode]];
                        
                        [[ZegoInstantTalk api] logoutRoom];
                    }
                    else
                    {
                        //监听消息
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRespondVideoTalk:) name:kUserRespondVideoTalkNotification object:nil];
                        self.tipsLabel.text = NSLocalizedString(@"等待对方同意...", nil);
                        [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"等待对方同意", nil)]];
                    }
                }];
            }
            else
            {
                self.tipsLabel.text = NSLocalizedString(@"登录房间失败...", nil);
                [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"登录房间失败, errorCode %d", nil), errorCode]];
            }
        }];
    }
    else
    {
        //进入私有房间
        self.tipsLabel.text = NSLocalizedString(@"开始登录私有房间...", nil);
        [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"开始登录房间 %@", nil), self.videoRoomId]];
        
        [[ZegoInstantTalk api] loginRoom:self.videoRoomId role:ZEGO_AUDIENCE withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
            if (errorCode == 0)
            {
                self.tipsLabel.text = NSLocalizedString(@"登录房间成功...", nil);
                [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"登录房间成功 %@", nil), self.videoRoomId]];
                
                self.loginRoomSuccess = YES;
                
                //play stream
                if (streamList.count != 0)
                    [self onStreamUpdateForAdd:streamList];
                
                //开始推流
                [self createPublishStream];
                self.isPublishing = YES;
            }
            else
            {
                self.tipsLabel.text = NSLocalizedString(@"登录房间失败...", nil);
                [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"登录房间失败, errorCode %d", nil), errorCode]];
            }
        }];
    }
}

- (void)setVideoTalkRoom
{
    unsigned int token = [[ZegoSettings sharedInstance].userID intValue];
    if (token == 0 || token == 1)
        token = rand() + token;
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    unsigned int below = (unsigned int)currentTime & 0xFFFF;
    unsigned int high = (unsigned int)((token << 16) & 0xFFFFF0000);
    
    unsigned int random = high | below;
    
    self.videoRoomId = [NSString stringWithFormat:@"%@-%u", [ZegoSettings sharedInstance].userID, random];
}

- (void)openSetting
{
    NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:settingURL])
        [[UIApplication sharedApplication] openURL:settingURL];
}

- (void)showAuthorizationAlert:(NSString *)message title:(NSString *)title
{
    if ([self isDeviceiOS7])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"设置权限", nil), nil];
        [alertView show];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *settingAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"设置权限", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openSetting];
        }];
        
        [alertController addAction:settingAction];
        [alertController addAction:cancelAction];
        
        alertController.preferredAction = settingAction;
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self openSetting];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    if (self.isMovingFromParentViewController)
//    {
//        [self.checkTimer invalidate];
//        self.checkTimer = nil;
//    }
}

//检查相机权限
- (BOOL)checkVideoAuthorization
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoAuthStatus == AVAuthorizationStatusDenied || videoAuthStatus == AVAuthorizationStatusRestricted)
        return NO;
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        }];
    }
    return YES;
}

- (BOOL)checkAudioAuthorization
{
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioAuthStatus == AVAuthorizationStatusDenied || audioAuthStatus == AVAuthorizationStatusRestricted)
        return NO;
    if (audioAuthStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        }];
    }
    
    return YES;
}

- (void)setupLiveKit
{
    [[ZegoInstantTalk api] setRoomDelegate:self];
    [[ZegoInstantTalk api] setPublisherDelegate:self];
    [[ZegoInstantTalk api] setPlayerDelegate:self];
    
}

- (void)onRespondVideoTalk:(NSNotification *)notification
{
    BOOL agreed = [notification.userInfo[@"result"] boolValue];
    ZegoUser *user = notification.userInfo[@"user"];

    if (agreed)
    {
        [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"%@同意了你的请求", nil), user.userId]];
        
        //开始推流
        if (!self.isPublishing)
        {
            [self createPublishStream];
            self.isPublishing = YES;
        }
    }
    else
    {
        //有用户拒绝
        self.refuseUserNumber += 1;
        if (self.refuseUserNumber == self.userList.count - 1)
        {
            //所有用户都拒绝了
            if (self.userList.count == 2)
                self.tipsLabel.text = NSLocalizedString(@"对方拒绝了您的请求", nil);
            else
                self.tipsLabel.text = NSLocalizedString(@"所有人都拒绝了您的请求", nil);
        }
        
        [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"%@拒绝了你的请求", nil), user.userId]];
    }
}

- (void)closeAllStream
{
    if (self.isPublishing)
    {
        [[ZegoInstantTalk api] stopPreview];
        [[ZegoInstantTalk api] setPreviewView:nil];
        [[ZegoInstantTalk api] stopPublishing];
        [self removeStreamViewContainer:self.liveStreamID];
    }
    
    self.publishView = nil;
    self.firstPlayStream = NO;
    
    for (ZegoStream *info in self.playStreamList)
    {
        NSLog(@"stop Play Stream: %@", info.streamID);
        [[ZegoInstantTalk api] stopPlayingStream:info.streamID];
        [self removeStreamViewContainer:info.streamID];
    }
    
    [self.viewContainersDict removeAllObjects];
    [self.retryStreamList removeAllObjects];
}

- (IBAction)closeView:(id)sender
{
    self.tipsLabel.text = NSLocalizedString(@"退出视频聊天...", nil);

    if (self.loginRoomSuccess)
    {
        [self closeAllStream];
        
        [[ZegoInstantTalk api] logoutRoom];
    }
    
    if (self.isRequester)
        [[ZegoDataCenter sharedInstance] cancelVideoTalk];
    
    self.loginRoomSuccess = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onShowPublishOption:(id)sender
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


- (void)onTapView:(UIGestureRecognizer *)recognizer
{
    if (self.playContainerView.subviews.count < 2)
        return;
    
    UIView *view = recognizer.view;
    if (view == nil)
        return;
    
    [self updateContainerConstraintsForTap:view containerView:self.playContainerView];
}

#pragma mark publishView & playView

- (UIView *)createPublishView
{
    UIView *publishView = [[UIView alloc] init];
    publishView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playContainerView addSubview:publishView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapView:)];
    [publishView addGestureRecognizer:tapGesture];
    
    BOOL bResult = [self setContainerConstraints:publishView containerView:self.playContainerView viewCount:0];
    if (bResult == NO)
    {
        [publishView removeFromSuperview];
        return nil;
    }
    
    [self.playContainerView bringSubviewToFront:publishView];
    
    return publishView;
}

- (void)createPublishStream
{
    NSString *publishTitle = [NSString stringWithFormat:@"Hello-%@", [ZegoSettings sharedInstance].userName];
    
    NSUInteger currentTime = (NSUInteger)[[NSDate date] timeIntervalSince1970];
    self.liveStreamID = [NSString stringWithFormat:@"s-%@-%lu", [ZegoSettings sharedInstance].userID, (unsigned long)currentTime];
    
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"开始发布直播 %@", nil), self.liveStreamID];
    [self addLogString:logString];
    
    [self setAnchorConfig:self.publishView];
    [[ZegoInstantTalk api] startPublishing:self.liveStreamID title:publishTitle flag:ZEGO_JOIN_PUBLISH];
    
    self.viewContainersDict[self.liveStreamID] = self.publishView;
}

- (UIView *)createPlayView:(NSString *)streamID
{
    UIView *playView = [[UIView alloc] init];
    playView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playContainerView addSubview:playView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapView:)];
    [playView addGestureRecognizer:tapGesture];
    
    NSUInteger count = self.viewContainersDict.count;
    if (self.viewContainersDict.count == 0)
        count = 1;
    
    BOOL bResult = [self setContainerConstraints:playView containerView:self.playContainerView viewCount:count];
    if (bResult == NO)
    {
        [playView removeFromSuperview];
        return nil;
    }
    
    self.viewContainersDict[streamID] = playView;
    [self.playContainerView bringSubviewToFront:playView];
    
    return playView;
    
}

- (void)createPlayStream:(NSString *)streamID
{
    UIView *playView = [self createPlayView:streamID];
    if (playView == nil)
        return;
    
    bool ret = [[ZegoInstantTalk api] startPlayingStream:streamID inView:playView];
    assert(ret);
    
    [[ZegoInstantTalk api] setViewMode:ZegoVideoViewModeScaleToFill ofStream:streamID];
    if (self.firstPlayStream == NO)
    {
        self.firstPlayStream = YES;
        [self updateContainerConstraintsForTap:playView containerView:self.playContainerView];
    }
}

- (void)removeStreamViewContainer:(NSString *)streamID
{
    UIView *view = self.viewContainersDict[streamID];
    if (view == nil)
        return;
    
    [self updateContainerConstraintsForRemove:view containerView:self.playContainerView];
    
    [self.viewContainersDict removeObjectForKey:streamID];
}

#pragma mark Stream Update
- (void)onStreamUpdateForAdd:(NSArray<ZegoStream *> *)streamList
{
    for (ZegoStream *stream in streamList)
    {
        NSString *streamID = stream.streamID;
        if ([self isStreamIDExist:streamID])
        {
            continue;
        }
        
        [self.playStreamList addObject:stream];
        [self createPlayStream:streamID];
        
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"新增一条流, 流ID:%@", nil), streamID];
        [self addLogString:logString];
        
        if (self.isPublishing)
            self.tipsLabel.text = NSLocalizedString(@"视频聊天中...", nil);
        
        if (self.viewContainersDict.count >= self.maxStreamCount)
            break;
    }
}

- (void)onStreamUpdateForDelete:(NSArray<ZegoStream *> *)streamList
{
    for (ZegoStream *stream in streamList)
    {
        NSString *streamID = stream.streamID;
        if (![self isStreamIDExist:streamID])
            continue;
        
        [[ZegoInstantTalk api] stopPlayingStream:streamID];
        
        [self removeStreamViewContainer:streamID];
        [self removeStreamInfo:streamID];
        
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"删除一条流, 流ID:%@", nil), streamID];
        [self addLogString:logString];
    }
    
    if (self.playStreamList.count == 0)
    {
        self.tipsLabel.text = NSLocalizedString(@"对方退出视频聊天", nil);
        self.firstPlayStream = NO;
    }
}

- (BOOL)isStreamIDExist:(NSString *)streamID
{
    if ([self.liveStreamID isEqualToString:streamID])
        return YES;
    
    for (ZegoStream *info in self.playStreamList)
    {
        if ([info.streamID isEqualToString:streamID])
            return YES;
    }
    
    return NO;
}

- (void)removeStreamInfo:(NSString *)streamID
{
    for (ZegoStream *info in self.playStreamList)
    {
        if ([info.streamID isEqualToString:streamID])
        {
            [self.playStreamList removeObject:info];
            break;
        }
    }
}

#pragma mark ZegoRoomDelegate
- (void)onDisconnect:(int)errorCode roomID:(NSString *)roomID
{
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"连接失败, error: %d", nil), errorCode];
    [self addLogString:logString];
}

- (void)onStreamUpdated:(int)type streams:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID
{
    if (type == ZEGO_STREAM_ADD)
        [self onStreamUpdateForAdd:streamList];
    else if (type == ZEGO_STREAM_DELETE)
        [self onStreamUpdateForDelete:streamList];
}

#pragma mark ZegoLivePlayerDelegate
- (void)onPlayStateUpdate:(int)stateCode streamID:(NSString *)streamID
{
    NSLog(@"%s, streamID:%@", __func__, streamID);
    
    if (stateCode == 0)
    {
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"播放流成功, 流ID:%@", nil), streamID];
        [self addLogString:logString];
    }
    else
    {
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"播放流失败, 流ID:%@,  error:%d", nil), streamID, stateCode];
        [self addLogString:logString];
    }
}

#pragma mark ZegoLivePublisherDelegate
- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary *)info
{
    if (stateCode == 0)
    {
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"发布直播成功,流ID:%@", nil), streamID];
        [self addLogString:logString];
    }
    else
    {
        if (stateCode != 1)
        {
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"发布直播失败, 流ID:%@, err:%d", nil), streamID, stateCode];
            [self addLogString:logString];
        }
        else
        {
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"发布直播结束, 流ID:%@", nil), streamID];
            [self addLogString:logString];
        }
        
        self.isPublishing = NO;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"logSegueIdentifier"])
    {
        UINavigationController *navigationController = [segue destinationViewController];
        ZegoLogTableViewController *logViewController = (ZegoLogTableViewController *)[navigationController.viewControllers firstObject];
        logViewController.logArray = self.logArray;
    }
}

@end
