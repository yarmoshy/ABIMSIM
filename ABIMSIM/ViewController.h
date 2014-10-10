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
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (strong, nonatomic) GameScene *scene;

-(void)showGameOverView;
@end
