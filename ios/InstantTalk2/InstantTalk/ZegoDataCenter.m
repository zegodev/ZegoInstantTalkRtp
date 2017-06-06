//
//  ZegoDataCenter.m
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoDataCenter.h"
#import "ZegoSettings.h"
#import "ZegoAVKitManager.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

NSString *const kUserUpdateNotification             = @"userUpdate";
NSString *const kUserLoginNotification              = @"userLogin";
NSString *const kUserDisconnectNotification         = @"userDisconnect";
NSString *const kUserMessageReceiveNotification     = @"receiveMessage";
NSString *const kUserMessageSendNotification        = @"sendMessage";
NSString *const kUserRequestVideoTalkNotification   = @"requestVideoTalk";
NSString *const kUserAcceptVideoTalkNotification    = @"acceptVideoTalk";
NSString *const kUserRespondVideoTalkNotification   = @"respondVideoTalk";
NSString *const kUserCancelVideoTalkNotification    = @"cancelVideoTalk";
NSString *const kUserClearAllSessionNotification    = @"clearAllSession";
NSString *const kUserUnreadCountUpdateNotification  = @"unreadCountUpdate";

@implementation ZegoRequestTalkInfo

@end

@implementation ZegoSession

- (void)setUnreadCount:(NSUInteger)unreadCount
{
    if (_unreadCount != unreadCount)
    {
        _unreadCount = unreadCount;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserUnreadCountUpdateNotification object:@{@"session": self.sessionId}];
    }
}

@end

@interface ZegoDataCenter () <ZegoChatRoomDelegate>
//日志记录
@property (nonatomic, strong) NSMutableArray *logArray;

//接收到的请求视频列表
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, ZegoRequestTalkInfo*> *receivedRequestList;

//发送的视频请求用户列表
@property (nonatomic, strong) NSMutableArray *waitingRequestUserList;
//发送的视频seq, 如果requestSeq不为0，再次请求其他通话，需要先cancel
@property (nonatomic, assign) NSUInteger requestSeq;

@end

@implementation ZegoDataCenter

+ (instancetype)sharedInstance
{
    static ZegoDataCenter *gInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gInstance = [[ZegoDataCenter alloc] init];
    });
    
    return gInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.logArray = [NSMutableArray array];
        _userList = [[NSMutableArray alloc] init];
        self.receivedRequestList = [NSMutableDictionary dictionary];
        self.waitingRequestUserList = [NSMutableArray array];
        self.requestSeq = 0;
        
        [self loadSessionList];
        if (_sessionList == nil)
            _sessionList = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeAppID:) name:@"RoomInstanceClear" object:nil];
        
        [[ZegoInstantTalk api] setChatRoomDelegate:self];
        _isLogin = NO;
    }
    
    return self;
}

- (void)onChangeAppID:(NSNotification *)notification
{
    _isLogin = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDisconnectNotification object:self userInfo:nil];
}

- (NSString *)getCurrentTime
{
//    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"[HH-mm-ss:SSS]";
    return [formatter stringFromDate:[NSDate date]];
}

- (void)addLogString:(NSString *)logString
{
    if (logString.length != 0)
    {
        NSString *totalString = [NSString stringWithFormat:@"%@: %@", [self getCurrentTime], logString];
        [self.logArray insertObject:totalString atIndex:0];
    }
}

- (void)loginRoom
{
    if (self.isLogin)
    {
        [self addLogString:NSLocalizedString(@"当前已登录", nil)];
        return;
    }
    
    if (self.isLoging)
    {
        [self addLogString:NSLocalizedString(@"当前正在登录", nil)];
        return;
    }
    
    [[ZegoInstantTalk api] setChatRoomDelegate:self];
    
    _isLoging = YES;
    
    [[ZegoInstantTalk api] loginChatRoomWithCompletion:^(int errorCode) {
        if (errorCode == 0)
        {
            _isLogin = YES;
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间成功.", nil)];
            [self addLogString:logString];
        }
        else
        {
            _isLogin = NO;
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间失败. error: %d", nil), errorCode];
            [self addLogString:logString];
        }
        
        _isLoging = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginNotification object:nil userInfo:@{@"Result": @(self.isLogin)}];
    }];
    
    [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"开始登录房间", nil)]];
}

- (void)leaveRoom
{
    if (!self.isLogin)
    {
        [self addLogString:NSLocalizedString(@"当前未登录或进入了私聊房间", nil)];
        return;
    }
    
    [[ZegoInstantTalk api] logoutChatRoom];
    _isLogin = NO;
    
    [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"离开房间", nil)]];
}

#pragma mark VideoTalk Function
- (void)requestVideoTalk:(NSArray<ZegoUser *> *)userList videoRoomId:(NSString *)videoRoomId completion:(void (^)(int))completionBlock
{
    if (self.requestSeq != 0)
    {
        [self cancelVideoTalk];
    }
    
    int requestSeq = [[ZegoInstantTalk api] requestVideoTalk:userList videoRoomId:videoRoomId completion:^(int errorCode) {
        if (errorCode != 0)
        {
            self.requestSeq = 0;
            [self.waitingRequestUserList removeAllObjects];
            
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"请求视频通话错误, %d", nil), errorCode];
            [self addLogString:logString];
        }
        
        if (completionBlock)
            completionBlock(errorCode);
        
    }];

    self.requestSeq = requestSeq;
    self.waitingRequestUserList = [NSMutableArray arrayWithArray:userList];
}

- (void)cancelVideoTalk
{
    if (self.requestSeq == 0)
        return;
    
    [[ZegoInstantTalk api] cancelVideoTalk:(int)self.requestSeq completion:^(int errorCode) {
        if (errorCode == 0)
        {
            self.requestSeq = 0;
            [self.waitingRequestUserList removeAllObjects];
        }
    }];
}

- (void)agreedVideoTalk:(BOOL)agreed requestSeq:(int)seq
{
    if (self.receivedRequestList[@(seq)] == nil)
        return;
    
    [[ZegoInstantTalk api] respondVideoTalk:seq respondResult:agreed completion:^(int errorCode) {
        if (agreed)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserAcceptVideoTalkNotification object:nil userInfo:@{@"requestInfo": self.receivedRequestList[@(seq)]}];
        }
        
        [self.receivedRequestList removeObjectForKey:@(seq)];
    }];
}

#pragma mark User Help Function
- (BOOL)isUserSelf:(NSString *)userID
{
    if ([[ZegoSettings sharedInstance].userID isEqualToString:userID])
        return YES;
    
    return NO;
}

- (BOOL)isUserExist:(NSString *)userID
{
    NSArray *filterArray = [self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", userID]];
    if (filterArray.count == 0)
        return NO;
    
    return YES;
}

- (void)removeUser:(NSString *)userID
{
    NSArray *filterArray = [self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", userID]];
    if (filterArray.count == 0)
        return;
    
    [self.userList removeObjectsInArray:filterArray];
}

#pragma mark Session Help
- (ZegoSession *)getSessionById:(NSString *)sessionId
{
    if (sessionId.length == 0)
        return nil;
    
    NSArray *filterArray = [self.sessionList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sessionId == %@", sessionId]];
    if (filterArray.count != 1)
        return nil;
    
    return [filterArray firstObject];
}

- (void)updateSessionIndex:(ZegoSession *)session
{
    if (session != nil)
    {
        [self.sessionList removeObject:session];
        [self.sessionList insertObject:session atIndex:0];
    }
}

- (BOOL)isMemberListContainSelf:(NSArray<ZegoUser *> *)memberList
{
    NSArray *filterArray = [memberList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", [ZegoSettings sharedInstance].userID]];
    if (filterArray.count == 1)
        return YES;
    
    return NO;
}

- (ZegoSession *)createSession:(NSString *)sessionId sessionName:(NSString *)sessionName memberList:(NSArray<ZegoUser *> *)memberList
{
    ZegoSession *session = [ZegoSession new];
    session.sessionId = sessionId;
    session.sessionName = sessionName;
    session.memberList = [NSMutableArray arrayWithArray:memberList];
    if (![self isMemberListContainSelf:memberList])
    {
        ZegoUser *user = [ZegoUser new];
        user.userId = [ZegoSettings sharedInstance].userID;
        user.userName = [ZegoSettings sharedInstance].userName;
        
        [session.memberList addObject:user];
    }
    
    session.messageHistory = [NSMutableArray array];
    session.unreadCount = 0;
    
    return session;
}

- (ZegoUser *)getOtherMember:(NSArray<ZegoUser *> *)memberList
{
    if (memberList.count != 2)
        return nil;
    
    NSArray *notSelfMemberArray = [memberList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId != %@", [ZegoSettings sharedInstance].userID]];
    if (notSelfMemberArray.count != 1)
        return nil;
    
    return notSelfMemberArray.firstObject;
}

- (BOOL)isUserExist:(NSString *)userID memberList:(NSArray<ZegoUser *> *)memberList
{
    NSArray *filterArray = [memberList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", userID]];
    if (filterArray.count == 0)
        return NO;
    
    return YES;
}

- (ZegoSession *)isSessionExistWithSameMemberList:(NSArray<ZegoUser *> *)memberList
{
    for (ZegoSession *session in self.sessionList)
    {
        BOOL found = YES;
        for (ZegoUser *user in memberList)
        {
            if (![self isUserExist:user.userId memberList:session.memberList])
            {
                found = NO;
                break;
            }
        }
        
        if (found == YES)
        {
            return session;
        }
    }
    
    return nil;
}

#pragma mark GroupChat Message
- (BOOL)createSessionWithMemberList:(NSArray<ZegoUser *> *)memberList completion:(void (^)(NSString *sessionId))completionBlock
{
    if (memberList.count < 1)
        return NO;
    
    //检查session是否存在
    NSString *groupName = nil;
    ZegoSession *session = [self isSessionExistWithSameMemberList:memberList];
    if (session)
    {
        [self.sessionList removeObject:session];
        [self.sessionList insertObject:session atIndex:0];
        
        if (completionBlock)
            completionBlock(session.sessionId);
    }
    
    if (memberList.count == 2)
    {
        ZegoUser *user = [self getOtherMember:memberList];
        groupName = user.userName;
    }
    else
    {
        groupName = @"群聊";
    }

    [[ZegoInstantTalk api] createGroupChat:groupName memberList:memberList completion:^(int errorCode, NSString *groupId) {
        if (errorCode == 0)
        {
            ZegoSession *session = [self createSession:groupId sessionName:groupName memberList:memberList];
            [self.sessionList insertObject:session atIndex:0];
            
            if (completionBlock)
                completionBlock(groupId);
        }
        else
        {
            if (completionBlock)
                completionBlock(nil);
        }
    }];
    
    return YES;
}

- (BOOL)sendMessage:(NSString *)sessionID messageContent:(NSString *)messageContent completion:(void (^)(int))completionBlock
{
    if (sessionID.length == 0 || messageContent.length == 0)
        return NO;
    
    ZegoSession *session = [self getSessionById:sessionID];
    if (session == nil)
        return NO;
    
    ZegoConversationMessage *message = [ZegoConversationMessage new];
    message.fromUserId = [ZegoSettings sharedInstance].userID;
    message.fromUserName = [ZegoSettings sharedInstance].userName;
    message.content = messageContent;
    message.type = ZEGO_TEXT;
    message.sendTime = [[NSDate date] timeIntervalSince1970];
    [session.messageHistory addObject:message];
    [self updateSessionIndex:session];
    
    [[ZegoInstantTalk api] sendGroupChatMessage:messageContent type:ZEGO_TEXT groupId:sessionID completion:^(int errorCode, NSString *groupId, unsigned long long messageId) {
        if (errorCode == 0)
            message.messageId = messageId;
        
        if (completionBlock)
            completionBlock(errorCode);
    }];
    
    return YES;
}

#pragma mark ZegoChatRoomDelegate
- (void)onConnectState:(ZegoChatRoomConnectState)state
{
    if (state == Disconnected)
    {
        _isLogin = NO;
        
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"断开房间.", nil)];
        [self addLogString:logString];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserDisconnectNotification object:self userInfo:nil];
    }
}

- (void)onChatRoomUserUpdate:(NSArray<ZegoUserState *> *)userList updateType:(ZegoUserUpdateType)type
{
    if (type == ZEGO_UPDATE_TOTAL)
        [self.userList removeAllObjects];
    
    for (ZegoUserState *state in userList)
    {
        if (state.updateFlag == ZEGO_USER_ADD)
        {
            NSString *userID = state.userID;
            NSString *userName = state.userName;
            
            NSLog(@"%s, add new userID %@, userName %@", __func__, userID, userName);
            
            if ([self isUserSelf:userID])
            {
                NSLog(@"%s, user is self, userID %@", __func__, userID);
                continue;
            }
            
            if ([self isUserExist:userID])
            {
                NSLog(@"%s, user exist userID %@", __func__, userID);
                
                NSArray *filterArray = [self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", userID]];
                [self.userList removeObjectsInArray:filterArray];
            }
            
            ZegoUser *user = [ZegoUser new];
            user.userName = userName;
            user.userId = userID;
            
            [self.userList addObject:user];
        }
        else if (state.updateFlag == ZEGO_USER_DELETE)
        {
            NSLog(@"%s, remove userID %@", __func__, state.userID);
            
            [self removeUser:state.userID];
        }
    }
    
    //通知界面更新
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpdateNotification object:self userInfo:nil];
}

- (void)onRecvBroadMessage:(NSArray<ZegoRoomMessage *> *)messageList
{
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"收到广播消息", nil)];
    [self addLogString:logString];

}

- (void)onRecvRequestVideoTalk:(int)respondSeq fromUserId:(NSString *)fromUserId fromUserName:(NSString *)fromUserName videoRoomId:(NSString *)videoRoomId
{
    if (respondSeq < 0)
    {
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"收到请求视频通话消息错误", nil)];
        [self addLogString:logString];
    }
    
    ZegoRequestTalkInfo *info = [ZegoRequestTalkInfo new];
    info.fromUserId = fromUserId;
    info.fromUserName = fromUserName;
    info.requestSeq = respondSeq;
    info.preferedRoomId = videoRoomId;
    
    //通知界面显示弹框，保存中间信息
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserRequestVideoTalkNotification object:nil userInfo:@{@"requestInfo": info}];
    self.receivedRequestList[@(respondSeq)] = info;
}

- (void)onRecvCancelVideoTalk:(int)respondSeq fromUserId:(NSString *)fromUserId fromUserName:(NSString *)fromUserName
{
    if (self.receivedRequestList[@(respondSeq)] == nil)
    {
        NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"收到取消视频通话消息错误", nil)];
        [self addLogString:logString];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserCancelVideoTalkNotification object:nil userInfo:@{@"requestSeq": @(respondSeq)}];
}

- (void)onRecvRespondVideoTalk:(int)requestSeq fromUserId:(NSString *)fromUserId fromUserName:(NSString *)fromUserName respondResult:(bool)result
{
    if (self.requestSeq != requestSeq)
    {
        //当前请求seq改变，通知对方取消
        [[ZegoInstantTalk api] cancelVideoTalk:requestSeq completion:nil];
        return;
    }
    
    for (ZegoUser *user in self.waitingRequestUserList)
    {
        if ([user.userId isEqualToString:fromUserId])
        {
            //有用户回复了视频聊天请求，通知界面
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserRespondVideoTalkNotification object:nil userInfo:@{@"result": @(result), @"user": user}];
            
            [self.waitingRequestUserList removeObject:user];
            break;
        }
    }
}

- (void)onRecvGroupChatMessage:(NSString *)groupId message:(ZegoConversationMessage *)message
{
    ZegoSession *session = [self getSessionById:groupId];
    if (session == nil)
    {
        //Get SessionInfo
        [[ZegoInstantTalk api] getGroupChatInfo:groupId completion:^(int errorCode, NSString *groupId, ZegoConversationInfo *info) {
            if (errorCode != 0)
                return;
            
            //检查member相同，但是sessionId不同，更新sessionId
            ZegoSession *session = [self isSessionExistWithSameMemberList:info.members];
            if (session == nil)
            {
                session = [self createSession:groupId sessionName:info.conversationName memberList:info.members];
                
                session.unreadCount = 1;
                [session.messageHistory addObject:message];
                [self.sessionList insertObject:session atIndex:0];
            }
            else
            {
                session.sessionId = groupId;
                session.sessionName = info.conversationName;
                session.unreadCount += 1;
                [self.sessionList removeObject:session];
                [self.sessionList insertObject:session atIndex:0];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserMessageReceiveNotification object:nil userInfo:@{@"session": groupId}];
        }];
    }
    else
    {
        session.unreadCount += 1;
        [session.messageHistory addObject:message];
        [self updateSessionIndex:session];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserMessageReceiveNotification object:nil userInfo:@{@"session": groupId}];
    }

}

- (NSArray<ZegoUser *> *)getMemberList:(NSString *)sessionID
{
    if (sessionID.length == 0)
        return nil;
    
    ZegoSession *session = [self getSessionById:sessionID];
    if (session == nil)
        return nil;
    
    return session.memberList;
}

- (NSArray<ZegoConversationMessage*> *)getMessageList:(NSString *)sessionID
{
    if (sessionID.length == 0)
        return nil;
    
    ZegoSession *session = [self getSessionById:sessionID];
    if (session == nil)
        return nil;
    
    return session.messageHistory;
}

- (void)clearUnreadCount:(NSString *)sessionID
{
    ZegoSession *session = [self getSessionById:sessionID];
    if (session == nil)
        return;
    
    session.unreadCount = 0;
}

- (NSUInteger)getTotalUnreadCount
{
    NSUInteger totalCount = 0;
    for (ZegoSession *session in self.sessionList)
    {
        totalCount += session.unreadCount;
    }
    
    return totalCount;
}

- (void)deleteSession:(ZegoSession *)session
{
    if (session != nil)
    {
        session.unreadCount = 0;
        
        [self.sessionList removeObject:session];
    }
}

- (void)clearAllSession
{
    [self.sessionList removeAllObjects];
    [self saveSessionList];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserClearAllSessionNotification object:nil userInfo:nil];
}

- (NSString *)documentPath
{
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [documents firstObject];
}

- (void)saveSessionList
{
//    NSString *sessionListPath = [[self documentPath] stringByAppendingPathComponent:@"session"];
//    [NSKeyedArchiver archiveRootObject:self.sessionList toFile:sessionListPath];
}

- (void)loadSessionList
{
//    NSString *sessionListPath = [[self documentPath] stringByAppendingPathComponent:@"session"];
//    NSArray *sessionList = [NSKeyedUnarchiver unarchiveObjectWithFile:sessionListPath];
    
//    _sessionList = [NSMutableArray arrayWithArray:sessionList];
}

- (BOOL)isUserOnline:(NSString *)userID
{
    NSArray *filterArray = [self.userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", userID]];
    if (filterArray.count > 0)
        return YES;
    
    return NO;
}

- (BOOL)isMemberOnline:(NSArray<ZegoUser *> *)userList
{
    if (!self.isLogin)
        return NO;
    
    NSArray *filterArray = [userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId != %@", [ZegoSettings sharedInstance].userID]];
    if (filterArray.count == 0)
        return NO;
    
    for (ZegoUser *user in filterArray)
    {
        if ([self isUserOnline:user.userId])
            return YES;
    }
    
    return NO;
}

- (void)stopVideoTalk
{

}

- (void)contactUs
{
#if defined(__i386__)
#else
    if (![QQApiInterface isQQInstalled])
    {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"联系我们", nil)];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"没有安装QQ", nil) message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    
    QQApiWPAObject *wpaObject = [QQApiWPAObject objectWithUin:@"84328558"];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObject];
    QQApiSendResultCode result = [QQApiInterface sendReq:req];
    NSLog(@"share result %d", result);
#endif
}
@end
