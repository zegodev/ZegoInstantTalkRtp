//
//  ZegoMenuViewController.m
//  InstantTalk
//
//  Created by Strong on 16/7/20.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoMenuViewController.h"

#define CONTENT_WIDTH       150
#define CONTENT_MARGIN      10

@interface ZegoMenuViewController ()
@property (nonatomic, weak) IBOutlet UILabel *videoLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@end

@implementation ZegoMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat labelHeight = CGRectGetHeight(self.videoLabel.frame);
    self.preferredContentSize= CGSizeMake(CONTENT_WIDTH, 2 * labelHeight + 1);
    self.view.backgroundColor = [UIColor clearColor];
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(CONTENT_MARGIN, CGRectGetMaxY(self.videoLabel.frame), CONTENT_WIDTH - 2 * CONTENT_MARGIN, 0.5);
    lineLayer.contentsScale = [UIScreen mainScreen].scale;
    lineLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.view.layer addSublayer:lineLayer];
    
    UITapGestureRecognizer *viewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:viewTapGesture];
    
    UITapGestureRecognizer *videoTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTapped:)];
    self.videoLabel.userInteractionEnabled = YES;
    [self.videoLabel addGestureRecognizer:videoTapGesture];
    
    UITapGestureRecognizer *messageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTapped:)];
    self.messageLabel.userInteractionEnabled = YES;
    [self.messageLabel addGestureRecognizer:messageTapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewTapped:(UIGestureRecognizer *)gestureRecoginzer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(onVideoTalkSelected)])
            [self.delegate onVideoTalkSelected];
    }];
}

- (void)messageTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(onMessageTalkSelected)])
            [self.delegate onMessageTalkSelected];
    }];
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
