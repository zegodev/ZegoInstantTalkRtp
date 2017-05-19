//
//  ZegoBackground.m
//  InstantTalk
//
//  Created by Strong on 16/7/19.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoBackground.h"
#import <AVFoundation/AVFoundation.h>

@interface ZegoBackground ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSTimer *preventTimer;

@end

@implementation ZegoBackground

- (void)startPreventSleep
{
    if (self.preventTimer)
    {
        [self.preventTimer invalidate];
        self.preventTimer = nil;
    }
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"silence" withExtension:@"mp3"]];
    self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    self.player.volume = 0.0f;
    [self.player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    
    [[AVAudioSession sharedInstance] setActive:YES withOptions:0 error:&sessionError];
    
    self.preventTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:5.0 target:self selector:@selector(playSilentSound) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.preventTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopPreventSleep
{
    [self.player pause];
    
    [self.preventTimer invalidate];
    self.preventTimer = nil;
}

- (void)playSilentSound
{
    NSLog(@"playSilentSound now");
    [self.player play];
}

@end
