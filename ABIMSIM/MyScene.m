//
//  MyScene.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/5/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//
static NSString* shipCategoryName = @"ship";
static NSString* asteroidCategoryName = @"asteroid";
static NSString* planetCategoryName = @"planet";
static NSString* goalCategoryName = @"goal";

static const uint32_t borderCategory  = 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t shipCategory  = 0x1 << 1;  // 00000000000000000000000000000001
static const uint32_t asteroidCategory = 0x1 << 2; // 00000000000000000000000000000010
static const uint32_t planetCategory = 0x1 << 3;  // 00000000000000000000000000000100
static const uint32_t goalCategory = 0x1 << 4; // 00000000000000000000000000001000


#define MAX_VELOCITY 300
#define MIN_VELOCITY 300
#define MAX_ANGULAR_VELOCITY 1

#define starBackMovement 1.2
#define starFrontMovement 1.4

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


#define orbitJoint @"orbitJoint"
#define moonsArray @"moonsArray"

#import "MyScene.h"
#import "HexColor.h"

@implementation MyScene {
    NSMutableArray *spritesArrays;
    NSMutableArray *starSprites;
    NSMutableArray *currentSpriteArray;
    NSNumber *safeToTransition;
    SKSpriteNode *starBackLayer;
    SKSpriteNode *starFrontLayer;
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
        borderBody.categoryBitMask = borderCategory;
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        self.physicsWorld.contactDelegate = self;
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        background.anchorPoint = CGPointZero;
        [self addChild:background];

        starBackLayer = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height * starBackMovement)];
        starFrontLayer = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height * starFrontMovement)];
        starFrontLayer.anchorPoint = CGPointZero;
        starBackLayer.anchorPoint = CGPointZero;
        starBackLayer.position = starFrontLayer.position = CGPointMake(0, 0);
        [self addChild:starBackLayer];
        [self addChild:starFrontLayer];

        SKSpriteNode *ship = [SKSpriteNode spriteNodeWithImageNamed:@"Ship"];
        ship.name = shipCategoryName;
        ship.position = CGPointMake(self.frame.size.width/4, ship.size.height*2);
        ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ship.frame.size.width/2];
        ship.physicsBody.friction = 0.0f;
        ship.physicsBody.restitution = 1.0f;
        ship.physicsBody.linearDamping = 0.0f;
        ship.physicsBody.allowsRotation = NO;
        ship.physicsBody.categoryBitMask = shipCategory;
        ship.physicsBody.collisionBitMask = borderCategory | asteroidCategory | planetCategory;
        ship.physicsBody.contactTestBitMask = goalCategory;
        ship.physicsBody.mass = ship.frame.size.width;

        spritesArrays = [NSMutableArray array];
        currentSpriteArray = [NSMutableArray array];
        
        
        
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
    
    float yPercentageFromCenter = (ball.position.y - (self.view.frame.size.height/2.0))  / (self.view.frame.size.height / 2.0);
    float frontMaxY = ((self.view.frame.size.height * starFrontMovement) - self.view.frame.size.height)/2.0;
    float backMaxY = ((self.view.frame.size.height * starBackMovement) - self.view.frame.size.height)/2.0;
    float frontY = (yPercentageFromCenter * frontMaxY);
    frontY = frontY + (frontMaxY);
    float backY = (yPercentageFromCenter * backMaxY);
    backY = backY + (backMaxY);
    starFrontLayer.position = CGPointMake(starFrontLayer.position.x, -frontY);
    starBackLayer.position = CGPointMake(starBackLayer.position.x, -backY);

    static int maxSpeed = MAX_VELOCITY;
    float speed = sqrt(ball.physicsBody.velocity.dx*ball.physicsBody.velocity.dx + ball.physicsBody.velocity.dy * ball.physicsBody.velocity.dy);
    if (speed > maxSpeed) {
        ball.physicsBody.linearDamping = 0.4f;
    } else {
        ball.physicsBody.linearDamping = 0.0f;
    }
    for (SKSpriteNode *asteroid in currentSpriteArray) {
        if (![asteroid.name isEqualToString:asteroidCategoryName]) {
            continue;
        }
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
        for (int i = 0; i < 12; i++) {
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"LargeStar"];
            [starSprites addObject:star];
            float x = arc4random() % (int)self.frame.size.width * 1;
            float y;
            if (i < 6) {
                y = arc4random() % (int)(self.frame.size.height * starBackMovement * 1);
            } else {
                y = arc4random() % (int)(self.frame.size.height * starFrontMovement * 1);
            }
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
            int color = i % 3;
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
            if (i < 6) {
                [starBackLayer addChild:star];
            } else {
                [starFrontLayer addChild:star];
            }
        }
        for (int i = 0; i < 12; i++) {
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"LargeStar"];
            [starSprites addObject:star];
            star.xScale = star.yScale = 0;
            star.colorBlendFactor = 1.0;
            if (i < 6) {
                [starBackLayer addChild:star];
            } else {
                [starFrontLayer addChild:star];
            }
        }
    } else {
        int i = 0;
        for (SKSpriteNode *star in starSprites) {
            float x = arc4random() % (int)self.frame.size.width * 1;
            float y;
            if (i < 6) {
                y = arc4random() % (int)(self.frame.size.height * starBackMovement * 1);
            } else {
                y = arc4random() % (int)(self.frame.size.height * starFrontMovement * 1);
            }
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
                int colorInt = i % 3;
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
            i++;
        }
    }
    
}

-(void)generateInitialLevels {
    BOOL endAtTop = YES;
    for (int i = 0; i < 10; i++) {
        NSMutableArray *spriteArray = [NSMutableArray array];
        for (int j = 0; j <= i; j++) {
            SKSpriteNode *asteroid = [self randomAsteroid];
            [self randomizeSprite:asteroid];
            asteroid.hidden = YES;
            [spriteArray addObject:asteroid];
        }
        SKSpriteNode *planet = [self randomPlanet];
        planet.hidden = YES;
        [spriteArray addObject:planet];
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
        [spriteArray addObject:goal];
        
        [spritesArrays addObject:spriteArray];
        endAtTop = !endAtTop;
    }
    currentSpriteArray = [spritesArrays firstObject];
    [self showCurrentSprites];
}

-(void)advanceToNextLevel {
    for (int i = 0; i < currentSpriteArray.count; i++) {
        if ([[currentSpriteArray[i] name] isEqual:asteroidCategoryName]) {
            [currentSpriteArray[i] removeFromParent];
            currentSpriteArray[i] = [self randomAsteroid];
            [self randomizeSprite:currentSpriteArray[i]];
            [currentSpriteArray[i] setHidden:YES];
        }if ([[currentSpriteArray[i] name] isEqual:planetCategoryName]) {
            [currentSpriteArray[i] removeFromParent];
            for (SKSpriteNode *moon in ((SKSpriteNode*)currentSpriteArray[i]).userData[moonsArray]) {
                [moon removeFromParent];
            }
            currentSpriteArray[i] = [self randomPlanet];
            [currentSpriteArray[i] setHidden:YES];
        }
    }
    [spritesArrays addObject:spritesArrays[0]];
    [spritesArrays removeObjectAtIndex:0];
    currentSpriteArray = spritesArrays[0];
    [self showCurrentSprites];
    safeToTransition = @YES;
}

-(SKSpriteNode*)randomAsteroid {
    int asteroidNum = arc4random() % 12;
    NSString *imageName = [NSString stringWithFormat:@"Asteroid_%d",asteroidNum];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForAsteroidNum:asteroidNum withSprite:sprite]];
    sprite.physicsBody.friction = 0.0f;
    sprite.physicsBody.restitution = 1.0f;
    sprite.physicsBody.linearDamping = 0.0f;
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.categoryBitMask = asteroidCategory;
    sprite.physicsBody.collisionBitMask = borderCategory | shipCategory | asteroidCategory | planetCategory;
    sprite.physicsBody.mass = sprite.size.width;
    sprite.name = asteroidCategoryName;
    sprite.physicsBody.allowsRotation = YES;
    int colorInt = arc4random() % 6;
    switch (colorInt) {
        case 0:
            sprite.color = [UIColor colorWithHexString:asteroidColorBlue];
            break;
        case 1:
            sprite.color = [UIColor colorWithHexString:asteroidColorBrownish];
            break;
        case 2:
            sprite.color = [UIColor colorWithHexString:asteroidColorGreen];
            break;
        case 3:
            sprite.color = [UIColor colorWithHexString:asteroidColorOrange];
            break;
        case 4:
            sprite.color = [UIColor colorWithHexString:asteroidColorPurple];
            break;
        case 5:
            sprite.color = [UIColor colorWithHexString:asteroidColorYella];
            break;
        default:
            break;
    }
    sprite.colorBlendFactor = 1.0;
    return sprite;
}

-(SKSpriteNode*)randomPlanet {
    int planetNum = arc4random() % 1;
    NSString *imageName = [NSString stringWithFormat:@"Planet_%d",planetNum];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:[self radiusForPlanetNum:planetNum]];
    sprite.physicsBody.dynamic = NO;
    sprite.physicsBody.categoryBitMask = planetCategory;
    sprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory | planetCategory;
    sprite.name = planetCategoryName;
    sprite.physicsBody.allowsRotation = NO;
    
    UIBezierPath *hoverPath = [UIBezierPath bezierPath];
	[hoverPath moveToPoint:sprite.position];
	[hoverPath addCurveToPoint:CGPointMake(sprite.position.x + (sprite.size.width * 0.1), sprite.position.y)
				 controlPoint1:CGPointMake(sprite.position.x, sprite.position.y + sprite.size.height * 0.1)
				 controlPoint2:CGPointMake(sprite.position.x + (sprite.size.width * 0.1), sprite.position.y + sprite.size.height * 0.1)];
	[hoverPath addCurveToPoint:sprite.position
				 controlPoint1:CGPointMake(sprite.position.x + (sprite.size.width * 0.1), sprite.position.y - sprite.size.height * 0.1)
				 controlPoint2:CGPointMake(sprite.position.x, sprite.position.y - sprite.size.height * 0.1)];
	[hoverPath addCurveToPoint:CGPointMake(sprite.position.x - (sprite.size.width * 0.1), sprite.position.y)
				 controlPoint1:CGPointMake(sprite.position.x, sprite.position.y + sprite.size.height * 0.1)
				 controlPoint2:CGPointMake(sprite.position.x - (sprite.size.width * 0.1), sprite.position.y + sprite.size.height * 0.1)];
	[hoverPath addCurveToPoint:sprite.position
				 controlPoint1:CGPointMake(sprite.position.x - (sprite.size.width * 0.1), sprite.position.y - sprite.size.height * 0.1)
				 controlPoint2:CGPointMake(sprite.position.x, sprite.position.y - sprite.size.height * 0.1)];

    
    [sprite runAction:[SKAction repeatActionForever:[SKAction followPath:hoverPath.CGPath asOffset:YES orientToPath:NO duration:30]]];
    [self randomizeSprite:sprite];

    sprite.userData = [NSMutableDictionary dictionary];
    sprite.userData[moonsArray] = @[[self moonForPlanetNum:planetNum withPlanet:sprite]];
    return sprite;
}

-(float)radiusForPlanetNum:(int)planetNum {
    switch (planetNum) {
        case 0:
            return 30.f;
            break;
            
        default:
            return 30.f;
            break;
    }
}

-(SKSpriteNode*)moonForPlanetNum:(int)planetNum withPlanet:(SKSpriteNode*)planet {
    NSString *imageName = [NSString stringWithFormat:@"Asteroid_%d",planetNum];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForAsteroidNum:planetNum withSprite:sprite]];
    sprite.physicsBody.friction = 0.0f;
    sprite.physicsBody.restitution = 1.0f;
    sprite.physicsBody.linearDamping = 0.0f;
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.categoryBitMask = asteroidCategory;
    sprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory | planetCategory;
    sprite.physicsBody.mass = sprite.size.width;
    sprite.name = asteroidCategoryName;
    sprite.physicsBody.allowsRotation = YES;
    int colorInt = arc4random() % 6;
    switch (colorInt) {
        case 0:
            sprite.color = [UIColor colorWithHexString:asteroidColorBlue];
            break;
        case 1:
            sprite.color = [UIColor colorWithHexString:asteroidColorBrownish];
            break;
        case 2:
            sprite.color = [UIColor colorWithHexString:asteroidColorGreen];
            break;
        case 3:
            sprite.color = [UIColor colorWithHexString:asteroidColorOrange];
            break;
        case 4:
            sprite.color = [UIColor colorWithHexString:asteroidColorPurple];
            break;
        case 5:
            sprite.color = [UIColor colorWithHexString:asteroidColorYella];
            break;
        default:
            break;
    }
    sprite.colorBlendFactor = 1.0;
    float distance = planet.size.width/2 + sprite.size.width/2;
    float angle = arc4random() % 360;
    sprite.position = CGPointMake(planet.position.x + (cosf(DegreesToRadians(angle)) * distance), planet.position.y + (sinf(DegreesToRadians(angle)) * distance)) ;

    SKPhysicsJointPin *centerPin = [SKPhysicsJointPin jointWithBodyA:sprite.physicsBody bodyB: planet.physicsBody anchor:planet.position];
    sprite.userData = [NSMutableDictionary dictionary];
    sprite.userData[orbitJoint] = centerPin;
    sprite.hidden = YES;
    return sprite;
}

-(void)showCurrentSprites {
    for (SKSpriteNode *sprite in currentSpriteArray) {
        if ([sprite.name isEqual:asteroidCategoryName]) {
            sprite.hidden = NO;
            [self addChild:sprite];
        } else if ([sprite.name isEqual:planetCategoryName]) {
            sprite.hidden = NO;
            [self addChild:sprite];
            for (SKSpriteNode *moon in sprite.userData[moonsArray]) {
                moon.hidden = NO;
                [self addChild:moon];
                [self.physicsWorld addJoint:moon.userData[orbitJoint]];
                moon.physicsBody.angularVelocity = 100;
            }
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
    if ([sprite.name isEqualToString:asteroidCategoryName]) {
        sprite.zRotation = DegreesToRadians(arc4random() % 360);
        float velocity = arc4random() % (MAX_VELOCITY/2);
        sprite.physicsBody.velocity = CGVectorMake(velocity * cosf(sprite.zRotation), velocity * -sinf(sprite.zRotation));
    }
    return sprite;
}


-(CGMutablePathRef)pathForAsteroidNum:(int)asteroidNum withSprite:(SKSpriteNode*)sprite {
    CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
    CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();

    switch (asteroidNum) {
        case 0: {
            CGPathMoveToPoint(path, NULL, 9 - offsetX, 18 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 12 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 6 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 12 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 17 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 18 - offsetY);
        }
            break;
        case 1:{
            CGPathMoveToPoint(path, NULL, 8 - offsetX, 18 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 12 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 8 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 19 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 19 - offsetX, 13 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 18 - offsetY);
        }
            break;
        case 2: {
            CGPathMoveToPoint(path, NULL, 7 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 20 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 20 - offsetX, 15 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 18 - offsetY);
        }
            break;
        case 3: {
            CGPathMoveToPoint(path, NULL, 3 - offsetX, 21 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 12 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 18 - offsetX, 14 - offsetY);
            CGPathAddLineToPoint(path, NULL, 20 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 24 - offsetY);
            CGPathAddLineToPoint(path, NULL, 6 - offsetX, 24 - offsetY);
        }
            break;
        case 4: {
            CGPathMoveToPoint(path, NULL, 5 - offsetX, 22 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 7 - offsetX, 2 - offsetY);
            CGPathAddLineToPoint(path, NULL, 13 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 20 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 30 - offsetX, 9 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 18 - offsetY);
            CGPathAddLineToPoint(path, NULL, 27 - offsetX, 23 - offsetY);
            CGPathAddLineToPoint(path, NULL, 23 - offsetX, 25 - offsetY);
        }
            break;
        case 5: {
            CGPathMoveToPoint(path, NULL, 26 - offsetX, 22 - offsetY);
            CGPathAddLineToPoint(path, NULL, 7 - offsetX, 21 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 9 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 8 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 21 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 30 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 32 - offsetX, 9 - offsetY);
            CGPathAddLineToPoint(path, NULL, 29 - offsetX, 20 - offsetY);
        }
            break;
        case 6: {
            CGPathMoveToPoint(path, NULL, 17 - offsetX, 29 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 17 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 12 - offsetY);
            CGPathAddLineToPoint(path, NULL, 11 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 22 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 27 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 22 - offsetY);
            CGPathAddLineToPoint(path, NULL, 23 - offsetX, 26 - offsetY);
            CGPathAddLineToPoint(path, NULL, 20 - offsetX, 28 - offsetY);
        }
            break;
        case 7: {
            CGPathMoveToPoint(path, NULL, 3 - offsetX, 17 - offsetY);
            CGPathAddLineToPoint(path, NULL, 7 - offsetX, 23 - offsetY);
            CGPathAddLineToPoint(path, NULL, 14 - offsetX, 25 - offsetY);
            CGPathAddLineToPoint(path, NULL, 22 - offsetX, 25 - offsetY);
            CGPathAddLineToPoint(path, NULL, 29 - offsetX, 22 - offsetY);
            CGPathAddLineToPoint(path, NULL, 32 - offsetX, 17 - offsetY);
            CGPathAddLineToPoint(path, NULL, 32 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 27 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 19 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 11 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 13 - offsetY);
        }
            break;
        case 8: {
            CGPathMoveToPoint(path, NULL, 15 - offsetX, 34 - offsetY);
            CGPathAddLineToPoint(path, NULL, 2 - offsetX, 24 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 13 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 22 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 9 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 23 - offsetY);
            CGPathAddLineToPoint(path, NULL, 23 - offsetX, 32 - offsetY);
        }
            break;
        case 9: {
            CGPathMoveToPoint(path, NULL, 13 - offsetX, 29 - offsetY);
            CGPathAddLineToPoint(path, NULL, 7 - offsetX, 27 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 11 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 31 - offsetX, 9 - offsetY);
            CGPathAddLineToPoint(path, NULL, 31 - offsetX, 23 - offsetY);
            CGPathAddLineToPoint(path, NULL, 26 - offsetX, 27 - offsetY);
            CGPathAddLineToPoint(path, NULL, 20 - offsetX, 29 - offsetY);
        }
            break;
        case 10: {
            CGPathMoveToPoint(path, NULL, 13 - offsetX, 33 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 25 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 13 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path, NULL, 15 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 22 - offsetX, 3 - offsetY);
            CGPathAddLineToPoint(path, NULL, 30 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 33 - offsetX, 15 - offsetY);
            CGPathAddLineToPoint(path, NULL, 33 - offsetX, 22 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 30 - offsetY);
            CGPathAddLineToPoint(path, NULL, 22 - offsetX, 32 - offsetY);
        }
            break;
        case 11: {
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

- (UIImage *)radialGradientImage:(CGSize)size start:(UIColor*)start end:(UIColor*)end centre:(CGPoint)centre radius:(float)radius {
	// Render a radial background
	// http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_shadings/dq_shadings.html
	
	// Initialise
	UIGraphicsBeginImageContextWithOptions(size, 0, 1);
	
	// Create the gradient's colours
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { 0,0,0,0,  // Start color
        0,0,0,0 }; // End color
	[start getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
	[end getRed:&components[4] green:&components[5] blue:&components[6] alpha:&components[7]];
	
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	
	// Normalise the 0-1 ranged inputs to the width of the image
	CGPoint myCentrePoint = CGPointMake(centre.x * size.width, centre.y * size.height);
	float myRadius = MIN(size.width, size.height) * radius;
	
	// Draw it!
	CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
								 0, myCentrePoint, myRadius,
								 kCGGradientDrawsAfterEndLocation);
	
	// Grab it as an autoreleased image
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
	// Clean up
	CGColorSpaceRelease(myColorspace); // Necessary?
	CGGradientRelease(myGradient); // Necessary?
	UIGraphicsEndImageContext(); // Clean up
	return image;
}
@end
