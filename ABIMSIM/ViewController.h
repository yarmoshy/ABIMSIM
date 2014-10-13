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



@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (strong, nonatomic) GameScene *scene;

- (IBAction)playSelect:(id)sender;
- (IBAction)playDeselect:(id)sender;

- (IBAction)playTouchUpInside:(id)sender;


- (IBAction)highScoresTapped:(id)sender;
- (IBAction)upgradesTapped:(id)sender;

-(void)showGameOverView;
@end
