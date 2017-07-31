//
//  ZegoSetTableViewController.m
//  LiveDemo3
//
//  Created by Strong on 16/6/22.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoSetTableViewController.h"
#import "ZegoAVKitManager.h"
#import "ZegoSettings.h"
#import "ZegoDataCenter.h"

@interface ZegoSetTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *version;

@property (weak, nonatomic) IBOutlet UISwitch *testEnvSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *appTypePicker;
@property (weak, nonatomic) IBOutlet UITextField *appIDText;
@property (weak, nonatomic) IBOutlet UITextField *appSignText;

@property (weak, nonatomic) IBOutlet UITextField *userID;
@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UIPickerView *presetPicker;
@property (weak, nonatomic) IBOutlet UILabel *videoResolution;
@property (weak, nonatomic) IBOutlet UILabel *videoFrameRate;
@property (weak, nonatomic) IBOutlet UILabel *videoBitRate;
@property (weak, nonatomic) IBOutlet UISlider *videoResolutionSlider;
@property (weak, nonatomic) IBOutlet UISlider *videoFrameRateSlider;
@property (weak, nonatomic) IBOutlet UISlider *videoBitRateSlider;

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation ZegoSetTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.videoResolutionSlider.maximumValue = 5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadEnvironmentSettings];
    [self loadVideoSettings];
    [self loadAccountSettings];
}

- (void)viewWillDisappear:(BOOL)animated {
    [ZegoSettings sharedInstance].userID = self.userID.text;
    [ZegoSettings sharedInstance].userName = self.userName.text;
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Event response

- (IBAction)toggleTestEnv:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    [ZegoInstantTalk setUsingTestEnv:s.on];
}

- (IBAction)onContactUs:(id)sender
{
    [[ZegoDataCenter sharedInstance] contactUs];
}

- (IBAction)sliderDidChange:(id)sender {
    [self.presetPicker selectRow:[ZegoSettings sharedInstance].presetVideoQualityList.count - 1 inComponent:0 animated:YES];
    
    ZegoAVConfig *config = [ZegoSettings sharedInstance].currentConfig;
    
    if (sender == self.videoResolutionSlider) {
        int v = (int)self.videoResolutionSlider.value;
        CGSize resolution = CGSizeMake(360, 640);
        switch (v)
        {
            case 0:
                resolution = CGSizeMake(240, 320);
                break;
            case 1:
                resolution = CGSizeMake(288, 352);
                break;
            case 2:
                resolution = CGSizeMake(360, 640);
                break;
            case 3:
                resolution = CGSizeMake(480, 640);
                break;
            case 4:
                resolution = CGSizeMake(720, 1280);
                break;
            case 5:
                resolution = CGSizeMake(1080, 1920);
                break;
                
            default:
                break;
        }
        config.videoEncodeResolution = resolution;
        
    } else if (sender == self.videoFrameRateSlider) {
        int v = (int)self.videoFrameRateSlider.value;
        config.fps = v;
    } else if (sender == self.videoBitRateSlider) {
        int v = (int)self.videoBitRateSlider.value;
        config.bitrate = v;
    }
    
    [ZegoSettings sharedInstance].currentConfig = config;
    
    [self updateViedoSettingUI];
}

- (IBAction)changeAvatar:(id)sender
{
#if TARGET_OS_SIMULATOR
    NSString *defaultUserName = [NSString stringWithFormat:@"simulator-%@", [ZegoSettings sharedInstance].userID];
#else
    NSString *defaultUserName = [NSString stringWithFormat:@"iphone-%@", [ZegoSettings sharedInstance].userID];
#endif
    
    NSString *originUserName = nil;
    if (![defaultUserName isEqualToString:self.userName.text])
        originUserName = self.userName.text;
    
    [[ZegoSettings sharedInstance] cleanLocalUser];
    
    self.userID.text = [ZegoSettings sharedInstance].userID;
    if (originUserName == nil)
        self.userName.text = [ZegoSettings sharedInstance].userName;
    else
        [ZegoSettings sharedInstance].userName = originUserName;
    
    NSString *imageName = [[ZegoSettings sharedInstance] getAvatarName:self.userID.text];
    UIImage *avatar = [UIImage imageNamed:imageName];
    
    [self.avatarView setImage:avatar];
    
    //头像改变时，ID发生变化。需要重新登录
    [self reloginRoom];
    //ID发生变化，需要把历史记录给删除
    [[ZegoDataCenter sharedInstance] clearAllSession];
}

- (void)onTapTableView:(UIGestureRecognizer *)gesture
{
    if (!self.userName.isEditing)
        [self.view endEditing:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if ([ZegoInstantTalk appType] == ZegoAppTypeCustom) {
        if (self.appIDText.text.length == 0 && self.appSignText.text.length == 0) {
            [ZegoInstantTalk setAppType:ZegoAppTypeUDP];
            [self.appTypePicker selectRow:ZegoAppTypeUDP inComponent:0 animated:NO];
            [self loadAppID];
        } else if (self.appIDText.text.length != 0 && self.appSignText.text.length != 0) {
            NSString *strAppID = self.appIDText.text;
            NSUInteger appID = (uint32_t)[strAppID longLongValue];
            [ZegoInstantTalk setCustomAppID:appID sign:self.appSignText.text];
        
        }
        
        // 重新登录房间
        [[ZegoDataCenter sharedInstance] leaveRoom];
        [ZegoInstantTalk releaseApi];
        [[ZegoDataCenter sharedInstance] loginRoom];
    }
}

#pragma mark - Private method

- (void)loadEnvironmentSettings {
    self.testEnvSwitch.on = [ZegoInstantTalk usingTestEnv];
    [self.appTypePicker selectRow:[ZegoInstantTalk appType] inComponent:0 animated:NO];
    
    [self loadAppID];
}

- (void)loadAppID {
    ZegoAppType type = [ZegoInstantTalk appType];
    
    // 导航栏标题随设置变化
    NSString *title = [NSString stringWithFormat:@"ZEGO(%@)", [ZegoSettings sharedInstance].appTypeList[type]];
    self.tabBarController.navigationItem.title =  NSLocalizedString(title, nil);
    
    // 自定义的 APPID 来源于用户输入
    uint32_t appID = [ZegoInstantTalk appID];
    NSData *appSign = [ZegoInstantTalk zegoAppSignFromServer];
    if (type == ZegoAppTypeCustom) {
        if (appID && appSign) {
            self.appIDText.enabled = YES;
            [self.appIDText setText:[NSString stringWithFormat:@"%u", appID]];
            
            self.appSignText.enabled = YES;
            [self.appSignText setText:NSLocalizedString(@"AppSign 已设置", nil)];
        } else {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            self.appIDText.enabled = YES;
            [self.appIDText setText:@""];
            self.appIDText.placeholder = NSLocalizedString(@"请输入 AppID", nil);
            self.appIDText.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.appIDText.keyboardType = UIKeyboardTypeDefault;
            self.appIDText.returnKeyType = UIReturnKeyDone;
            
            self.appSignText.placeholder = NSLocalizedString(@"请输入 AppSign", nil);
            self.appSignText.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.appSignText.keyboardType = UIKeyboardTypeASCIICapable;
            self.appSignText.returnKeyType = UIReturnKeyDone;
            self.appSignText.enabled = YES;
            [self.appSignText setText:@""];
            [self.appSignText becomeFirstResponder];
            
        }
    } else {
        // 其他类型的 APPID 从本地加载
        [self.appIDText resignFirstResponder];
        [self.appSignText setText:@""];
        self.appSignText.placeholder = NSLocalizedString(@"Demo已添加，无需设置", nil);
        self.appSignText.enabled = NO;
        
        self.appIDText.enabled = NO;
        [self.appIDText setText:[NSString stringWithFormat:@"%u", appID]];
    }
}

- (void)loadAccountSettings {
    NSUInteger userIDInteger = [[ZegoSettings sharedInstance].userID integerValue];
    if (userIDInteger == 0)
    {
        [[ZegoSettings sharedInstance] cleanLocalUser];
    }
    
    self.userID.text = [ZegoSettings sharedInstance].userID;
    self.userName.text = [ZegoSettings sharedInstance].userName;
    NSString *imageName = [[ZegoSettings sharedInstance] getAvatarName:self.userID.text];
    UIImage *avatar = [UIImage imageNamed:imageName];
    [self.avatarView setImage:avatar];
}

- (void)loadVideoSettings {
    self.version.text = [ZegoLiveRoomApi version];
    [self.presetPicker selectRow:[ZegoSettings sharedInstance].presetIndex inComponent:0 animated:YES];
    [self updateViedoSettingUI];
}

- (void)updateViedoSettingUI {
    ZegoAVConfig *config = [[ZegoSettings sharedInstance] currentConfig];
    
    CGSize r = [ZegoSettings sharedInstance].currentResolution;
    self.videoResolution.text = [NSString stringWithFormat:@"%d X %d", (int)r.width, (int)r.height];
    switch ((int)r.height) {
        case 320:
            self.videoResolutionSlider.value = 0;
            break;
        case 352:
            self.videoResolutionSlider.value = 1;
            break;
        case 640:
            if (r.width == 360) {
                self.videoResolutionSlider.value = 2;
            } else {
                self.videoResolutionSlider.value = 3;
            }
            break;
        case 1280:
            self.videoResolutionSlider.value = 4;
            break;
        case 1920:
            self.videoResolutionSlider.value = 5;
            break;
        default:
            break;
    }
    
    self.videoFrameRateSlider.value = config.fps;
    self.videoFrameRate.text = [NSString stringWithFormat:@"%d", config.fps];
    
    self.videoBitRateSlider.value = config.bitrate;
    self.videoBitRate.text = [NSString stringWithFormat:@"%d", config.bitrate];
}

- (void)reloginRoom
{
    [ZegoSettings sharedInstance].userID = self.userID.text;
    [ZegoSettings sharedInstance].userName = self.userName.text;
    
    [[ZegoDataCenter sharedInstance] leaveRoom];
    [[ZegoDataCenter sharedInstance] loginRoom];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginRoom:) name:kUserLoginNotification object:nil];
    
    if (self.indicatorView)
        self.indicatorView = nil;
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = YES;
    self.indicatorView.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - 40)/2, (CGRectGetHeight(self.view.bounds) - 40)/2, 40, 40);
    [self.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}

- (void)onLoginRoom:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserLoginNotification object:nil];
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
    self.indicatorView = nil;
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:confirm];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)showUploadAlertView
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"日志上传成功", nil)];
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.presetPicker) {
        return [ZegoSettings sharedInstance].presetVideoQualityList.count;
    } else if (pickerView == self.appTypePicker) {
        return [ZegoSettings sharedInstance].appTypeList.count;
    } else {
        return 0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.presetPicker)
    {
        if (row >= [ZegoSettings sharedInstance].presetVideoQualityList.count) {
            return ;
        }
        
        NSLog(@"%s: %@", __func__, [ZegoSettings sharedInstance].presetVideoQualityList[row]);
        
        [[ZegoSettings sharedInstance] selectPresetQuality:row];
        
        [self updateViedoSettingUI];
    } else if (pickerView == self.appTypePicker) {
        if (row >= [ZegoSettings sharedInstance].appTypeList.count) {
            return ;
        }
        
        NSLog(@"%s: %@", __func__, [ZegoSettings sharedInstance].appTypeList[row]);
        
        [ZegoInstantTalk setAppType:(ZegoAppType)row];
        
        if ([ZegoInstantTalk appType] != ZegoAppTypeCustom) {
            // 重新登录房间
            [ZegoInstantTalk releaseApi];
            [[ZegoDataCenter sharedInstance] loginRoom];
        }

        [self loadAppID];
    }
    
    return;
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.presetPicker)
    {
        if (row >= [ZegoSettings sharedInstance].presetVideoQualityList.count) {
            return @"ERROR";
        }
        
        return [[ZegoSettings sharedInstance].presetVideoQualityList objectAtIndex:row];
    } else if (pickerView == self.appTypePicker) {
        if (row >= [ZegoSettings sharedInstance].appTypeList.count) {
            return @"ERROR";
        }
        
        return [[ZegoSettings sharedInstance].appTypeList objectAtIndex:row];
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        [ZegoLiveRoomApi uploadLog];
        [self showUploadAlertView];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3 || indexPath.section == 4)
        return YES;
    
    if (indexPath.section == 0 && indexPath.row == 1)
        return YES;
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length != 0)
    {
        [textField resignFirstResponder];
        return YES;
    } else {
        [self showAlert:NSLocalizedString(@"请重新输入！", nil) message:NSLocalizedString(@"该字段不可为空", nil)];
        [textField becomeFirstResponder];
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.tapGesture == nil)
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapTableView:)];
    
    [self.tableView addGestureRecognizer:self.tapGesture];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.tapGesture)
    {
        [self.tableView removeGestureRecognizer:self.tapGesture];
        self.tapGesture = nil;
    }
    
    if (textField == self.userName && ![self.userName.text isEqualToString:[ZegoSettings sharedInstance].userName])
    {
        [self reloginRoom];
    }
}

@end
