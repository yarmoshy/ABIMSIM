//
//  MyScene.h
//  ABIMSIM
//

//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate, GKGameCenterControllerDelegate>
@property (strong, nonatomic) UIViewController *viewController;

@end
