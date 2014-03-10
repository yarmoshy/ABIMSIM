//
//  MyScene.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/5/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//
static NSString* shipCategoryName = @"ship";
static NSString* bumperCategoryName = @"bumper";
static NSString* lazerCategoryName = @"lazer";
static NSString* goalCategoryName = @"goal";

static const uint32_t shipCategory  = 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t bumperCategory = 0x1 << 1; // 00000000000000000000000000000010
static const uint32_t lazerCategory = 0x1 << 2;  // 00000000000000000000000000000100
static const uint32_t goalCategory = 0x1 << 3; // 00000000000000000000000000001000


#define MAX_VELOCITY 500
#define MIN_VELOCITY 100

#import "MyScene.h"

@implementation MyScene {
    NSMutableArray *bumperSpritesArrays;
    NSMutableArray *currentBumperSpriteArray;
}

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * (M_PI / 180);
};


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        
        SKSpriteNode *ship = [SKSpriteNode spriteNodeWithImageNamed:@"Ship"];
        ship.name = shipCategoryName;
        ship.position = CGPointMake(self.frame.size.width/4, ship.size.height*2);
        [self addChild:ship];
        ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ship.frame.size.width/2];
        ship.physicsBody.friction = 0.0f;
        ship.physicsBody.restitution = 1.0f;
        ship.physicsBody.linearDamping = 0.0f;
        ship.physicsBody.allowsRotation = NO;
        ship.physicsBody.categoryBitMask = shipCategory;
        ship.physicsBody.collisionBitMask = bumperCategory;
        
        bumperSpritesArrays = [NSMutableArray array];
        currentBumperSpriteArray = [NSMutableArray array];
        [self generateInitialLevels];
        for (SKSpriteNode *bumper in currentBumperSpriteArray) {
            bumper.hidden = NO;
            [self addChild:bumper];
        }
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:recognizer];
}

-(void)handlePanGesture:(UIPanGestureRecognizer*)recognizer {
    CGPoint addVelocity = [recognizer velocityInView:recognizer.view];
    CGPoint newVelocity = addVelocity;
    float velocity = sqrtf(powf(newVelocity.x, 2) + powf(newVelocity.y, 2));
    if (velocity > MAX_VELOCITY) {
        newVelocity.x = MAX_VELOCITY * ( newVelocity.x / velocity );
        newVelocity.y = MAX_VELOCITY * ( newVelocity.y / velocity );
    } else if (velocity <MIN_VELOCITY ) {
        newVelocity.x = MIN_VELOCITY * ( newVelocity.x / velocity );
        newVelocity.y = MIN_VELOCITY * ( newVelocity.y / velocity );
    }
    [self childNodeWithName:shipCategoryName].physicsBody.velocity = CGVectorMake(newVelocity.x, -newVelocity.y);
}

-(void)generateInitialLevels {
    for (int i = 1; i >= 0; i--) {
        NSMutableArray *bumperArray = [NSMutableArray array];
        SKSpriteNode *bumper = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(50, 50)];
        bumper.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bumper.size];
        bumper.physicsBody.friction = 0.0f;
        bumper.physicsBody.dynamic = NO;
        bumper.physicsBody.categoryBitMask = bumperCategory;
        bumper.physicsBody.collisionBitMask = shipCategory;
        bumper.name = bumperCategoryName;
        float x = arc4random() % (int)self.frame.size.width * 1;
        float y = arc4random() % (int)self.frame.size.height * 1;
        bumper.position = CGPointMake(x, y);
        bumper.zRotation = DegreesToRadians(arc4random() % 360);
        bumper.hidden = YES;
        [bumperArray addObject:bumper];
        [bumperSpritesArrays addObject:bumperArray];
    }
    currentBumperSpriteArray = [bumperSpritesArrays lastObject];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
