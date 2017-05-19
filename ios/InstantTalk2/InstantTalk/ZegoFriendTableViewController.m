//
//  ZegoFriendTableViewController.m
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoFriendTableViewController.h"
#import "ZegoDataCenter.h"
#import "ZegoAVKitManager.h"
#import "ZegoSettings.h"
#import "ZegoChatViewController.h"
#import "ZegoVideoTalkViewController.h"
#import "ZegoFriendSelectViewController.h"
#import "ZegoMenuViewController.h"

@implementation ZegoFriendTableViewCell

- (UIEdgeInsets)tableViewCellInsets
{
    return UIEdgeInsetsMake(0, CGRectGetMinX(self.nickNameLabel.frame), 0, 0);
}

@end

@interface ZegoFriendTableViewController () <ZegoFriendSelectDelegate, UIPopoverPresentationControllerDelegate, ZegoMenuViewControllerDelegate>

@end

@implementation ZegoFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"ZEGO";
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserUpdated:) name:kUserUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setRightButton];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRightButton
{
    if ([ZegoDataCenter sharedInstance].userList.count > 0)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (IBAction)onContactUs:(id)sender
{
    [[ZegoDataCenter sharedInstance] contactUs];
}

- (void)onUserUpdated:(NSNotification *)notification
{
    [self setRightButton];
    [self.tableView reloadData];
}

- (void)onBecomeActive:(NSNotificationCenter *)notification
{
    [self setRightButton];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ZegoDataCenter sharedInstance].userList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZegoFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userListIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.row >= [ZegoDataCenter sharedInstance].userList.count)
        return cell;
    
    ZegoUser *user = [[ZegoDataCenter sharedInstance].userList objectAtIndex:indexPath.row];
    
    cell.nickNameLabel.text = user.userName;
    
    NSString *imageName = [[ZegoSettings sharedInstance] getAvatarName:user.userId];
    [cell.avatarView setImage:[UIImage imageNamed:imageName]];
    
    cell.separatorInset = [cell tableViewCellInsets];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"userChatSegue"])
    {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath == nil)
            return;
        
        if (indexPath.row >= [ZegoDataCenter sharedInstance].userList.count)
            return;
        
        ZegoUser *user = [[ZegoDataCenter sharedInstance].userList objectAtIndex:indexPath.row];
        
        //find session by memberlist
        ZegoSession *session = [[ZegoDataCenter sharedInstance] isSessionExistWithSameMemberList:@[user, [[ZegoSettings sharedInstance] getZegoUser]]];
        
        ZegoChatViewController *chatController = (ZegoChatViewController *)segue.destinationViewController;
        if (session == nil)
        {
            chatController.userList = [NSMutableArray arrayWithObjects:user, [[ZegoSettings sharedInstance] getZegoUser], nil];
        }
        else
        {
            chatController.sessionID = session.sessionId;
            chatController.userList = [NSMutableArray arrayWithArray:[[ZegoDataCenter sharedInstance] getMemberList:session.sessionId]];
        }
        
        chatController.chatTheme = user.userName;
        chatController.hidesBottomBarWhenPushed = YES;
    }
    else if ([segue.identifier isEqualToString:@"userVideoTalkSegue"])
    {
        if (![sender isKindOfClass:[UIButton class]])
            return;
        
        UIButton *videoButton = (UIButton *)sender;
        UITableViewCell *cell = (UITableViewCell *)[[videoButton superview] superview];
        if (![cell isKindOfClass:[UITableViewCell class]])
            return;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath == nil)
            return;
        
        if (indexPath.row >= [ZegoDataCenter sharedInstance].userList.count)
            return;
        
        ZegoUser *user = [[ZegoDataCenter sharedInstance].userList objectAtIndex:indexPath.row];
        
        ZegoVideoTalkViewController *videoController = (ZegoVideoTalkViewController *)segue.destinationViewController;
        videoController.isRequester = YES;
        videoController.userList = @[user, [[ZegoSettings sharedInstance] getZegoUser]];
    }
    else if ([segue.identifier isEqualToString:@"friendPopoverSegue"])
    {
        ZegoMenuViewController *popoverViewController = (ZegoMenuViewController *)segue.destinationViewController;
        popoverViewController.modalPresentationStyle = UIModalPresentationPopover;
        popoverViewController.popoverPresentationController.delegate = self;
        popoverViewController.delegate = self;
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}

#pragma mark UIPopoverPresentationControllerDelegate 
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

#pragma mark ZegoMenuViewControllerDelegate
- (void)onVideoTalkSelected
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [self performFriendSelectViewController:YES];
}

- (void)onMessageTalkSelected
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [self performFriendSelectViewController:NO];
}

- (void)performFriendSelectViewController:(BOOL)videoSelector
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"friendSelectorStoryboard"];
    ZegoFriendSelectViewController *friendSelectController = (ZegoFriendSelectViewController *)navigationController.viewControllers.firstObject;
    friendSelectController.videoSelector = videoSelector;
    friendSelectController.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark ZegoFriendSelectDelegate
- (void)onSelectedFriends:(NSArray<ZegoUser *> *)selectedUsers videoSelector:(BOOL)videoSelector
{
    if (selectedUsers.count == 0)
        return;
    
    if (videoSelector)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ZegoVideoTalkViewController *videoController = (ZegoVideoTalkViewController *)[storyboard instantiateViewControllerWithIdentifier:@"videoTalkStoryboardID"];
        videoController.isRequester = YES;
        NSMutableArray *chatUsers = [NSMutableArray arrayWithArray:selectedUsers];
        [chatUsers addObject:[[ZegoSettings sharedInstance] getZegoUser]];
        videoController.userList = [NSMutableArray arrayWithArray:chatUsers];
        
        [self presentViewController:videoController animated:YES completion:nil];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ZegoChatViewController *chatController = (ZegoChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chatStoryboardID"];
        
        NSMutableArray *chatUsers = [NSMutableArray arrayWithArray:selectedUsers];
        [chatUsers addObject:[[ZegoSettings sharedInstance] getZegoUser]];
        
        ZegoSession *session = [[ZegoDataCenter sharedInstance] isSessionExistWithSameMemberList:chatUsers];
        if (session)
        {
            chatController.chatTheme = session.sessionName;
            chatController.userList = session.memberList;
        }
        else
        {
            if (chatUsers.count == 2)
                chatController.chatTheme = [selectedUsers firstObject].userName;
            else
                chatController.chatTheme = @"群聊";
            
            chatController.userList = chatUsers;
        }
        
        [self.navigationController pushViewController:chatController animated:YES];
    }
}

@end
