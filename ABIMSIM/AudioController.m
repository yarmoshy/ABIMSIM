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
    AVAudioPlayer *minePlayer;
    AVAudioPlayer *shieldUpPlayer;
    AVAudioPlayer *shieldDownPlayer;
    AVAudioPlayer *shipExplosion;

    STKAudioPlayer* audioPlayer;
    MusicMode musicMode;
    NSTimer *currentTimeTimer;
    BOOL playSoundEffect, playMusic;
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
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        Float32 bufferLength = 0.1;
        [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:bufferLength error:&error];
        
        audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = YES, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        audioPlayer.meteringEnabled = YES;
        audioPlayer.volume = 1;
        audioPlayer.delegate = self;
        playSoundEffect = [ABIMSIMDefaults boolForKey:kSFXSetting];
        playMusic = [ABIMSIMDefaults boolForKey:kMusicSetting];
//        NSString* path = [[NSBundle mainBundle] pathForResource:@"Level1" ofType:@"mp3"];
//        NSURL* url = [NSURL fileURLWithPath:path];
//        
//        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
//        [audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
        
        NSError __autoreleasing *errorMine;
        NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"explosionMineTrimmed.caf"];
        minePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] fileTypeHint:@"caf" error:&errorMine];
        minePlayer.numberOfLoops = 0;
        minePlayer.delegate = self;
        [minePlayer prepareToPlay];
        
        filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"activateShieldTrimmed.caf"];
        shieldUpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] fileTypeHint:@"caf" error:&errorMine];
        shieldUpPlayer.numberOfLoops = 0;
        shieldUpPlayer.delegate = self;
        [shieldUpPlayer prepareToPlay];

        filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"deactivateShieldTrimmed.caf"];
        shieldDownPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] fileTypeHint:@"caf" error:&errorMine];
        shieldDownPlayer.numberOfLoops = 0;
        shieldDownPlayer.delegate = self;
        [shieldDownPlayer prepareToPlay];
        
        filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"explosionTrimmed.caf"];
        shipExplosion = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] fileTypeHint:@"caf" error:&errorMine];
        shipExplosion.numberOfLoops = 0;
        shipExplosion.delegate = self;
        [shipExplosion prepareToPlay];

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicToggled) name:kMusicToggleChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sfxToggled) name:kSFXToggleChanged object:nil];
    }
    return self;
}

-(void)musicToggled {
    playMusic = [ABIMSIMDefaults boolForKey:kMusicSetting];
    if (!playMusic) {
        [audioPlayer clearQueue];
        [audioPlayer stop];
    } else {
        [self audioPlayer:audioPlayer didStartPlayingQueueItemId:nil];
    }
}

-(void)sfxToggled {
    playSoundEffect = [ABIMSIMDefaults boolForKey:kSFXSetting];
}

-(void)playerDeath {
    musicMode = MusicModeIntro;
    if (playSoundEffect) {
        [shipExplosion play];
    }
    [audioPlayer stop];
    [self audioPlayer:audioPlayer didStartPlayingQueueItemId:nil];
}

-(void)gameplay {
    musicMode = MusicModeGame;
    [audioPlayer clearQueue];
    if (playMusic) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"parsecsGameplayMusic" ofType:@"mp3"];
        NSURL* url = [NSURL fileURLWithPath:path];
        
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        [audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
    }
}

-(void)mine {
    if (playSoundEffect) {
        [minePlayer play];
    }
}

-(void)shieldUp {
    if (playSoundEffect) {
        [shieldUpPlayer play];
    }
}

-(void)shieldDown {
    if (playSoundEffect) {
        [shieldDownPlayer play];
    }
}

#pragma mark - STKAudioPlayerDelegate

-(void) audioPlayer:(STKAudioPlayer*)aAudioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    if (!playMusic) {
        return;
    }
    if (musicMode == MusicModeIntro) {
//        NSString* path = [[NSBundle mainBundle] pathForResource:@"Level1" ofType:@"mp3"];
//        NSURL* url = [NSURL fileURLWithPath:path];
//        
//        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
//        [audioPlayer queueDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0]];
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

#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if ([player isEqual:minePlayer]) {
        [minePlayer prepareToPlay];
    } else if ([player isEqual:shieldUpPlayer]) {
        [shieldUpPlayer prepareToPlay];
    } else if ([player isEqual:shieldDownPlayer]) {
        [shieldDownPlayer prepareToPlay];
    }
}

@end
