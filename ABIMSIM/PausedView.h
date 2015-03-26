//
//  PausedView.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/23/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DCRoundSwitch, GameScene;

typedef enum {
    PausedViewViewButtonTypePlay,
    PausedViewViewButtonTypeMainMenu
} PausedViewViewButtonType;

@protocol PausedViewDelegate

@property (strong, nonatomic) GameScene *scene;

-(void)pausedViewViewDidSelectButtonType:(PausedViewViewButtonType)type;

@end

@interface PausedView : UIView
@property (weak, nonatomic) id<PausedViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *playPausedRing0;
@property (weak, nonatomic) IBOutlet UIImageView *playPausedRing1;
@property (weak, nonatomic) IBOutlet UIImageView *playPausedRing2;
@property (weak, nonatomic) IBOutlet UIImageView *playPausedRing3;
@property (weak, nonatomic) IBOutlet UIButton *playPausedButton;

@property (weak, nonatomic) IBOutlet UIImageView *mmRing0;
@property (weak, nonatomic) IBOutlet UIImageView *mmRing1;
@property (weak, nonatomic) IBOutlet UIImageView *mmRing2;
@property (weak, nonatomic) IBOutlet UIImageView *mmRing3;
@property (weak, nonatomic) IBOutlet UIButton *mainMenuButton;

@property (weak, nonatomic) IBOutlet DCRoundSwitch *musicPausedSwitch;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *sfxPausedSwitch;

- (IBAction)playPausedSelect:(id)sender;
- (IBAction)playPausedDeselect:(id)sender;
- (IBAction)playPausedTouchUpInside:(id)sender;

- (IBAction)mainMenuSelect:(id)sender;
- (IBAction)mainMenuDeselect:(id)sender;
- (IBAction)mainMenuTouchUpInside:(id)sender;

-(void)configureButtonsEnabled:(BOOL)enabled;
-(void)musicSwitchToggled:(DCRoundSwitch*)toggle;
-(void)sfxSwitchToggled:(DCRoundSwitch*)toggle;
@end
