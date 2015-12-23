//
//  GameOverView.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/23/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameScene;

typedef enum {
    GameOverViewButtonTypePlay,
    GameOverViewButtonTypeMainMenu,
    GameOverViewButtonTypeUpgrades,
    GameOverViewButtonTypeHighScores
} GameOverViewButtonType;

@protocol GameOverViewDelegate

@property (strong, nonatomic) GameScene *scene;

-(void)gameOverViewDidSelectButtonType:(GameOverViewButtonType)type;
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;

@end


@interface GameOverView : UIView
@property (weak, nonatomic) id<GameOverViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *gameOverLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gameOverLabelHorizonalConstraint;

@property (weak, nonatomic) IBOutlet UILabel *largeParsecsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *largeParsecsLabelYAlignmentConstraint;
@property (weak, nonatomic) IBOutlet UILabel *largeParsecsImage;

@property (weak, nonatomic) IBOutlet UILabel *largeXPLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *largeXPLabelYAlignmentConstraint;
@property (weak, nonatomic) IBOutlet UILabel *largeXPImage;

@property (weak, nonatomic) IBOutlet UILabel *bonusImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusImageTopConstraint;

@property (weak, nonatomic) IBOutlet UILabel *bonusLabelOne;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusBubbleOneTopConstraint;

@property (weak, nonatomic) IBOutlet UILabel *bonusLabelTwo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusBubbleTwoTopConstraint;

@property (weak, nonatomic) IBOutlet UILabel *bonusLabelThree;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusBubbleThreeTopConstraint;

@property (weak, nonatomic) IBOutlet UILabel *bonusLabelFour;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusBubbleFourTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rectangleImageHorizontalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rectangleImageYConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *rectangleImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rectangleImageWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *rectangleSocialImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rectangleSocialImageWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *smallParsecsImage;
@property (weak, nonatomic) IBOutlet UILabel *smallParsecsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smallParsecsLabelHorizonalConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *smallXPImage;
@property (weak, nonatomic) IBOutlet UILabel *smallXPLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smallXPLabelHorizonalConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *verticalDivider;
@property (weak, nonatomic) IBOutlet UIImageView *horizontalDivider;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (weak, nonatomic) IBOutlet UIButton *editReplayButton;

@property (weak, nonatomic) IBOutlet UIView *gameOverButtonContainer;

@property (weak, nonatomic) IBOutlet UIButton *ggPlayButton;
@property (weak, nonatomic) IBOutlet UIImageView *ggPlayRing0;
@property (weak, nonatomic) IBOutlet UIImageView *ggPlayRing1;
@property (weak, nonatomic) IBOutlet UIImageView *ggPlayRing2;
@property (weak, nonatomic) IBOutlet UIImageView *ggPlayRing3;

@property (weak, nonatomic) IBOutlet UIButton *ggMainMenuButton;
@property (weak, nonatomic) IBOutlet UIImageView *ggMMRing0;
@property (weak, nonatomic) IBOutlet UIImageView *ggMMRing1;
@property (weak, nonatomic) IBOutlet UIImageView *ggMMRing2;
@property (weak, nonatomic) IBOutlet UIImageView *ggMMRing3;

@property (weak, nonatomic) IBOutlet UIButton *ggUpgradeButton;
@property (weak, nonatomic) IBOutlet UIImageView *ggUpgradeRing0;
@property (weak, nonatomic) IBOutlet UIImageView *ggUpgradeRing1;
@property (weak, nonatomic) IBOutlet UIImageView *ggUpgradeRing2;
@property (weak, nonatomic) IBOutlet UIImageView *ggUpgradeRing3;

@property (weak, nonatomic) IBOutlet UILabel *upgradesAvailableLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gameOverContainerYAlignConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gameOverLabelTopConstraint;
- (IBAction)ggPlaySelect:(id)sender;
- (IBAction)ggPlayDeselect:(id)sender;
- (IBAction)ggPlayTouchUpInside:(id)sender;

- (IBAction)ggMainMenuSelect:(id)sender;
- (IBAction)ggMainMenuDeselect:(id)sender;
- (IBAction)ggMainMenuTouchUpInside:(id)sender;

- (IBAction)ggUpgradeSelect:(id)sender;
- (IBAction)ggUpgradeDeselect:(id)sender;
- (IBAction)ggUpgradeTouchUpInside:(id)sender;

- (IBAction)facebookTapped:(id)sender;
- (IBAction)twitterTapped:(id)sender;
- (IBAction)editReplayButtonTapped:(id)sender;
- (IBAction)quitTapped:(id)sender;

-(void)show;
-(void)hide;
-(void)showSocialButtons;
-(void)configureButtonsEnabled:(BOOL)enabled;
@end
