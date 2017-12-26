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
#import <MessageUI/MessageUI.h>
#import <SSZipArchive/SSZipArchive.h>
#import "ZegoShareLogViewController.h"

@interface ZegoSetTableViewController ()<MFMailComposeViewControllerDelegate>
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
    
    // 发送日志邮件彩蛋
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareLogFile)];
//    gesture.numberOfTapsRequired = 5;
//    [self.tableView addGestureRecognizer:gesture];

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

- (IBAction)onAbout:(id)sender
{
    [[ZegoDataCenter sharedInstance] about:self];
}

- (IBAction)sliderDidChange:(id)sender {
    // 手动变更slider数值后，presetPicker自动切换到自定义模式

    [self.presetPicker selectRow:[ZegoSettings sharedInstance].presetVideoQualityList.count - 1 inComponent:0 animated:YES];
    
    ZegoAVConfig *config = [ZegoSettings sharedInstance].currentConfig;
    
    if (sender == self.videoResolutionSlider) {
        int v = (int)self.videoResolutionSlider.value;
        CGSize resolution = CGSizeMake(360, 640);
        switch (v)
        {
            case 0:
                resolution = CGSizeMake(180, 320);
                break;
            case 1:
                resolution = CGSizeMake(270, 480);
                break;
            case 2:
                resolution = CGSizeMake(360, 640);
                break;
            case 3:
                resolution = CGSizeMake(540, 960);
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
        
        if ([self.appIDText.text isEqualToString:@"1"]) {    // 当用户选择自定义，并且输入的 AppID 为 1 时，自动识别为 RTMP 版本且填充 AppSign
            NSString *signkey = @"0x91,0x93,0xcc,0x66,0x2a,0x1c,0x0e,0xc1,0x35,0xec,0x71,0xfb,0x07,0x19,0x4b,0x38,0x41,0xd4,0xad,0x83,0x78,0xf2,0x59,0x90,0xe0,0xa4,0x0c,0x7f,0xf4,0x28,0x41,0xf7";
            [ZegoInstantTalk setCustomAppID:1 sign:signkey];
            [self.appSignText setText:signkey];
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
    self.tabBarController.navigationItem.title = NSLocalizedString(title, nil);
    
    // 自定义的 APPID 来源于用户输入
    uint32_t appID = [ZegoInstantTalk appID];
    NSData *appSign = [ZegoInstantTalk zegoAppSignFromServer];
    if (type == ZegoAppTypeCustom) {
        NSString *appSignString = [ZegoInstantTalk customAppSign];
        
        if (appID && appSign) {
            self.appIDText.enabled = YES;
            [self.appIDText setText:[NSString stringWithFormat:@"%u", appID]];
            
            self.appSignText.enabled = YES;
            [self.appSignText setText:appSignString];
            
            // 重新登录房间
            [[ZegoDataCenter sharedInstance] leaveRoom];
            [ZegoInstantTalk releaseApi];
            [[ZegoDataCenter sharedInstance] loginRoom];
            
        } else {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            self.appIDText.enabled = YES;
            [self.appIDText setText:@""];
            self.appIDText.placeholder = NSLocalizedString(@"请输入 AppID", nil);
            self.appIDText.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.appIDText.keyboardType = UIKeyboardTypeDefault;
            self.appIDText.returnKeyType = UIReturnKeyDone;
            [self.appIDText becomeFirstResponder];
            
            self.appSignText.placeholder = NSLocalizedString(@"请输入 AppSign", nil);
            self.appSignText.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.appSignText.keyboardType = UIKeyboardTypeASCIICapable;
            self.appSignText.returnKeyType = UIReturnKeyDone;
            self.appSignText.enabled = YES;
            [self.appSignText setText:@""];
        }
    } else {
        // 其他类型的 APPID 从本地加载
        [self.appIDText resignFirstResponder];
        [self.appSignText setText:@""];
        self.appSignText.placeholder = NSLocalizedString(@"AppSign 已设置", nil);
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
        case 480:
        case 352: // 兼容老版本 288 x 352
            self.videoResolutionSlider.value = 1;
            break;
        case 640:
            self.videoResolutionSlider.value = 2;
            break;
        case 960:
            self.videoResolutionSlider.value = 3;
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

- (void)shareLogFile {
    [self performSegueWithIdentifier:@"shareLogIdentifier" sender:nil];
}

- (void)sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        [mailCompose setMailComposeDelegate:self];
        
        // 主体
        NSDate *date = [NSDate date]; //date: 2016-07-07 08:00:04 UTC
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYYMMddHHmmss"];
        NSString *dateString = [formatter stringFromDate:date]; //dateString: 20160707160333
        
        NSString *subject = [NSString stringWithFormat:@"%d-%@-%@", [ZegoInstantTalk appID], [ZegoSettings sharedInstance].userID, dateString];
        [mailCompose setSubject:[NSString stringWithFormat:@"手动发送日志提醒【%@】", subject]];
        
        // 收件人
        [mailCompose setToRecipients:@[@"zegosdklog@zego.im"]];
        
        // 正文
        NSString *mailContent = @"手动发送日志邮件";
        [mailCompose setMessageBody:mailContent isHTML:NO];
        
        // 附件
        [mailCompose addAttachmentData:[self zipArchiveWithFiles] mimeType:@"application/zip" fileName:@"zegoavlog.zip"];
        
        [self presentViewController:mailCompose animated:YES completion:nil];
        
        // 清理环境，删除当次的 zip 文件
        NSString *zipPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/ZegoLogs/zegoavlog.zip"];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:&error];
        if (error) {
            NSLog(@"删除日志 zip 文件失败");
        }
    } else {
        [self showAlert:@"无法发送邮件" message:@"请先在手机的 [设置>邮件] 中添加可使用账户并开启邮件服务!"];
    }
}

- (NSData *)zipArchiveWithFiles {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *zegologs = [cachesPath stringByAppendingString:@"/ZegoLogs"];
    
    // 获取 Library/Caches/ZegoLogs 目录下的所有文件
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager subpathsAtPath:zegologs];
    
    NSMutableArray *logFiles = [NSMutableArray arrayWithCapacity:1];
    [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * stop) {
        // 取出 ZegoLogs 下的 txt 日志文件
        if ([obj hasSuffix:@".txt"]) {
            NSString *logFile = [NSString stringWithFormat:@"%@/%@", zegologs, obj];
            [logFiles addObject:logFile];
        }
    }];
    
    // 压缩文件
    NSString *zipPath = [zegologs stringByAppendingPathComponent:@"/zegoavlog.zip"];
    BOOL zipSuccess = [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:logFiles];
    
    if (zipSuccess) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:zipPath];
        if (data) {
            return data;
        }
    } else {
        [self showAlert:@"无法发送邮件" message:@"日志文件压缩失败!"];
    }
    
    return nil;
    
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
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1) {
            [ZegoLiveRoomApi uploadLog];
            [self showUploadAlertView];
        } else if (indexPath.row == 2) {
            [self shareLogFile];
        }
    }
    else if (indexPath.section == [self.tableView numberOfSections] - 1)
    {
        [[ZegoDataCenter sharedInstance] about:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionCount = [self.tableView numberOfSections];
    if (sectionCount >= 2 && (indexPath.section == sectionCount - 2 || indexPath.section == sectionCount - 1))
        return YES;
    
    if (indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2))
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
    if (textField == self.appSignText) {
        self.appSignText.placeholder = NSLocalizedString(@"请输入 AppSign", nil);
    }

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

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultSaved:
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"日志邮件发送成功");
            
            // 弹框提示
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"日志邮件发送成功"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [controller dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:confirm];
            
            [controller presentViewController:alert animated:NO completion:nil];
            
        }
            break;
        case MFMailComposeResultFailed:
        {
            NSLog(@"日志邮件发送失败");
            // 弹框提示
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"日志邮件发送失败"
                                                                           message:@"请稍后重试"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [controller dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:confirm];
            
            [controller presentViewController:alert animated:NO completion:nil];
        }
            break;
    }
}


@end
