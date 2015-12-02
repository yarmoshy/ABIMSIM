//
//  MyScene.h
//  ABIMSIM
//

//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Social/Social.h>
#import "ViewController.h"


@interface GameScene : SKScene <SKPhysicsContactDelegate, RPPreviewViewControllerDelegate, RPScreenRecorderDelegate>
@property (strong, nonatomic) ViewController *viewController;
@property (assign, nonatomic) BOOL reset;
@property (assign, nonatomic) BOOL initialPause;
@property (assign, nonatomic) BOOL resuming;
@property (assign, nonatomic) BOOL transitioningToMenu;
@property (assign, nonatomic) BOOL gameOver;
@property (assign, nonatomic) int currentLevel;
@property (assign, nonatomic) int bubblesPopped;
@property (assign, nonatomic) int sunsSurvived;
@property (assign, nonatomic) int blackHolesSurvived;

-(void)transitionFromMainMenu;
-(void)pause;
-(void)setDefaultValues;
-(void)configureGestureRecognizers:(BOOL)enabled;
-(void)startShipVelocity;
-(BOOL)previewIsAvailable;
-(void)showPreview;
@end
