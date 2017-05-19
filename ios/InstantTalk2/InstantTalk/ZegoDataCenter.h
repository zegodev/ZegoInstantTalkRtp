//
//  ZegoDataCenter.h
//  InstantTalk
//
//  Created by Strong on 16/7/7.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZegoAVKitManager.h"

extern NSString *const kUserUpdateNotification;
extern NSString *const kUserLoginNotification;
extern NSString *const kUserDisconnectNotification;
extern NSString *const kUserMessageReceiveNotification;
extern NSString *const kUserMessageSendNotification;
extern NSString *const kUserRequestVideoTalkNotification;
extern NSString *const kUserAcceptVideoTalkNotification;
extern NSString *const kUserRespondVideoTalkNotification;
extern NSString *const kUserCancelVideoTalkNotification;
extern NSString *const kUserClearAllSessionNotification;
extern NSString *const kUserUnreadCountUpdateNotification;

@interface ZegoRequestTalkInfo : NSObject

@property (nonatomic, copy) NSString *fromUserId;
@property (nonatomic, copy) NSString *fromUserName;
@property (nonatomic, assign) int requestSeq;
@property (nonatomic, copy) NSString *preferedRoomId;

@end

@interface ZegoSession: NSObject

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *sessionName;
@property (nonatomic, strong) NSMutableArray<ZegoUser *> *memberList;
@property (nonatomic, strong) NSMutableArray<ZegoConversationMessage *> *messageHistory;
@property (nonatomic, assign) NSUInteger unreadCount;

@end

@interface ZegoDataCenter : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign, readonly) BOOL isLogin;

//当前在线用户列表
@property (nonatomic, strong, readonly) NSMutableArray<ZegoUser*> *userList;

//聊天记录
@property (nonatomic, strong, readonly) NSMutableArray<ZegoSession *> *sessionList;

- (void)loginRoom;
- (void)leaveRoom;

#pragma mark Message
//创建一个session (发起多人会话时每次都创建一个sesssion，单人会话从历史记录中查找）
- (BOOL)createSessionWithMemberList:(NSArray<ZegoUser *> *)memberList completion:(void (^)(NSString *sessionId))completionBlock;

//一个session中删除成员
//- (void)removeMember:(NSArray<ZegoUser *> *)removeMemberList sessionID:(NSString *)sessionID;
//一个session中增加成员
//- (void)addMember:(NSArray<ZegoUser *> *)addMemberList  sessionID:(NSString *)sessionID;

//向一个session发送消息
- (BOOL)sendMessage:(NSString *)sessionID messageContent:(NSString *)messageContent completion:(void (^)(int errorCode))completionBlock;

//清除一个session的未读计数
- (void)clearUnreadCount:(NSString *)sessionID;
//获取所有的未读计数
- (NSUInteger)getTotalUnreadCount;

//删除一个session
- (void)deleteSession:(ZegoSession *)session;
//删除所有session
- (void)clearAllSession;

//根据session获取当前成员列表
- (NSArray<ZegoUser *> *)getMemberList:(NSString *)sessionID;
//根据session获取当前聊天记录
- (NSArray<ZegoConversationMessage*> *)getMessageList:(NSString *)sessionID;

//单人会话时，获取成员列表中另外一个成员
- (ZegoUser *)getOtherMember:(NSArray<ZegoUser *> *)memberList;

//保存所有会话记录到本地
- (void)saveSessionList;

//检查是否存在memberlist相同的session
- (ZegoSession *)isSessionExistWithSameMemberList:(NSArray<ZegoUser *> *)memberList;

#pragma mark User
//判断用户是否在线
- (BOOL)isUserOnline:(NSString *)userID;
//判断成员列表是否有人在线
//YES: 至少有人在线(除用户自己外)
//NO: 没有任何人在线
- (BOOL)isMemberOnline:(NSArray<ZegoUser *> *)userList;

#pragma mark VideoTalk
//用户发起视频聊天请求
- (void)requestVideoTalk:(NSArray<ZegoUser *> *)userList videoRoomId:(NSString *)videoRoomId completion:(void (^)(int errorCode))completionBlock;

//取消视频聊天请求
- (void)cancelVideoTalk;
//用户同意/拒绝视频聊天
- (void)agreedVideoTalk:(BOOL)agreed requestSeq:(int)seq;

- (void)contactUs;


@end
