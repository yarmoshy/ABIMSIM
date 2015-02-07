//
//  AudioController.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 2/5/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "AudioController.h"

static AudioController *sharedController;
typedef enum {
    MusicModeIntro,
    MusicModeGame,
    MusicModeDeath
} MusicMode;

@implementation AudioController  {
    AVAudioPlayer *deathPlayer;
    AVAudioPlayer *gamePlayer;
    AVAudioPlayer *introPlayer;
    STKAudioPlayer* audioPlayer;
    MusicMode musicMode;
    NSTimer *currentTimeTimer;
}


+(AudioController*)sharedController {
    if (!sharedController) {
        sharedController = [AudioController new];
    }
    return sharedController;
}

-(instancetype)init {
    if (self = [super init]) {
        NSError* error;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        Float32 bufferLength = 0.1;
        [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:bufferLength error:&error];
        
        audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        audioPlayer.meteringEnabled = YES;
        audioPlayer.volume = 1;
        audioPlayer.delegate = self;
    
        NSString* path = [[NSBundle mainBundle] pathForResource:@"Level1" ofType:@"mp3"];
        NSURL* url = [NSURL fileURLWithPath:path];
        
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        [audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
        
    }
    return self;
}

-(void)playerDeath {
    musicMode = MusicModeIntro;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"cheapExplosion" ofType:@"mp3"];
    NSURL* url = [NSURL fileURLWithPath:path];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    [audioPlayer playDataSource:dataSource withQueueItemID:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

-(void)gameplay {
    musicMode = MusicModeGame;
    [audioPlayer clearQueue];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"parsecsGameplayMusic" ofType:@"mp3"];
    NSURL* url = [NSURL fileURLWithPath:path];
    
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    [audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
}

#pragma mark - STKAudioPlayerDelegate

-(void) audioPlayer:(STKAudioPlayer*)aAudioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    if (musicMode == MusicModeIntro) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"Level1" ofType:@"mp3"];
        NSURL* url = [NSURL fileURLWithPath:path];
        
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        [audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    } else if (musicMode == MusicModeGame) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"parsecsGameplayMusic" ofType:@"mp3"];
        NSURL* url = [NSURL fileURLWithPath:path];
        
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        [audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    } else if (musicMode == MusicModeDeath) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"Level1" ofType:@"mp3"];
        NSURL* url = [NSURL fileURLWithPath:path];
        
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        [audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    }
}


-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{
    
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState{
    
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{
    
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode{
    
}
@end
