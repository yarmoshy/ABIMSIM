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
    NSNumber *safeToTransition;
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
        self.physicsWorld.contactDelegate = self;

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
        ship.physicsBody.contactTestBitMask = goalCategory;
        bumperSpritesArrays = [NSMutableArray array];
        currentBumperSpriteArray = [NSMutableArray array];
        [self generateInitialLevels];
        safeToTransition = @YES;
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


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

- (void)didBeginContact:(SKPhysicsContact*)contact {
    // 1 Create local variables for two physics bodies
    @synchronized (safeToTransition) {
        SKPhysicsBody* firstBody;
        SKPhysicsBody* secondBody;
        // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        } else {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == goalCategory) {
            if ([safeToTransition isEqualToNumber:@YES]) {
                safeToTransition = @NO;
                [secondBody.node removeFromParent];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self advanceToNextLevel];
                });
            }
        }
    }
}

-(void)didEndContact:(SKPhysicsContact *)contact {
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == goalCategory) {
//        safeToTransition = YES;
    }
}

-(void)generateInitialLevels {
    BOOL endAtTop = YES;
    for (int i = 0; i < 10; i++) {
        NSMutableArray *bumperArray = [NSMutableArray array];
        for (int j = 0; j <= i; j++) {
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
        }
        CGRect goalRect;
        if (endAtTop) {
            goalRect = CGRectMake(self.frame.origin.x, self.frame.size.height, self.frame.size.width, 1);
        } else {
            goalRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        }
        SKNode* goal = [SKNode node];
        goal.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:goalRect];
        goal.name = goalCategoryName;
        goal.physicsBody.categoryBitMask = goalCategory;
        [bumperArray addObject:goal];
        
        [bumperSpritesArrays addObject:bumperArray];
        endAtTop = !endAtTop;
    }
    currentBumperSpriteArray = [bumperSpritesArrays firstObject];
    [self showCurrentSprites];
}

-(void)advanceToNextLevel {
    for (SKSpriteNode *sprite in currentBumperSpriteArray) {
        [sprite removeFromParent];
    }
    [bumperSpritesArrays addObject:bumperSpritesArrays[0]];
    [bumperSpritesArrays removeObjectAtIndex:0];
    currentBumperSpriteArray = bumperSpritesArrays[0];
    [self showCurrentSprites];
    safeToTransition = @YES;
}

-(void)showCurrentSprites {
    for (SKSpriteNode *sprite in currentBumperSpriteArray) {
        if ([sprite.name isEqual:bumperCategoryName]) {
            sprite.hidden = NO;
            [self addChild:sprite];
        } else if ([sprite.name isEqual:goalCategoryName]) {
            [self addChild:sprite];
        }
    }
}
@end
