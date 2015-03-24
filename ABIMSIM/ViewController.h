//
//  ViewController.h
//  ABIMSIM
//

//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameOverView.h"
#import "UIView+Screenshot.h"
#import "UIImage+Effects.h"

@class GameScene;
@class DCRoundSwitch;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate, GameOverViewDelegate>

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
@property (weak, nonatomic) IBOutlet UIView *settingsContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsContainerTopAlignmentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsContainerTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLeadngConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTopConstraint;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *musicSettingsToggle;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *sfxSettingsToggle;

- (IBAction)twitterTapped:(id)sender;
- (IBAction)facebookTapped:(id)sender;
- (IBAction)resetTapped:(id)sender;

#pragma mark - Paused
@property (weak, nonatomic) IBOutlet UIView *pausedView;
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

#pragma mark - Game Over
@property (weak, nonatomic) IBOutlet GameOverView *gameOverView;

#pragma mark - Game Play
- (IBAction)pauseButtonTapped:(id)sender;

-(void)showGameOverView;
-(void)showPausedView;
@end


@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

