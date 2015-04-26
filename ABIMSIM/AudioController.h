//
//  AudioController.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 2/5/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "STKAudioPlayer.h"
#import "SampleQueueId.h"

@interface AudioController : NSObject  <STKAudioPlayerDelegate>
+(AudioController*)sharedController;
-(void)playerDeath;
-(void)gameplay;
@end
