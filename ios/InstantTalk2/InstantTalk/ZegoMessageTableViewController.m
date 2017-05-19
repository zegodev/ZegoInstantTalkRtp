//
//  ZegoMessageTableViewController.m
//  InstantTalk
//
//  Created by Strong on 16/7/11.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoMessageTableViewController.h"
#import "ZegoDataCenter.h"
#import "ZegoSettings.h"
#import "ZegoChatViewController.h"

@implementation ZegoMessageTableViewCell

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
    
    self.unreadCount.layer.cornerRadius = CGRectGetWidth(self.unreadCount.frame) / 2;
    self.unreadCount.layer.masksToBounds = YES;
    self.unreadCount.backgroundColor = [UIColor redColor];
    self.unreadCount.textColor = [UIColor whiteColor];
    self.unreadCount.textAlignment = NSTextAlignmentCenter;
}

- (UIEdgeInsets)tableViewCellInsets
{
    return UIEdgeInsetsMake(0, CGRectGetMinX(self.nickNameLabel.frame), 0, 0);
}

@end

@interface ZegoMessageTableViewController ()

@end

@implementation ZegoMessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageUpdate:) name:kUserMessageReceiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageUpdate:) name:kUserMessageSendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageUpdate:) name:kUserClearAllSessionNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onContactUs:(id)sender
{
    [[ZegoDataCenter sharedInstance] contactUs];
}

- (void)onMessageUpdate:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ZegoDataCenter sharedInstance].sessionList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZegoMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageListIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.row >= [ZegoDataCenter sharedInstance].sessionList.count)
        return cell;
    
    ZegoSession *session = [ZegoDataCenter sharedInstance].sessionList[indexPath.row];
    if (session == nil)
        return cell;
    
    if (session.memberList.count == 2)
    {
        ZegoUser *otherUser = [[ZegoDataCenter sharedInstance] getOtherMember:session.memberList];
        NSString *userImage = [[ZegoSettings sharedInstance] getAvatarName:otherUser.userId];
        cell.avatarView.image = [UIImage imageNamed:userImage];
        cell.nickNameLabel.text = session.sessionName;
    }
    else
    {
        cell.nickNameLabel.text = session.sessionName;
        cell.avatarView.image = [[ZegoSettings sharedInstance] getMemberAvatar:session.memberList width:CGRectGetWidth(cell.avatarView.frame)];
    }
    
    ZegoConversationMessage *messageDetail = [session.messageHistory lastObject];
    if (messageDetail)
        cell.lastMessageLabel.text = messageDetail.content;
    if (session.unreadCount != 0)
    {
        cell.unreadCount.hidden = NO;
        cell.unreadCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)session.unreadCount];
    }
    else
    {
        cell.unreadCount.hidden = YES;
    }
    cell.separatorInset = [cell tableViewCellInsets];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"删除", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.row >= [ZegoDataCenter sharedInstance].sessionList.count)
            return;
        
        ZegoSession *session = [ZegoDataCenter sharedInstance].sessionList[indexPath.row];
        if (session == nil)
            return;
        
        [[ZegoDataCenter sharedInstance] deleteSession:session];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ZegoDataCenter sharedInstance] saveSessionList];
        });
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"messageChatSegue"])
    {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if (indexPath.row >= [ZegoDataCenter sharedInstance].sessionList.count)
            return;
        
        ZegoSession *session = [ZegoDataCenter sharedInstance].sessionList[indexPath.row];
        
        ZegoChatViewController *chatController = (ZegoChatViewController *)segue.destinationViewController;
        chatController.sessionID = session.sessionId;
        session.unreadCount = 0;
        [cell setNeedsLayout];
        
        chatController.userList = [NSMutableArray arrayWithArray:session.memberList];
        chatController.chatTheme = session.sessionName;
        chatController.hidesBottomBarWhenPushed = YES;
    }
}


@end
