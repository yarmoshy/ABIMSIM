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
    AVAudioPlayer *upgradePlayer;
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
        audioPlayer.volume = 0.6;
        audioPlayer.delegate = self;
        audioPlayer.enableRate = YES;
        [audioPlayer prepareToPlay];
        playSoundEffect = [ABIMSIMDefaults boolForKey:kSFXSetting];
        playMusic = [ABIMSIMDefaults boolForKey:kMusicSetting];
        
        NSError __autoreleasing *errorUpgrade;
        NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"upgrade.caf"];

        upgradePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] fileTypeHint:@"caf" error:&errorUpgrade];
        upgradePlayer.numberOfLoops = 0;
        upgradePlayer.delegate = self;
        [upgradePlayer prepareToPlay];

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
            dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(backgroundQueue, ^{
                [audioPlayer play];
            });
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
    audioPlayer.rate = 1;
}

-(void)gameplay {
    musicMode = MusicModeGame;
    if (playMusic) {
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(backgroundQueue, ^{
            [audioPlayer play];
        });
    }
}

-(void)upgrade {
    if (playSoundEffect) {
        [upgradePlayer play];
    }
}

-(void)blackhole {
    if (arc4random() % 2)
        audioPlayer.rate = 0.5;
    else
        audioPlayer.rate = 2;
}

-(void)endBlackhole {
    audioPlayer.rate = 1;
}

#pragma mark AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (musicMode == MusicModeGame && playMusic) {
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(backgroundQueue, ^{
            [audioPlayer play];
        });
    }
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    if (musicMode == MusicModeGame && playMusic) {
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(backgroundQueue, ^{
            [audioPlayer play];
        });
    }
}

@end
