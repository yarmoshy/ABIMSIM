//
//  MyScene.h
//  ABIMSIM
//

//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Social/Social.h>
#import "ViewController.h"

@interface GameScene : SKScene <SKPhysicsContactDelegate, GKGameCenterControllerDelegate>
@property (strong, nonatomic) ViewController *viewController;
@property (assign, nonatomic) BOOL reset;

-(void)transitionFromMainMenu;

@end
