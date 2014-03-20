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


#define MAX_VELOCITY 300
#define MIN_VELOCITY 300
#define MAX_ANGULAR_VELOCITY 1


#define starScaleLarge 1
#define starScaleMedium 0.65
#define starScaleSmall 0.4

#define starColorA @"ec52ea"
#define starColorB @"3eaabd"
#define starColorC @"ffffff"

#define asteroidColorBlue @"2eb0ce"
#define asteroidColorGreen @"6ecc32"
#define asteroidColorOrange @"d65e34"
#define asteroidColorBrownish @"c69b30"
#define asteroidColorYella @"dbdb0b"
#define asteroidColorPurple @"9e3dd1"

#import "MyScene.h"
#import "HexColor.h"

@implementation MyScene {
    NSMutableArray *bumperSpritesArrays;
    NSMutableArray *starSprites;
    NSMutableArray *currentBumperSpriteArray;
    NSNumber *safeToTransition;
    int currentLevel;
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
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        background.anchorPoint = CGPointZero;
        [self addChild:background];

        SKSpriteNode *ship = [SKSpriteNode spriteNodeWithImageNamed:@"Ship"];
        ship.name = shipCategoryName;
        ship.position = CGPointMake(self.frame.size.width/4, ship.size.height*2);
        ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ship.frame.size.width/2];
        ship.physicsBody.friction = 0.0f;
        ship.physicsBody.restitution = 1.0f;
        ship.physicsBody.linearDamping = 0.0f;
        ship.physicsBody.allowsRotation = NO;
        ship.physicsBody.categoryBitMask = shipCategory;
        ship.physicsBody.collisionBitMask = bumperCategory;
        ship.physicsBody.contactTestBitMask = goalCategory;
        ship.physicsBody.mass = ship.frame.size.width;

        bumperSpritesArrays = [NSMutableArray array];
        currentBumperSpriteArray = [NSMutableArray array];
        [self transitionStars];
        [self addChild:ship];
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

#pragma mark - Touch Handling

-(void)handlePanGesture:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
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
    SKNode* ball = [self childNodeWithName: shipCategoryName];
    static int maxSpeed = MAX_VELOCITY;
    float speed = sqrt(ball.physicsBody.velocity.dx*ball.physicsBody.velocity.dx + ball.physicsBody.velocity.dy * ball.physicsBody.velocity.dy);
    if (speed > maxSpeed) {
        ball.physicsBody.linearDamping = 0.4f;
    } else {
        ball.physicsBody.linearDamping = 0.0f;
    }
    for (SKSpriteNode *asteroid in currentBumperSpriteArray) {
        if (fabs(asteroid.physicsBody.angularVelocity) > MAX_ANGULAR_VELOCITY) {
            asteroid.physicsBody.angularDamping = 1.0f;
        } else {
            asteroid.physicsBody.angularDamping = 0.0f;
        }
        float speed = sqrt(asteroid.physicsBody.velocity.dx*asteroid.physicsBody.velocity.dx + asteroid.physicsBody.velocity.dy * asteroid.physicsBody.velocity.dy);
        if (speed > maxSpeed) {
            asteroid.physicsBody.linearDamping = 0.4f;
        } else {
            asteroid.physicsBody.linearDamping = 0.0f;
        }

    }
}


#pragma mark - Collisions and Contacts

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
                    [self transitionStars];
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

#pragma mark - Level generation

-(void)transitionStars {
    if (!starSprites) {
        starSprites = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"LargeStar"];
            [starSprites addObject:star];
            float x = arc4random() % (int)self.frame.size.width * 1;
            float y = arc4random() % (int)self.frame.size.height * 1;
            star.position = CGPointMake(x, y);
            int size = arc4random() % 3;
            switch (size) {
                case 0:
                    star.yScale = star.xScale = starScaleSmall;
                    break;
                case 1:
                    star.yScale = star.xScale = starScaleMedium;
                    break;
                case 2:
                    star.yScale = star.xScale = starScaleLarge;
                    break;

                default:
                    break;
            }
            int color = arc4random() % 3;
            switch (color) {
                case 0:
                    star.color = [UIColor colorWithHexString:starColorA];
                    break;
                case 1:
                    star.color = [UIColor colorWithHexString:starColorB];
                    break;
                case 2:
                    star.color = [UIColor colorWithHexString:starColorC];
                    break;
  
                default:
                    break;
            }
            star.colorBlendFactor = 1.0;
            [self addChild:star];
        }
        for (int i = 0; i < 10; i++) {
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"LargeStar"];
            [starSprites addObject:star];
            star.xScale = star.yScale = 0;
            [self addChild:star];
        }
    } else {
        for (SKSpriteNode *star in starSprites) {
            float x = arc4random() % (int)self.frame.size.width * 1;
            float y = arc4random() % (int)self.frame.size.height * 1;
            float scale = 0;
            if (star.yScale == 0) {
                star.position = CGPointMake(x, y);
                int size = arc4random() % 3;
                switch (size) {
                    case 0:
                        scale = starScaleSmall;
                        break;
                    case 1:
                        scale = starScaleMedium;
                        break;
                    case 2:
                        scale = starScaleLarge;
                        break;
                    default:
                        break;
                }
                int colorInt = arc4random() % 3;
                switch (colorInt) {
                    case 0:
                        star.color = [UIColor colorWithHexString:starColorA];
                        break;
                    case 1:
                        star.color = [UIColor colorWithHexString:starColorB];
                        break;
                    case 2:
                        star.color = [UIColor colorWithHexString:starColorC];
                        break;
                    default:
                        break;
                }
                [star runAction:[SKAction scaleTo:scale duration:0.5]];
            } else {
                [star runAction:[SKAction scaleTo:0 duration:0.5]];
            }
        }
    }
    
}

-(void)generateInitialLevels {
    BOOL endAtTop = YES;
    for (int i = 0; i < 10; i++) {
        NSMutableArray *bumperArray = [NSMutableArray array];
        for (int j = 0; j <= i; j++) {
            int asteroidNum = 12;// arc4random() % 12;
            NSString *imageName = [NSString stringWithFormat:@"Asteroid_%d",asteroidNum];
            SKSpriteNode *bumper = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            bumper.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForAsteroidNum:asteroidNum withSprite:bumper]];
            bumper.physicsBody.friction = 0.0f;
            bumper.physicsBody.restitution = 1.0f;
            bumper.physicsBody.linearDamping = 0.0f;
            bumper.physicsBody.dynamic = YES;
            bumper.physicsBody.categoryBitMask = bumperCategory;
            bumper.physicsBody.collisionBitMask = shipCategory | bumperCategory;
            bumper.physicsBody.mass = bumper.size.width;
            bumper.name = bumperCategoryName;
            bumper.physicsBody.allowsRotation = YES;
            int colorInt = arc4random() % 6;
            switch (colorInt) {
                case 0:
                    bumper.color = [UIColor colorWithHexString:asteroidColorBlue];
                    break;
                case 1:
                    bumper.color = [UIColor colorWithHexString:asteroidColorBrownish];
                    break;
                case 2:
                    bumper.color = [UIColor colorWithHexString:asteroidColorGreen];
                    break;
                case 3:
                    bumper.color = [UIColor colorWithHexString:asteroidColorOrange];
                    break;
                case 4:
                    bumper.color = [UIColor colorWithHexString:asteroidColorPurple];
                    break;
                case 5:
                    bumper.color = [UIColor colorWithHexString:asteroidColorYella];
                    break;
                default:
                    break;
            }
            bumper.colorBlendFactor = 1.0;
            [self randomizeSprite:bumper];
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
        if ([sprite.name isEqual:bumperCategoryName]) {
           [self randomizeSprite:sprite];
        }
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

-(SKSpriteNode*)randomizeSprite:(SKSpriteNode*)sprite {
    float x = arc4random() % (int)self.frame.size.width * 1;
    float maxHeight = self.frame.size.height - ([self childNodeWithName:shipCategoryName].frame.size.height*2) - (sprite.size.height*2);
    float y = (arc4random() % ((int)maxHeight)) + [self childNodeWithName:shipCategoryName].frame.size.height + sprite.size.height;
    sprite.position = CGPointMake(x, y);
    sprite.zRotation = DegreesToRadians(arc4random() % 360);
    float velocity = arc4random() % (MAX_VELOCITY/2);
    sprite.physicsBody.velocity = CGVectorMake(velocity * cosf(sprite.zRotation), velocity * -sinf(sprite.zRotation));
    return sprite;
}


-(CGMutablePathRef)pathForAsteroidNum:(int)asteroidNum withSprite:(SKSpriteNode*)sprite {
    CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
    CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();

    switch (asteroidNum) {
        case 0: {
            CGPathMoveToPoint(path, NULL, 4 - offsetX, 15 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 13 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 9 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 1 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 14 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 14 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 11 - offsetX, 14 - offsetY);
        }
            break;
        case 1:{
            CGPathMoveToPoint(path, NULL, 4 - offsetX, 14 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 1 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 11 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 14 - offsetX, 1 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 13 - offsetX, 14 - offsetY);
        }
            break;
        case 2: {
            CGPathMoveToPoint(path, NULL, 0 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 8 - offsetX, 15 - offsetY);
            CGPathAddLineToPoint(path, NULL, 14 - offsetX, 14 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 12 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 13 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 2 - offsetY);
        }
            break;
        case 3: {
            CGPathMoveToPoint(path, NULL, 3 - offsetX, 21 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 18 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 1 - offsetY);
            CGPathAddLineToPoint(path, NULL, 8 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 14 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 18 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 21 - offsetY);
        }
            break;
        case 4: {
            CGPathMoveToPoint(path, NULL, 8 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 1 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 25 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 24 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 22 - offsetX, 22 - offsetY);
        }
            break;
        case 5: {
            CGPathMoveToPoint(path, NULL, 3 - offsetX, 17 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 11 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 25 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 17 - offsetY);
            CGPathAddLineToPoint(path, NULL, 23 - offsetX, 19 - offsetY);
        }
            break;
        case 6: {
            CGPathMoveToPoint(path, NULL, 13 - offsetX, 25 - offsetY);
            CGPathAddLineToPoint(path, NULL, 7 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 13 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 7 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 22 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 24 - offsetX, 13 - offsetY);
            CGPathAddLineToPoint(path, NULL, 24 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 24 - offsetY);
        }
            break;
        case 7: {
            CGPathMoveToPoint(path, NULL, 10 - offsetX, 22 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 13 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 10 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 25 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 15 - offsetY);
            CGPathAddLineToPoint(path, NULL, 25 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 21 - offsetY);
        }
            break;
        case 8: {
            CGPathMoveToPoint(path, NULL, 11 - offsetX, 31 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 21 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 9 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 20 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 23 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 24 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 25 - offsetX, 18 - offsetY);
            CGPathAddLineToPoint(path, NULL, 25 - offsetX, 21 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 29 - offsetY);
        }
            break;
        case 9: {
            CGPathMoveToPoint(path, NULL, 8 - offsetX, 26 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 24 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 6 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 11 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 19 - offsetX, 26 - offsetY);
        }
            break;
        case 10: {
            CGPathMoveToPoint(path, NULL, 9 - offsetX, 29 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 19 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 25 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 30 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 30 - offsetX, 18 - offsetY);
            CGPathAddLineToPoint(path, NULL, 24 - offsetX, 27 - offsetY);
        }
            break;
        case 11: {
            CGPathMoveToPoint(path, NULL, 14 - offsetX, 32 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 27 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 18 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 21 - offsetX, 0 - offsetY);
            CGPathAddLineToPoint(path, NULL, 30 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 32 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 32 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 25 - offsetX, 30 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 32 - offsetY);
        }
            break;
        case 12: {
            CGPathMoveToPoint(path, NULL, 18 - offsetX, 36 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 32 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 24 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 6 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 10 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 33 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 36 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 34 - offsetX, 28 - offsetY);
            CGPathAddLineToPoint(path, NULL, 27 - offsetX, 35 - offsetY);
        }
            break;
        default:
            break;
    }
    
    CGPathCloseSubpath(path);
    return path;
}
@end
