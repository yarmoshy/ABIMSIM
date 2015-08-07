//
//  PausedView.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/23/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "PausedView.h"
#import "AudioController.h"
#import "UIView+Fancy.h"
#import "DCRoundSwitch.h"

@implementation PausedView

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupMusicToggle) name:kMusicToggleChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSFXToggle) name:kSFXToggleChanged object:nil];
    }
    return self;
}

-(void)didMoveToSuperview {
    self.playPausedButton.exclusiveTouch = self.mainMenuButton.exclusiveTouch = YES;
    [self setupToggles];
    [self.musicPausedSwitch addTarget:self action:@selector(musicSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.sfxPausedSwitch addTarget:self action:@selector(sfxSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    self.pausedLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.pausedLabel.layer.shadowRadius = 10;
    self.pausedLabel.layer.shadowOpacity = 0.25;
    self.settingsLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.settingsLabel.layer.shadowRadius = 10;
    self.settingsLabel.layer.shadowOpacity = 0.25;

}

-(void)setupToggles {
    [self setupMusicToggle];
    [self setupSFXToggle];
}

-(void)setupMusicToggle {
    self.musicPausedSwitch.on = [ABIMSIMDefaults boolForKey:kMusicSetting];
}

-(void)setupSFXToggle {
    self.sfxPausedSwitch.on = [ABIMSIMDefaults boolForKey:kSFXSetting];
}


-(void)musicSwitchToggled:(DCRoundSwitch*)toggle {
    [ABIMSIMDefaults setBool:toggle.on forKey:kMusicSetting];
    [ABIMSIMDefaults synchronize];
    self.musicPausedSwitch.on = toggle.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMusicToggleChanged object:nil];
}

-(void)sfxSwitchToggled:(DCRoundSwitch*)toggle {
    [ABIMSIMDefaults setBool:toggle.on forKey:kSFXSetting];
    [ABIMSIMDefaults synchronize];
    self.sfxPausedSwitch.on = toggle.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSFXToggleChanged object:nil];
}


-(void)animatePlayPausedButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithRing1:self.playPausedRing0 ring2:self.playPausedRing1 ring3:self.playPausedRing2 ring4:self.playPausedRing3 andCompletion:completionBlock];
}

-(void)animatePlayPausedButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithRing1:self.playPausedRing0 ring2:self.playPausedRing1 ring3:self.playPausedRing2 ring4:self.playPausedRing3 andCompletion:completionBlock];
}

- (IBAction)playPausedSelect:(id)sender {
    [self animatePlayPausedButtonSelect:nil];
}

- (IBAction)playPausedDeselect:(id)sender {
    [self animatePlayPausedButtonDeselect:nil];
}

- (IBAction)playPausedTouchUpInside:(id)sender {
    [[AudioController sharedController] gameplay];
    
    [self configureButtonsEnabled:NO];
    [self animatePlayPausedButtonDeselect:^{
        [self.delegate pausedViewViewDidSelectButtonType:PausedViewViewButtonTypePlay];
    }];
}

#pragma mark - Main Menu Button

-(void)animateMainMenuButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithRing1:self.mmRing0 ring2:self.mmRing2 ring3:self.mmRing1 ring4:self.mmRing0 andCompletion:completionBlock];
}

-(void)animateMainMenuButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithRing1:self.mmRing0 ring2:self.mmRing2 ring3:self.mmRing1 ring4:self.mmRing0 andCompletion:completionBlock];
}

- (IBAction)mainMenuSelect:(id)sender {
    [self animateMainMenuButtonSelect:nil];
}

- (IBAction)mainMenuDeselect:(id)sender {
    [self animateMainMenuButtonDeselect:nil];
}

- (IBAction)mainMenuTouchUpInside:(id)sender {
    [[AudioController sharedController] playerDeath];
    [self configureButtonsEnabled:NO];
    [self animateMainMenuButtonDeselect:^{
        [self.delegate pausedViewViewDidSelectButtonType:PausedViewViewButtonTypeMainMenu];
    }];
}

#pragma mark - UI Helpers

-(void)configureButtonsEnabled:(BOOL)enabled {
    self.playPausedButton.userInteractionEnabled = self.mainMenuButton.userInteractionEnabled = enabled;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
