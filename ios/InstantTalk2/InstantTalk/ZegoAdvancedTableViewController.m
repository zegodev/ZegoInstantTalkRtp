//
//  ZegoAdvancedTableViewController.m
//  LiveDemo3
//
//  Created by Strong on 16/6/30.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoAdvancedTableViewController.h"
#import "ZegoAVKitManager.h"

@interface ZegoAdvancedTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *hardwareAcceleratedSwitch;

@end

@implementation ZegoAdvancedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hardwareAcceleratedSwitch.on =[ZegoInstantTalk requireHardwareAccelerated];
}

- (void)onAlphaEnv:(UIGestureRecognizer *)gesture
{
    BOOL alpha = [ZegoInstantTalk usingAlphaEnv];
    [ZegoInstantTalk setUsingAlphaEnv:(!alpha)];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"测试环境" message:alpha ? @"关闭Alpha环境" : @"打开Alpha环境" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleHardwareAccelerated:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    [ZegoInstantTalk setRequireHardwareAccelerated:s.on];
}


@end
