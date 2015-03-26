//
//  MainMenuView.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/25/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameScene;

typedef enum {
    MainMenuViewButtonTypePlay,
    MainMenuViewButtonTypeHighScores,
    MainMenuViewButtonTypeUpgrades
} MainMenuViewButtonType;

@protocol MainMenuViewDelegate

@property (strong, nonatomic) GameScene *scene;

-(void)mainMenuViewDidSelectButtonType:(MainMenuViewButtonType)type;
-(void)showSettings;
-(void)hideSettings;
@end

@interface MainMenuView : UIView
@property (weak, nonatomic) id<MainMenuViewDelegate> delegate;

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

@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;

@property (weak, nonatomic) IBOutlet UIButton *hamburgerButton;
@property (weak, nonatomic) IBOutlet UIButton *creditsButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hamburgerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hamburgerBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *settingsContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsContainerTopAlignmentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsContainerTrailingConstraint;


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
- (void)configureButtonsEnabled:(BOOL)enabled;

@end
