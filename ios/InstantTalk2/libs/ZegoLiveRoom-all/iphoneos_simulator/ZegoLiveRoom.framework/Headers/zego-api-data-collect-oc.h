//
//  zego-api-data-collect-oc.h
//  ZegoLiveRoom
//
//  Created by Strong on 11/12/2017.
//

#import <Foundation/Foundation.h>

@interface ZegoDataCollect : NSObject

+ (int)startTask:(NSString *)type content:(NSString *)content;

+ (void)addTaskEvent:(unsigned int)seq event:(NSString *)event content:(NSString *)content;

+ (void)finishTask:(unsigned int)seq errorCode:(unsigned int)code message:(NSString *)message;

@end
