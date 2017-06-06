//
//  AppDelegate.m
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "AppDelegate.h"
#import "ZegoDataCenter.h"
#import "ZegoBackground.h"
#import "ZegoTabBarViewController.h"
#import "ZegoSettings.h"
#import "ZegoAVKitManager.h"

#import <Bugly/Bugly.h>

#define kUserNotificationActionMessageCategory      @"messageaction"
#define kUserNotificationActionMessage              @"openMessage"

#define kUserNotificationActionVideoCategory        @"videoaction"
#define kUserNotificationActionDisagree             @"disagreeVideo"
#define kUserNotificationActionAgree                @"agreeVideo"

@interface AppDelegate ()

@property (nonatomic, strong) ZegoBackground *backgound;
@property (nonatomic, strong) ZegoRequestTalkInfo *requestInfo;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self registerNotificationAction:application];
    self.backgound = [[ZegoBackground alloc] init];
    
    [self setupBugly];
    
    return YES;
}

-(void) setupBugly{
    // Get the default config
    BuglyConfig * config = [[BuglyConfig alloc] init];
    
    // Open the debug mode to print the sdk log message.
    // Default value is NO, please DISABLE it in your RELEASE version.
#if DEBUG
    config.debugMode = YES;
#endif
    
    // Open the customized log record and report, BuglyLogLevelWarn will report Warn, Error log message.
    // Default value is BuglyLogLevelSilent that means DISABLE it.
    // You could change the value according to you need.
    config.reportLogLevel = BuglyLogLevelWarn;
    
    // Open the STUCK scene data in MAIN thread record and report.
    // Default value is NO
    config.blockMonitorEnable = YES;
    
    // Set the STUCK THRESHOLD time, when STUCK time > THRESHOLD it will record an event and report data when the app launched next time.
    // Default value is 3.5 second.
    config.blockMonitorTimeout = 1.5;
    
    // Set the app channel to deployment
    config.channel = @"Bugly";
    
    // NOTE:Required
    // Start the Bugly sdk with APP_ID and your config
    [Bugly startWithAppId:@"2594b551b9"
#if DEBUG
        developmentDevice:YES
#endif
                   config:config];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if (!application.isIdleTimerDisabled)
        [self.backgound startPreventSleep];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (application.isIdleTimerDisabled)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessage:) name:kUserMessageReceiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRequestVideoTalk:) name:kUserRequestVideoTalkNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDisconnected:) name:kUserDisconnectNotification object:nil];
    UIViewController *rootViewController = application.keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[ZegoTabBarViewController class]])
    {
        ZegoTabBarViewController *tabController = (ZegoTabBarViewController *)rootViewController;
        [tabController removeObserver];
    }
    
    [[ZegoDataCenter sharedInstance] saveSessionList];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [application setApplicationIconBadgeNumber:0];
    
    if (application.isIdleTimerDisabled)
        return;
    
    UIViewController *rootViewController = application.keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[ZegoTabBarViewController class]])
    {
        ZegoTabBarViewController *tabController = (ZegoTabBarViewController *)rootViewController;
        [tabController addObserver];
    }
    
    if (![[ZegoDataCenter sharedInstance] isLogin] && ![[ZegoDataCenter sharedInstance] isLoging])
        [[ZegoDataCenter sharedInstance] loginRoom];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (application.isIdleTimerDisabled)
        return;
    
    UIViewController *rootViewController = application.keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[ZegoTabBarViewController class]])
    {
        ZegoTabBarViewController *tabController = (ZegoTabBarViewController *)rootViewController;
        if (self.requestInfo)
        {
            [tabController showRequestVideoAlert:self.requestInfo];
            self.requestInfo = nil;
        }
    }
    
    [self.backgound stopPreventSleep];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:kUserNotificationActionMessage])
    {
        UIViewController *rootViewController = application.keyWindow.rootViewController;
        if ([rootViewController isKindOfClass:[ZegoTabBarViewController class]])
        {
            ZegoTabBarViewController *tabController = (ZegoTabBarViewController *)rootViewController;
            [tabController setSelectedIndex:1];
        }
    }
    else if ([identifier isEqualToString:kUserNotificationActionAgree])
    {
        self.requestInfo = nil;
        int requestSeq = [notification.userInfo[@"requestSeq"] intValue];
        [[ZegoDataCenter sharedInstance] agreedVideoTalk:YES requestSeq:requestSeq];
    }
    else if ([identifier isEqualToString:kUserNotificationActionDisagree])
    {
        self.requestInfo = nil;
        int requestSeq = [notification.userInfo[@"requestSeq"] intValue];
        [[ZegoDataCenter sharedInstance] agreedVideoTalk:NO requestSeq:requestSeq];
    }
    
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([notification.alertAction isEqualToString:kUserNotificationActionMessage])
    {
        
    }
    else if ([notification.alertAction isEqualToString:kUserNotificationActionAgree])
    {
        UIViewController *rootViewController = application.keyWindow.rootViewController;
        if ([rootViewController isKindOfClass:[ZegoTabBarViewController class]])
        {
            ZegoTabBarViewController *tabController = (ZegoTabBarViewController *)rootViewController;
            if (self.requestInfo)
            {
                [tabController showRequestVideoAlert:self.requestInfo];
                self.requestInfo = nil;
            }
        }
    }
}

- (void)registerNotificationAction:(UIApplication *)application
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIMutableUserNotificationAction *actionMessage = [[UIMutableUserNotificationAction alloc] init];
        actionMessage.activationMode = UIUserNotificationActivationModeForeground;
        actionMessage.title = NSLocalizedString(@"打开", nil);
        actionMessage.identifier = kUserNotificationActionMessage;
        [actionMessage setDestructive:NO];
        [actionMessage setAuthenticationRequired:YES];
        
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = kUserNotificationActionMessageCategory;
        [category setActions:@[actionMessage] forContext:UIUserNotificationActionContextDefault];
        
        UIMutableUserNotificationAction *agreeMessage = [[UIMutableUserNotificationAction alloc] init];
        agreeMessage.activationMode = UIUserNotificationActivationModeForeground;
        agreeMessage.title = NSLocalizedString(@"同意", nil);
        agreeMessage.identifier = kUserNotificationActionAgree;
        [agreeMessage setDestructive:NO];
        [agreeMessage setAuthenticationRequired:YES];
        
        UIMutableUserNotificationAction *disagreeMessage = [[UIMutableUserNotificationAction alloc] init];
        disagreeMessage.activationMode = UIUserNotificationActivationModeForeground;
        disagreeMessage.title = NSLocalizedString(@"拒绝", nil);
        disagreeMessage.identifier = kUserNotificationActionDisagree;
        [disagreeMessage setDestructive:NO];
        [disagreeMessage setAuthenticationRequired:YES];
        
        UIMutableUserNotificationCategory *videoCategory = [[UIMutableUserNotificationCategory alloc] init];
        videoCategory.identifier = kUserNotificationActionVideoCategory;
        [videoCategory setActions:@[agreeMessage, disagreeMessage] forContext:UIUserNotificationActionContextDefault];
        
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:[NSSet setWithObjects:category, videoCategory, nil]]];
    }
}

- (void)onReceiveMessage:(NSNotification *)notification
{
    NSString *sessionId = notification.userInfo[@"session"];
    if (sessionId == nil)
        return;
    
    ZegoConversationMessage *message = [[[ZegoDataCenter sharedInstance] getMessageList:sessionId] lastObject];
    if (message == nil)
        return;
    
    NSString *notificationConent = [NSString stringWithFormat:@"%@:%@", message.fromUserName, message.content];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.repeatInterval = 0;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = notificationConent;
    localNotification.alertAction = kUserNotificationActionMessage;
    if (![[ZegoSettings sharedInstance] isDeviceiOS7])
        localNotification.category = kUserNotificationActionMessageCategory;
    
    localNotification.hasAction = YES;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    NSUInteger unreadCount = [[ZegoDataCenter sharedInstance] getTotalUnreadCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
}

- (void)onRequestVideoTalk:(NSNotification *)notification
{
    ZegoRequestTalkInfo *requestInfo = notification.userInfo[@"requestInfo"];
    if (requestInfo == nil)
        return;
    
    //只保留最后一次视频请求信息
    self.requestInfo = requestInfo;
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ 请求与你视频聊天", nil), requestInfo.fromUserName];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.repeatInterval = 0;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = message;
    localNotification.alertAction = kUserNotificationActionAgree;
    if (![[ZegoSettings sharedInstance] isDeviceiOS7])
        localNotification.category = kUserNotificationActionVideoCategory;
    
    localNotification.userInfo = @{@"requestSeq": @(requestInfo.requestSeq)};
    localNotification.hasAction = YES;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)onDisconnected:(NSNotification *)notification
{
    //在后台如果网络断了，不再播放静音
    NSLog(@"%s disconnected in background", __func__);
    
    [self.backgound stopPreventSleep];
}
@end
