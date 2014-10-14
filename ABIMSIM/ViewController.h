//
//  ViewController.h
//  ABIMSIM
//

//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
@class GameScene;

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *mainMenuView;
@property (weak, nonatomic) IBOutlet UIImageView *playRing0;
@property (weak, nonatomic) IBOutlet UIImageView *playRing1;
@property (weak, nonatomic) IBOutlet UIImageView *playRing2;
@property (weak, nonatomic) IBOutlet UIImageView *playRing3;

@property (weak, nonatomic) IBOutlet UIImageView *hsRing0;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing1;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing2;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing3;

@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing0;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing1;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing2;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing3;

@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (strong, nonatomic) GameScene *scene;

- (IBAction)playSelect:(id)sender;
- (IBAction)playDeselect:(id)sender;
- (IBAction)playTouchUpInside:(id)sender;

- (IBAction)highScoresSelect:(id)sender;
- (IBAction)highScoresDeselect:(id)sender;
- (IBAction)highScoresTouchUpInside:(id)sender;

- (IBAction)upgradesSelect:(id)sender;
- (IBAction)upgradesDeselect:(id)sender;
- (IBAction)upgradesTouchUpInside:(id)sender;
-(void)showGameOverView;
@end
