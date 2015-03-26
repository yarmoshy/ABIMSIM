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
#import "MainMenuView.h"
#import "UIView+Screenshot.h"
#import "UIImage+Effects.h"

@class GameScene;
@class DCRoundSwitch;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate, GameOverViewDelegate, PausedViewDelegate, SettingsViewDelegate, MainMenuViewDelegate>

@property (strong, nonatomic) GameScene *scene;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

#pragma mark - Main Menu

@property (weak, nonatomic) IBOutlet MainMenuView *mainMenuView;

#pragma mark - Settings
@property (weak, nonatomic) IBOutlet SettingsView *settingsView;

#pragma mark - Paused
@property (weak, nonatomic) IBOutlet PausedView *pausedView;

#pragma mark - Game Over
@property (weak, nonatomic) IBOutlet GameOverView *gameOverView;

#pragma mark - Game Play
- (IBAction)pauseButtonTapped:(id)sender;

-(void)showGameOverView;
-(void)showPausedView;
@end