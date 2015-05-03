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
    AVAudioPlayer *audioPlayer;
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
        NSString* path = [[NSBundle mainBundle] pathForResource:@"gamePlay" ofType:@"caf"];
        NSURL* url = [NSURL fileURLWithPath:path];

        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.volume = 0.8;
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
        playSoundEffect = [ABIMSIMDefaults boolForKey:kSFXSetting];
        playMusic = [ABIMSIMDefaults boolForKey:kMusicSetting];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicToggled) name:kMusicToggleChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sfxToggled) name:kSFXToggleChanged object:nil];
    }
    return self;
}

-(void)musicToggled {
    playMusic = [ABIMSIMDefaults boolForKey:kMusicSetting];
    if (!playMusic) {
        [audioPlayer stop];
        [audioPlayer setCurrentTime:0];
        [audioPlayer prepareToPlay];
    } else {
        if (musicMode == MusicModeGame) {
            [audioPlayer play];
        }
    }
}

-(void)sfxToggled {
    playSoundEffect = [ABIMSIMDefaults boolForKey:kSFXSetting];
}

-(void)playerDeath {
    musicMode = MusicModeIntro;
    [audioPlayer stop];
    [audioPlayer setCurrentTime:0];
    [audioPlayer prepareToPlay];
}

-(void)gameplay {
    musicMode = MusicModeGame;
    if (playMusic) {
        [audioPlayer play];
    }
}

#pragma mark AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (musicMode == MusicModeGame && playMusic) {
        [audioPlayer play];
    }
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    if (musicMode == MusicModeGame && playMusic) {
        [audioPlayer play];
    }
}

@end
