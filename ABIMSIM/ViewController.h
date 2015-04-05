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
#import "UpgradesView.h"
#import "UIView+Screenshot.h"
#import "UIImage+Effects.h"

@class GameScene;
@class DCRoundSwitch;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate, GameOverViewDelegate, PausedViewDelegate, SettingsViewDelegate, MainMenuViewDelegate, UpgradesViewDelegate>

@property (strong, nonatomic) GameScene *scene;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (weak, nonatomic) MainMenuView *mainMenuView;
@property (weak, nonatomic) SettingsView *settingsView;
@property (weak, nonatomic) PausedView *pausedView;
@property (weak, nonatomic) GameOverView *gameOverView;
@property (weak, nonatomic) UpgradesView *upgradesView;


#pragma mark - Game Play
- (IBAction)pauseButtonTapped:(id)sender;

-(void)showGameOverView;
-(void)showPausedView;
@end