//
//  ZegoLiveRoomApiDefines-IM.h
//  ZegoLiveRoom
//
//  Copyright © 2017年 zego. All rights reserved.
//

#ifndef ZegoLiveRoomApiDefines_IM_h
#define ZegoLiveRoomApiDefines_IM_h

/** 用户更新类型 */
typedef enum
{
    ZEGO_UPDATE_TOTAL = 1,      /**< 全量更新 */
    ZEGO_UPDATE_INCREASE,       /**< 增量更新 */
} ZegoUserUpdateType;

/** 用户更新属性 */
typedef enum
{
    ZEGO_USER_ADD = 1,          /**< 新增 */
    ZEGO_USER_DELETE,           /**< 删除 */
} ZegoUserUpdateFlag;

/** 消息类型 */
typedef enum
{
    ZEGO_TEXT = 1,              /**< 文字 */
    ZEGO_PICTURE,               /**< 图片 */
    ZEGO_FILE,                  /**< 文件 */
    ZEGO_OTHER_TYPE = 100,      /**< 其他 */
} ZegoMessageType;

/** 消息优先级 */
typedef enum
{
    ZEGO_DEFAULT = 2,           /**< 默认优先级 */
    ZEGO_HIGH = 3,              /**< 高优先级 */
} ZegoMessagePriority;

/** 消息类别 */
typedef enum
{
    ZEGO_CHAT = 1,              /**< 聊天 */
    ZEGO_SYSTEM,                /**< 系统 */
    ZEGO_LIKE,                  /**< 点赞 */
    ZEGO_GIFT,                  /**< 送礼物 */
    ZEGO_OTHER_CATEGORY = 100,  /**< 其他 */
} ZegoMessageCategory;

@interface ZegoUserState : NSObject

@property (nonatomic, copy) NSString *userID;               /**< 用户 ID */
@property (nonatomic, copy) NSString *userName;             /**< 用户名 */
@property (nonatomic, assign) ZegoUserUpdateFlag updateFlag; /**< 用户更新属性 */
@property (nonatomic, assign) int role;                     /**< 角色 */

@end

@interface ZegoRoomMessage : NSObject

@property (nonatomic, copy) NSString *fromUserId;           /**< 来源用户 Id */
@property (nonatomic, copy) NSString *fromUserName;         /**< 来源用户名 */
@property (nonatomic, assign) unsigned long long messageId; /**< 消息 Id */
@property (nonatomic, copy) NSString *content;              /**< 内容 */
@property (nonatomic, assign) ZegoMessageType type;         /**< 消息类型 */
@property (nonatomic, assign) ZegoMessagePriority priority; /**< 消息优先级 */
@property (nonatomic, assign) ZegoMessageCategory category; /**< 消息类别 */

@end

@interface ZegoConversationMessage : NSObject

@property (nonatomic, copy) NSString *fromUserId;           /**< 来源用户 Id */
@property (nonatomic, copy) NSString *fromUserName;         /**< 来源用户名 */
@property (nonatomic, assign) unsigned long long messageId; /**< 消息 Id */
@property (nonatomic, copy) NSString *content;              /**< 内容 */
@property (nonatomic, assign) ZegoMessageType type;         /**< 消息类型 */
@property (nonatomic, assign) unsigned int sendTime;        /**< 发送时间 */

@end

@interface ZegoUser : NSObject 

@property (nonatomic, copy) NSString *userId;               /**< 用户 Id */
@property (nonatomic, copy) NSString *userName;             /**< 用户名 */

@end

@interface ZegoConversationInfo : NSObject 

@property (nonatomic, copy) NSString *conversationName;     /**< 会话名称 */
@property (nonatomic, copy) NSString *creatorId;            /**< 会话创建者 Id */
@property (nonatomic, assign) unsigned int createTime;      /**< 创建时间 */
@property (nonatomic, strong) NSArray<ZegoUser*>* members;  /**< 会话成员列表 */

@end

#endif /* ZegoLiveRoomApiDefines_h */
