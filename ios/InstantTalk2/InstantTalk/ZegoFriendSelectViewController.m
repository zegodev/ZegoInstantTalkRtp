//
//  ZegoFriendSelectViewController.m
//  InstantTalk
//
//  Created by Strong on 16/7/13.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoFriendSelectViewController.h"
#import "ZegoFriendTableViewController.h"
#import "ZegoDataCenter.h"
#import "ZegoSettings.h"

#define BASE_TAG    1000

@implementation ZegoFriendSelectTableViewCell

@end

@interface ZegoFriendSelectViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewHeighConstraint;

@property (nonatomic, strong) NSMutableArray *selectedUserArray;

@property (nonatomic, strong) NSArray *userList;

@end

@implementation ZegoFriendSelectViewController

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), CGRectGetWidth(self.scrollView.frame), 0.5);
    lineLayer.contentsScale = [UIScreen mainScreen].scale;
    lineLayer.masksToBounds = YES;
    lineLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.view.layer addSublayer:lineLayer];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.selectedUserArray = [NSMutableArray array];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.userList = [NSArray arrayWithArray:[ZegoDataCenter sharedInstance].userList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

- (IBAction)onCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onOK:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(onSelectedFriends:videoSelector:)])
            [self.delegate onSelectedFriends:self.selectedUserArray videoSelector:self.videoSelector];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZegoFriendSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendSelectIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.row >= self.userList.count)
        return cell;
    
    ZegoUser *user = [self.userList objectAtIndex:indexPath.row];
    
    cell.nickNameLabel.text = user.userName;
    
    NSString *imageName = [[ZegoSettings sharedInstance] getAvatarName:user.userId];
    [cell.avatarView setImage:[UIImage imageNamed:imageName]];
    NSArray *filterArray = [self.selectedUserArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", user.userId]];
    if (filterArray.count == 0)
        cell.checkBox.on = NO;
    else
        cell.checkBox.on = YES;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)addFirstViewConstraint:(UIView *)firstView
{
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(2)-[firstView(==44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstView)]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firstView(==44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(firstView)]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)addViewConstraint:(UIView *)secondView previousView:(UIView *)previousView
{
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousView]-(3)-[secondView(==44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(previousView, secondView)]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[secondView(==44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(secondView)]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)onTapImageView:(UIGestureRecognizer *)gesture
{
    UIView *tapView = gesture.view;
    if (tapView == nil)
        return;
    
    NSInteger index = tapView.tag - BASE_TAG;
    if (index < 0 || index >= self.selectedUserArray.count)
        return;
    
    [self.selectedUserArray removeObjectAtIndex:index];
    [self removeSelectedView:index];
    
    [self updateRightButton];
}

- (void)addSelectedView:(ZegoUser *)user
{
    UIImage *image = [UIImage imageNamed:[[ZegoSettings sharedInstance] getAvatarName:user.userId]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.userInteractionEnabled = YES;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.tag = self.selectedUserArray.count - 1 + BASE_TAG;
    [self.scrollView addSubview:imageView];
    
    if (self.selectedUserArray.count == 1)
    {
        [self addFirstViewConstraint:imageView];
    }
    else
    {
        UIView *previousView = [self.scrollView viewWithTag:self.selectedUserArray.count - 2 + BASE_TAG];
        [self addViewConstraint:imageView previousView:previousView];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.scrollView layoutIfNeeded];
    } completion:^(BOOL finished) {
        CGFloat maxX = CGRectGetMaxX(imageView.frame);
        if (maxX > CGRectGetWidth(self.scrollView.frame))
            self.scrollView.contentSize = CGSizeMake(maxX, CGRectGetHeight(self.scrollView.frame));
        else
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImageView:)];
        [imageView addGestureRecognizer:tapGesture];
    }];
}

- (void)removeSelectedView:(NSUInteger)index
{
    UIView *view = [self.scrollView viewWithTag:index + BASE_TAG];
    if (view == nil)
        return;
    
    [view removeFromSuperview];
    [self.scrollView removeConstraints:self.scrollView.constraints];
    [self.scrollView addConstraint:self.scrollViewHeighConstraint];
    
    for (UIView *subView in self.scrollView.subviews)
    {
        if (subView.tag > BASE_TAG + index)
            subView.tag -=1;
    }
    
    for (UIView *subView in self.scrollView.subviews)
    {
        if (subView.tag == 0)
            continue;
        
        if (subView.tag == BASE_TAG)
            [self addFirstViewConstraint:subView];
        else
        {
            NSInteger tag = subView.tag;
            UIView *previousView = [self.scrollView viewWithTag:tag - 1];
            [self addViewConstraint:subView previousView:previousView];
        }
    }
    
    UIView *lastView = [self.scrollView viewWithTag:self.selectedUserArray.count - 1 + BASE_TAG];
    CGFloat maxX = CGRectGetMaxX(lastView.frame);
    if (maxX > CGRectGetWidth(self.scrollView.frame))
        self.scrollView.contentSize = CGSizeMake(maxX, CGRectGetHeight(self.scrollView.frame));
    else
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ZegoFriendSelectTableViewCell *cell = (ZegoFriendSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row >= [ZegoDataCenter sharedInstance].userList.count)
        return;
    
    ZegoUser *user = [[ZegoDataCenter sharedInstance].userList objectAtIndex:indexPath.row];
    
    BOOL isOn = cell.checkBox.on;
    cell.checkBox.on = !isOn;
    if (!isOn)
    {
        [self.selectedUserArray addObject:user];
        [self addSelectedView:user];
    }
    else
    {
        NSArray *filterArray = [self.selectedUserArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", user.userId]];
        if (filterArray.count != 1)
            NSLog(@"error filter array");
        NSUInteger index = [self.selectedUserArray indexOfObject:[filterArray firstObject]];
        
        [self.selectedUserArray removeObjectsInArray:filterArray];
        [self removeSelectedView:index];
    }
    
    [self updateRightButton];
}

- (void)updateRightButton
{
    if (self.selectedUserArray.count == 0)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
