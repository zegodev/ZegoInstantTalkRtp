//
//  ZegoChatViewController.m
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoChatViewController.h"
#import "ZegoChatInput.h"
#import "ZegoChatTableViewCell.h"
#import "ZegoSettings.h"
#import "ZegoDataCenter.h"
#import "ZegoVideoTalkViewController.h"

@interface ZegoChatViewController () <ZegoChatInputDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet ZegoChatInput *chatInput;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomChatInputConstraint;

@property (nonatomic, strong) ZegoChatTableViewCell *sizingCell;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation ZegoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.chatTheme;
    
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.estimatedRowHeight = 64.0;
    [self.tableView registerClass:[ZegoChatTableViewCell class] forCellReuseIdentifier:@"messageCellIdentifier"];
    
    self.chatInput.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _sizingCell = [[ZegoChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessage:) name:kUserMessageReceiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ZegoDataCenter sharedInstance] clearUnreadCount:self.sessionID];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.chatInput.textView resignFirstResponder];
    
    if (self.isMovingFromParentViewController)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ZegoDataCenter sharedInstance] saveSessionList];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onReceiveMessage:(NSNotification *)notification
{
    NSString *sessionID = notification.userInfo[@"session"];
    if (sessionID.length == 0)
        return;
    
    if (![self.sessionID isEqualToString:sessionID])
    {
        //检查当前收到的消息是否为此窗口
        self.sessionID = sessionID;
        [self updateChatView];
    }
    else
    {
        //update UI
        [self updateChatView];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *keyboardAnimationDetail = notification.userInfo;
    NSTimeInterval duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [keyboardAnimationDetail[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view.window convertRect:keyboardFrame toView:self.view];
    if (CGRectEqualToRect(keyboardFrame, CGRectZero))
        return;
    
    NSUInteger animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view layoutIfNeeded];
    
//    CGFloat chatInputOffset = -((CGRectGetHeight(self.view.bounds) - self.bottomLayoutGuide.length) - CGRectGetMinY(keyboardFrame));
    CGFloat chatInputOffset = CGRectGetMinY(keyboardFrame) + self.bottomLayoutGuide.length - CGRectGetHeight(self.view.bounds);
    if (chatInputOffset > 0)
        chatInputOffset = 0;
    
    self.bottomChatInputConstraint.constant = chatInputOffset;
    [UIView animateWithDuration:duration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
        [self scrollTableViewToBottom];
    } completion:^(BOOL finished) {
        self.tableView.scrollEnabled = YES;
        self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }];
}

- (void)updateChatView
{
    [[ZegoDataCenter sharedInstance] clearUnreadCount:self.sessionID];
    
    [self.tableView reloadData];
    [self scrollTableViewToBottom];
}

- (NSArray<ZegoConversationMessage *> *)getMessageList
{
    if (self.sessionID.length == 0)
        return nil;
    
    return [[ZegoDataCenter sharedInstance] getMessageList:self.sessionID];
}

#pragma mark UITableViewDataSource & UITableViewDlegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getMessageList].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 60);
//    NSString *message = self.messageList[indexPath.row];
    
    NSArray *messageList = [self getMessageList];
    if (indexPath.row >= messageList.count)
        return 0.0;
    
    ZegoConversationMessage *messageDetail = messageList[indexPath.row];
    NSString *message = messageDetail.content;
    
    CGFloat height = [self.sizingCell setupMessage:message oppentImage:nil].height + 10;
    return height;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.dragging)
        [self.chatInput.textView resignFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZegoChatTableViewCell *cell = (ZegoChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"messageCellIdentifier" forIndexPath:indexPath];
    NSArray *messageList = [self getMessageList];
    if (indexPath.row >= messageList.count)
        return cell;
    
    ZegoConversationMessage *messageDetail = messageList[indexPath.row];
    NSString *message = messageDetail.content;
    UIImage *oppentImage = nil;
    
    if (![messageDetail.fromUserId isEqualToString:[ZegoSettings sharedInstance].userID])
    {
        NSString *oppentImageName = [[ZegoSettings sharedInstance] getAvatarName:messageDetail.fromUserId];
        oppentImage = [UIImage imageNamed:oppentImageName];
    }

    [cell setupMessage:message oppentImage:oppentImage];
    
    return cell;
}

- (void)scrollTableViewToBottom
{
    if ([self getMessageList].count == 0)
        return;
    
    NSInteger lastItemIndex = [self.tableView numberOfRowsInSection:0] - 1;
    if (lastItemIndex < 0)
        lastItemIndex = 0;
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastItemIndex inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark ChatInputDelegate
- (void)chatInputDidResize:(ZegoChatInput *)chatInput
{
    [self scrollTableViewToBottom];
}

- (void)chatInput:(ZegoChatInput *)chatInput didSendMessage:(NSString *)message
{
    //发送消息
    if (self.sessionID == nil)
    {
        BOOL ret = [[ZegoDataCenter sharedInstance] createSessionWithMemberList:self.userList completion:^(NSString *sessionId) {
            if (sessionId != nil)
            {
                self.sessionID = sessionId;
                [[ZegoDataCenter sharedInstance] sendMessage:sessionId messageContent:message completion:^(int errorCode) {
                    // can update UI
                    if (errorCode != 0)
                        NSLog(@"send Message Error");
                    
                    [self.tableView reloadData];
                    [self scrollTableViewToBottom];
                }];
            }
        }];

        if (!ret)
        {
            NSLog(@"createSession error");
        }
    }
    else
    {
        [[ZegoDataCenter sharedInstance] sendMessage:self.sessionID messageContent:message completion:^(int errorCode) {
            [self.tableView reloadData];
            [self scrollTableViewToBottom];
        }];
    }
}

- (void)onTapTableView:(UIGestureRecognizer *)gesture
{
    [self.chatInput.textView resignFirstResponder];
}

- (void)chatInputBeginEditing:(ZegoChatInput *)chatInput
{
    if (self.tapGesture == nil)
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapTableView:)];
    
    [self.tableView addGestureRecognizer:self.tapGesture];
}

- (void)chatInputEndEditing:(ZegoChatInput *)chatInput
{
    if (self.tapGesture)
    {
        [self.tableView removeGestureRecognizer:self.tapGesture];
        self.tapGesture = nil;
    }
}

- (void)alertNobodyOnline
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"没有用户在线，可能无法进行视频聊天", nil)];
    if ([[ZegoSettings sharedInstance] isDeviceiOS7])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"继续", nil), nil];
        [alertView show];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"继续", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"videoTalkSegue" sender:nil];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self performSegueWithIdentifier:@"videoTalkSegue" sender:nil];
    }
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    [self.chatInput resignFirstResponder];
    if ([identifier isEqualToString:@"videoTalkSegue"])
    {
        if (sender == nil)
            return YES;
        
        if ([[ZegoDataCenter sharedInstance] isMemberOnline:self.userList])
            return YES;
        
        [self alertNobodyOnline];
        return NO;
    }
    
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"videoTalkSegue"])
    {
        ZegoVideoTalkViewController *videoController = (ZegoVideoTalkViewController *)segue.destinationViewController;
        videoController.isRequester = YES;
        videoController.userList = self.userList;
    }
}


@end
