//
//  ViewController.h
//  ABIMSIM
//

//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameOverView.h"
#import "PausedView.h"
#import "SettingsView.h"
#import "UIView+Screenshot.h"
#import "UIImage+Effects.h"

@class GameScene;
@class DCRoundSwitch;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate, GameOverViewDelegate, PausedViewDelegate, SettingsViewDelegate>

#pragma mark - Main Menu

@property (weak, nonatomic) IBOutlet UIView *mainMenuView;
@property (weak, nonatomic) IBOutlet UIImageView *playRing0;
@property (weak, nonatomic) IBOutlet UIImageView *playRing1;
@property (weak, nonatomic) IBOutlet UIImageView *playRing2;
@property (weak, nonatomic) IBOutlet UIImageView *playRing3;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIImageView *hsRing0;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing1;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing2;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing3;
@property (weak, nonatomic) IBOutlet UIButton *highScoreButton;

@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing0;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing1;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing2;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing3;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;

@property (weak, nonatomic) IBOutlet UIButton *hamburgerButton;
@property (weak, nonatomic) IBOutlet UIButton *creditsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hamburgerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hamburgerBottomConstraint;
@property (strong, nonatomic) GameScene *scene;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;

- (IBAction)playSelect:(id)sender;
- (IBAction)playDeselect:(id)sender;
- (IBAction)playTouchUpInside:(id)sender;

- (IBAction)highScoresSelect:(id)sender;
- (IBAction)highScoresDeselect:(id)sender;
- (IBAction)highScoresTouchUpInside:(id)sender;

- (IBAction)upgradesSelect:(id)sender;
- (IBAction)upgradesDeselect:(id)sender;
- (IBAction)upgradesTouchUpInside:(id)sender;

- (IBAction)hamburgerTapped:(id)sender;


#pragma mark - Settings
@property (weak, nonatomic) IBOutlet SettingsView *settingsView;
@property (weak, nonatomic) IBOutlet UIView *settingsContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsContainerTopAlignmentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsContainerTrailingConstraint;

#pragma mark - Paused
@property (weak, nonatomic) IBOutlet PausedView *pausedView;

#pragma mark - Game Over
@property (weak, nonatomic) IBOutlet GameOverView *gameOverView;

#pragma mark - Game Play
- (IBAction)pauseButtonTapped:(id)sender;

-(void)showGameOverView;
-(void)showPausedView;
@end