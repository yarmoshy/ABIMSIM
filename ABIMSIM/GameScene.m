//
//  GameScene
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/5/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#define kExtraSpaceOffScreen 63
#define kNumberOfLevelsToGenerate 2

#define MAX_VELOCITY 300
#define MIN_VELOCITY 300
#define MAX_ANGULAR_VELOCITY 1

#define starBackMovement 1.2
#define starFrontMovement 1.4

#define starScaleLarge 1
#define starScaleMedium 0.65
#define starScaleSmall 0.4

#define bufferZoneHeight 150

#define largePlanetWidth 650

#define starColorA @"ec52ea"
#define starColorB @"3eaabd"
#define starColorC @"ffffff"

#define asteroidColorBlue @"2eb0ce"
#define asteroidColorGreen @"6ecc32"
#define asteroidColorOrange @"d65e34"
#define asteroidColorBrownish @"c69b30"
#define asteroidColorYella @"dbdb0b"
#define asteroidColorPurple @"9e3dd1"

#define asteroidShield0 6
#define asteroidShield1 7

#define appStoreLink @"http://itunes.com/app/ABIMSIM"

#import "GameScene.h"
#import "HexColor.h"
#import "UpgradeScene.h"
#import "AudioController.h"
#import "PhysicsContstants.h"
#import "SpriteUserDataConstants.h"
#import "BlackHole.h"

@implementation GameScene  {
    NSMutableArray *spritesArrays;
    NSMutableArray *starSprites;
    NSMutableArray *currentSpriteArray;
    NSNumber *safeToTransition;
    SKSpriteNode *starBackLayer;
    SKSpriteNode *starFrontLayer;
    SKSpriteNode *background, *background2;
    SKSpriteNode *shipSprite, *currentBlackHole, *explodingMine, *explodedMine;
    BOOL shipWarping;
    BOOL hasShield;
    BOOL showingSun;
    int possibleBubblesPopped, lastShieldLevel, lastMineLevel;
    
    NSInteger shieldHitPoints;
    NSInteger shipHitPoints;
    
    UIPanGestureRecognizer *flickRecognizer;
    
    BOOL showGameCenter, walkthroughSeen;
    int lastLevelPanned;
    NSTimeInterval lastTimeHit;
    int timesHitWithinSecond;
    
    NSArray *spaceMineTextures;
    
    SKAction *shieldUpSoundAction;
    SKAction *shieldDownSoundAction;
    SKAction *spaceMineSoundAction;
    
    CGPoint lastShipPosition;
}

static NSMutableArray *backgroundTextures;
static NSMutableArray *backgroundTextureAtlases;
CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * (M_PI / 180);
};


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        walkthroughSeen = [ABIMSIMDefaults boolForKey:kWalkthroughSeen];
        
        shieldUpSoundAction = [SKAction playSoundFileNamed:@"activateShieldTrimmed.caf" waitForCompletion:NO];
        shieldDownSoundAction = [SKAction playSoundFileNamed:@"deactivateShieldTrimmed.caf" waitForCompletion:NO];
        spaceMineSoundAction = [SKAction playSoundFileNamed:@"explosionMineTrimmed.caf" waitForCompletion:NO];
        
        lastTimeHit = 0;
        timesHitWithinSecond = 0;
        
        if (!backgroundTextures) {
            backgroundTextures = [NSMutableArray arrayWithCapacity:7];
            NSMutableArray *backgroundTextureAtlases = [NSMutableArray array];
            for (int i = 0; i < 2; i++) {
                SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"Background%d",i]];
                [backgroundTextureAtlases addObject:atlas];
                for (int j = 0; j < 4; j++) {
                    NSString *textureName = [NSString stringWithFormat:@"Background_%d", (i*4)+j];
                    if ((i*4)+j > 6) {
                        break;
                    }
                    NSLog(@"%@",textureName);
                    [backgroundTextures addObject:[atlas textureNamed:textureName]];
                }
            }
        }
        [SKTextureAtlas preloadTextureAtlases:backgroundTextureAtlases withCompletionHandler:^{
            ;
        }];
        [SKTexture preloadTextures:backgroundTextures withCompletionHandler:^{
            ;
        }];
        
        NSMutableArray *planetTextures = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            for (int j = 0; j < 4; j++) {
                NSString *textureName = [NSString stringWithFormat:@"Planet_%d_%d", i, j];
                NSLog(@"%@",textureName);
                [planetTextures addObject:[SKTexture textureWithImageNamed:textureName]];
            }
        }
        [SKTexture preloadTextures:planetTextures withCompletionHandler:^{
            ;
        }];
        NSMutableArray *asteroidTextures = [NSMutableArray array];
        for (int i = 0; i < 12; i++) {
            NSString *textureName = [NSString stringWithFormat:@"Asteroid_%d", i];
            NSLog(@"%@",textureName);
            [asteroidTextures addObject:[SKTexture textureWithImageNamed:textureName]];
        }
        [SKTexture preloadTextures:asteroidTextures withCompletionHandler:^{
            ;
        }];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, -kExtraSpaceOffScreen, size.width, size.height+kExtraSpaceOffScreen*2)];
        borderBody.categoryBitMask = borderCategory;
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        self.physicsWorld.contactDelegate = self;
        
        background2 = [SKSpriteNode spriteNodeWithTexture:backgroundTextures[1]];
        background2.anchorPoint = CGPointZero;
        background2.zPosition = -1;
        background2.alpha = 0;
        [self addChild:background2];

        
        background = [SKSpriteNode spriteNodeWithTexture:backgroundTextures[0]];
        background.anchorPoint = CGPointZero;
        background.zPosition = -1;
        [self addChild:background];
        
        SKSpriteNode *secondaryBorderSprite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height+kExtraSpaceOffScreen)];
        secondaryBorderSprite.anchorPoint = CGPointZero;
        secondaryBorderSprite.position = CGPointZero;
        SKPhysicsBody* secondaryBorderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, size.width, size.height+kExtraSpaceOffScreen)];
        secondaryBorderBody.friction = 0.0f;
        secondaryBorderBody.categoryBitMask = secondaryBorderCategory;
        secondaryBorderSprite.physicsBody = secondaryBorderBody;
        [self addChild:secondaryBorderSprite];

        starBackLayer = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height * starBackMovement)];
        starFrontLayer = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height * starFrontMovement)];
        starFrontLayer.anchorPoint = CGPointZero;
        starBackLayer.anchorPoint = CGPointZero;
        starBackLayer.position = starFrontLayer.position = CGPointMake(0, 0);
        [self addChild:starBackLayer];
        [self addChild:starFrontLayer];

        lastShieldLevel = lastMineLevel = 0;
        
        hasShield = [ABIMSIMDefaults boolForKey:kShieldOnStart];
        if (hasShield) {
            shieldHitPoints = 1 + [ABIMSIMDefaults integerForKey:kShieldDurabilityLevel];
        } else {
            shieldHitPoints = 0;
        }
        shipHitPoints = 1;
        shipSprite = [self createShip];
        
        spritesArrays = [NSMutableArray array];
        currentSpriteArray = [NSMutableArray array];
        
        SKLabelNode *level = [[SKLabelNode alloc] initWithFontNamed:@"Voltaire"];
        level.text = [NSString stringWithFormat:@"%d",self.currentLevel];
        level.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        level.position = CGPointMake(15, 15);
        level.zPosition = 100;
        level.name = levelNodeName;
        level.hidden = YES;
        [self addChild:level];
                
        [self addChild:shipSprite];
        [self updateShipPhysics];
        [self childNodeWithName:shipCategoryName].physicsBody.collisionBitMask = borderCategory | asteroidCategory | planetCategory;
        [self generateInitialLevelsAndShowSprites:NO];
        safeToTransition = @YES;
        shipWarping = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIApplicationWillResignActiveNotification object:nil];

    }
    return self;
}

-(void)transitionFromMainMenu {
    [[AudioController sharedController] gameplay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIApplicationDidBecomeActiveNotification object:nil];

    [self transitionStars];
    [self showCurrentSprites];
    self.viewController.pauseButton.hidden = NO;
    self.viewController.pauseButton.alpha = 0;
    [self childNodeWithName:levelNodeName].hidden = NO;
    [self childNodeWithName:levelNodeName].alpha = 0;
    [[self childNodeWithName:shipCategoryName] runAction:[SKAction moveTo:CGPointMake(self.frame.size.width/2, ((SKSpriteNode*)[self childNodeWithName:shipCategoryName]).size.height*2) duration:0.5] completion:^{
        self.paused = NO;
        self.initialPause = YES;
        flickRecognizer.enabled = YES;
    }];
    SKAction *move = [SKAction moveTo:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + ((SKSpriteNode*)[self childNodeWithName:directionsSpriteName]).size.height) duration:0.5];
    SKAction *alphaIn = [SKAction fadeAlphaTo:1 duration:0.5];
    SKAction *group = [SKAction group:@[move, alphaIn]];
    [[self childNodeWithName:directionsSpriteName] runAction:group completion:^{
        for (SKSpriteNode *direction in [self children]) {
            if ([direction.name isEqualToString:directionsSecondarySpriteName]) {
                [direction runAction:[SKAction sequence:@[[SKAction waitForDuration:1],alphaIn]]];
            } else if ([direction.name isEqualToString:directionsSecondaryBlinkingSpriteName]) {
                SKAction *wait = [SKAction waitForDuration:1];
                SKAction *alphaIn = [SKAction fadeAlphaTo:1 duration:1];
                SKAction *alphaOut = [SKAction fadeAlphaTo:0 duration:1];
                SKAction *sequence = [SKAction sequence:@[alphaIn, alphaOut, [SKAction waitForDuration:0.5]]];
                [direction runAction:[SKAction sequence:@[wait,[SKAction repeatActionForever:sequence]]]];
            }
        }
    }];

    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        self.viewController.pauseButton.alpha = 1;
        [self childNodeWithName:levelNodeName].alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];
//    self.currentLevel = 100;
//    self.bubblesPopped = 10;
//    self.sunsSurvived = 10;
//    self.blackHolesSurvived = 10;
}

-(void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    flickRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:flickRecognizer];
    flickRecognizer.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.paused = NO;
    });
}

-(void)willMoveFromView:(SKView *)view {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeGestureRecognizer:flickRecognizer];
}

-(void)pause {
    self.paused = YES;
    flickRecognizer.enabled = NO;
    [self.viewController showPausedView];
}

-(void)upgradeTapped:(id)sender {
    UpgradeScene *us = [[UpgradeScene alloc] initWithSize:self.size];
    us.viewController = self.viewController;
    [self.view presentScene:us transition:[SKTransition pushWithDirection:SKTransitionDirectionLeft duration:1]];
}

-(void)update:(CFTimeInterval)currentTime {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self pause];
    }
    if (self.paused) {
        if (self.resuming && !flickRecognizer.enabled) {
            flickRecognizer.enabled = YES;
        }
        return;
    }
    
    if (shipSprite.physicsBody.velocity.dx!=0 || shipSprite.physicsBody.velocity.dy!=0)
        shipSprite.zRotation = atan2f(-shipSprite.physicsBody.velocity.dx, shipSprite.physicsBody.velocity.dy);
    
    if (!walkthroughSeen) {
        if (self.currentLevel == 2) {
            SKSpriteNode *directions = [SKSpriteNode spriteNodeWithImageNamed:@"Instructions_Screen2"];
            directions.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + directions.size.height * 2);
            [self addChild:directions];
            directions.alpha = 0;
            directions.zPosition = 100;
            directions.name = directionsSpriteName;

            SKAction *move = [SKAction moveTo:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + ((SKSpriteNode*)[self childNodeWithName:directionsSpriteName]).size.height/2) duration:0.5];
            SKAction *alphaIn = [SKAction fadeAlphaTo:1 duration:0.5];
            SKAction *group = [SKAction group:@[move, alphaIn]];
            [[self childNodeWithName:directionsSpriteName] runAction:group completion:^{
                self.paused = YES;
                self.initialPause = YES;
            }];
            walkthroughSeen = YES;
            [ABIMSIMDefaults setBool:YES forKey:kWalkthroughSeen];
            [ABIMSIMDefaults synchronize];
        }
    }

    for (SKSpriteNode *sprite in self.children) {
        if ([sprite.name isEqualToString:removedThisSprite]) {
            [sprite removeFromParent];
        }
    }
    
    if (self.reset) {
        [self resetWorld];
    }

    /* Called before each frame is rendered */
    if (shipWarping && shipSprite.position.y > shipSprite.frame.size.height/2) {
        shipWarping = NO;
        shipSprite.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | asteroidCategory | planetCategory;
    }
    if (shipSprite) {
        float yPercentageFromCenter = (shipSprite.position.y - (self.view.frame.size.height/2.0))  / (self.view.frame.size.height / 2.0);
        float frontMaxY = ((self.view.frame.size.height * starFrontMovement) - self.view.frame.size.height)/2.0;
        float backMaxY = ((self.view.frame.size.height * starBackMovement) - self.view.frame.size.height)/2.0;
        float frontY = (yPercentageFromCenter * frontMaxY);
        frontY = frontY + (frontMaxY);
        float backY = (yPercentageFromCenter * backMaxY);
        backY = backY + (backMaxY);
        starFrontLayer.position = CGPointMake(starFrontLayer.position.x, -frontY);
        starBackLayer.position = CGPointMake(starBackLayer.position.x, -backY);
    }
    
    static int maxSpeed = MAX_VELOCITY;
    float speed = sqrt(shipSprite.physicsBody.velocity.dx*shipSprite.physicsBody.velocity.dx + shipSprite.physicsBody.velocity.dy * shipSprite.physicsBody.velocity.dy);
    if (speed > maxSpeed) {
        shipSprite.physicsBody.linearDamping = 0.4f;
    } else {
        shipSprite.physicsBody.linearDamping = 0.0f;
    }
//    CGPoint velocity = CGPointMake(shipSprite.physicsBody.velocity.dx, shipSprite.physicsBody.velocity.dy) ;
//    [shipSprite runAction:[SKAction rotateToAngle:[self pointPairToBearingDegrees:CGPointZero secondPoint:velocity] duration:0]];
    if (currentBlackHole) {
        for (SKSpriteNode *sprite in currentBlackHole.children) {
            if ([sprite.name isEqualToString:removedThisSprite]) {
                if (sprite.size.width < 5) {
                    [sprite removeFromParent];
                }
            }
        }

        [self applyBlackHolePullToSprite:shipSprite];
        for (SKSpriteNode *sprite in self.children) {
            if ([sprite.name isEqualToString:asteroidCategoryName] ||
                [sprite.name isEqualToString:planetCategoryName] ||
                [sprite.name isEqualToString:asteroidShieldCategoryName] ||
                [sprite.name isEqualToString:asteroidInShieldCategoryName]) {
                if (sprite.parent || [sprite.name isEqualToString:asteroidInShieldCategoryName]) {
                    [self applyBlackHolePullToSprite:sprite];
                }
            }
        }
        for (SKSpriteNode *star in starFrontLayer.children) {
            if (star.xScale != 0 && star.yScale != 0) {
                [self applyBlackHolePullToSprite:star];
            }
        }
        for (SKSpriteNode *star in starBackLayer.children) {
            if (star.xScale != 0 && star.yScale != 0) {
                [self applyBlackHolePullToSprite:star];
            }
        }

    }

    for (SKSpriteNode *asteroid in currentSpriteArray) {
        if ([asteroid.name isEqualToString:planetCategoryName]) {
            for (SKSpriteNode *child in asteroid.children) {
                child.position = CGPointZero;
            }
        }
        if (![asteroid.name isEqualToString:asteroidCategoryName] &&
            ![asteroid.name isEqualToString:asteroidInShieldCategoryName]) {
            continue;
        }

        if (asteroid.position.y - asteroid.size.height/2 > self.frame.size.height) {
            if (asteroid.parent && [asteroid.name isEqualToString:asteroidCategoryName]) {
                [asteroid removeFromParent];
                continue;
            }
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
    
//    SKSpriteNode *explodingMine = (SKSpriteNode*)[self childNodeWithName:explodingSpaceMine];
//    SKSpriteNode *explodedMine = (SKSpriteNode*)[self childNodeWithName:explodedSpaceMine];
    if (explodingMine) {
        SKSpriteNode *explodingRing = (SKSpriteNode*)[explodingMine childNodeWithName:powerUpSpaceMineExplodeRingName];
        if (explodingRing.size.width > 0) {
            explodingRing.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:explodingRing.size.width/2];
            explodingRing.physicsBody.dynamic = NO;
            explodingRing.physicsBody.categoryBitMask = powerUpSpaceMineExplodingRingCategory;
            explodingRing.physicsBody.contactTestBitMask = asteroidCategory;
            explodingRing.physicsBody.collisionBitMask = asteroidCategory ;
            
            for (SKSpriteNode *node in currentSpriteArray) {
                if ([node.name isEqualToString:asteroidShieldCategoryName]) {
                    CGPoint ringPos = explodingRing.parent.position;
                    CGPoint astShPos = node.position;
                    float distance = sqrtf(powf(ringPos.x-astShPos.x, 2)+powf(ringPos.y-astShPos.y, 2));
                    if (distance < (explodingRing.size.width/2.f) + (node.size.width/2.f)) {
                        possibleBubblesPopped++;
                        NSString *imageName = @"";
                        float scale = 0;
                        float duration = 0.5;
                        if ([node.userData[planetNumber] intValue] == asteroidShield0) {
                            imageName = @"AsteroidShield_Pop_0";
                            scale = 0.625;
                        } else {
                            imageName = @"AsteroidShield_Pop_1";
                            scale = 0.65;
                        }
                        SKSpriteNode *explosionSprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
                        explosionSprite.position = node.position;
                        [explosionSprite setScale:scale];
                        explosionSprite.zPosition = 10;
                        [self addChild:explosionSprite];
                        SKAction *fadeAction = [SKAction fadeAlphaTo:0 duration:0.5];
                        SKAction *scaleAction = [SKAction scaleTo:1 duration:duration];
                        SKAction *groupAction = [SKAction group:@[fadeAction, scaleAction]];
                        [explosionSprite runAction:[SKAction sequence:@[groupAction, [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                            node.name = removedThisSprite;
                        }]]]];
                        node.name = removedThisSprite;
                        for (SKSpriteNode *asteroid in [self children]) {
                            if ([asteroid.name isEqual:asteroidInShieldCategoryName] &&
                                [asteroid.userData[asteroidShieldTag] intValue] == [node.userData[asteroidShieldTag] intValue]) {
                                asteroid.physicsBody.categoryBitMask = asteroidCategory;
                                asteroid.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | shipCategory | asteroidCategory | planetCategory | asteroidShieldCategory | powerUpSpaceMineExplodingRingCategory;
                                asteroid.physicsBody.contactTestBitMask = goalCategory | shipCategory | asteroidShieldCategory;
                                asteroid.zRotation = DegreesToRadians(arc4random() % 360);
                                float velocity = MAX_VELOCITY;
                                asteroid.physicsBody.velocity = CGVectorMake(velocity * cosf(asteroid.zRotation), velocity * -sinf(asteroid.zRotation));
                            }
                        }
                    }
                }
            }
        }
    }
    if (explodedMine) {
        SKSpriteNode *explodingRing = (SKSpriteNode*)[explodingMine childNodeWithName:powerUpSpaceMineExplodeRingName];
        [explodingRing removeFromParent];
        [explodedMine removeFromParent];
    }
    if (self.transitioningToMenu) {
        self.transitioningToMenu = NO;
        self.paused = YES;
        self.initialPause = YES;
    }
}

-(void)applyBlackHolePullToSprite:(SKSpriteNode*)sprite {
    CGPoint p1 = [self childNodeWithName:blackHoleCategoryName].position;
    CGPoint p2 = sprite.position;
    if ([sprite.name isEqualToString:starSpriteName]) {
        if ([sprite.parent isEqual:starFrontLayer]) {
            p2.y += starFrontLayer.position.y;
        } else {
            p2.y += starBackLayer.position.y;
        }
    }

    CGFloat r = DegreesToRadians([self pointPairToBearingDegrees:p1 secondPoint:p2]);
    float x = cosf(r);
    float y = sinf(r);

    float distance = sqrtf(powf(p1.x - p2.x,2) + powf(p1.y - p2.y, 2));
    float magnitude = (self.frame.size.height / distance);
    if (sprite.name == planetCategoryName) {
        magnitude = powf(magnitude, 7.5);
        magnitude *= 10;
    } else if (sprite.name == shipCategoryName) {
        magnitude = powf(magnitude, 4.5);
    } else {
        magnitude = powf(magnitude, 4);
    }
    [sprite.physicsBody applyImpulse:CGVectorMake(-x*magnitude, -y*magnitude)];
    if ([sprite.name isEqualToString:asteroidShieldCategoryName] || [sprite.name isEqualToString:starSpriteName]) {
        if (magnitude > 250) {
            magnitude = 250;
        }
        [sprite runAction:[SKAction moveBy:CGVectorMake(-x * (magnitude/100), -y*(magnitude/100)) duration:0]];
    }
}

#pragma mark - Achievements
-(void)checkPlanetHitAchievement:(int)planetNum {
    switch (planetNum) {
        case 0:
            [ABIMSIMDefaults setBool:YES forKey:kPlanet0Hit];
            break;
        case 1:
            [ABIMSIMDefaults setBool:YES forKey:kPlanet1Hit];
            break;
        case 2:
            [ABIMSIMDefaults setBool:YES forKey:kPlanet2Hit];
            break;
        case 3:
            [ABIMSIMDefaults setBool:YES forKey:kPlanet3Hit];
            break;
        case 4:
            [ABIMSIMDefaults setBool:YES forKey:kPlanet4Hit];
            break;
        case 5:
            [ABIMSIMDefaults setBool:YES forKey:kPlanet5Hit];
            break;
        default:
            break;
    }
    [ABIMSIMDefaults synchronize];
    if ([ABIMSIMDefaults boolForKey:kPlanet0Hit] &&
        [ABIMSIMDefaults boolForKey:kPlanet1Hit] &&
        [ABIMSIMDefaults boolForKey:kPlanet2Hit] &&
        [ABIMSIMDefaults boolForKey:kPlanet3Hit] &&
        [ABIMSIMDefaults boolForKey:kPlanet4Hit] &&
        [ABIMSIMDefaults boolForKey:kPlanet5Hit]) {
        [self sendAchievementWithIdentifier:@"allAroundTheWorlds"];
    }
}

-(void)checkHitAchievement {
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if (now - lastTimeHit <= 1) {
        timesHitWithinSecond++;
        if (timesHitWithinSecond >= 3) {
            [self sendAchievementWithIdentifier:@"poorUnfortunateSoul"];
        }
    } else {
        lastTimeHit = now;
        timesHitWithinSecond = 0;
    }
}

-(void)checkLevelAchievements {
    NSString *identifier = @"";
    switch (self.currentLevel) {
        case 10:
            identifier = @"learningToFly";
            break;
        case 20:
            identifier = @"explorerReporting";
            break;
        case 30:
            identifier = @"adventureIsOutThere";
            break;
        case 40:
            identifier = @"gettinKindaHectic";
            break;
        case 50:
            identifier = @"deepSpace";
            break;
        case 60:
            identifier = @"toBoldyGo";
            break;
        case 70:
            identifier = @"whereNoManHasGoneBefore";
            break;
        case 80:
            identifier = @"acrossTheCosmos";
            break;
        case 90:
            identifier = @"theObservableUniverse";
            break;
        case 100:
            identifier = @"theEdgeOfSpace";
            break;
        default:
            identifier = @"";
            break;
    }
    if (![identifier isEqualToString:@""]) {
        [self sendAchievementWithIdentifier:identifier];
    }
    if (self.currentLevel - lastLevelPanned >= 5) {
        identifier = @"Autopilot";
        [self sendAchievementWithIdentifier:identifier];
    }
}

-(void)sendAchievementWithIdentifier:(NSString*)identifier {
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    if (achievement)
    {
        achievement.percentComplete = 100.0;
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error)
         {
             if (![ABIMSIMDefaults boolForKey:identifier]) {
                 [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
                     for (GKAchievementDescription *description in descriptions) {
                         if ([description.identifier isEqualToString:identifier]) {
                             [GKNotificationBanner showBannerWithTitle:description.title message:description.achievedDescription duration:1 completionHandler:^{
                                 [ABIMSIMDefaults setBool:YES forKey:identifier];
                                 [ABIMSIMDefaults synchronize];
                             }];
                         }
                     }
                 }];
                 if (error != nil)
                 {
                     NSLog(@"Error in reporting achievements: %@", error);
                 }
             }
        }];
    }
}

#pragma mark - Touch Handling

-(void)handlePanGesture:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateEnded || (self.paused && !self.initialPause && !self.resuming)) {
        return;
    }
    lastLevelPanned = self.currentLevel;
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
    if (self.initialPause) {
        self.initialPause = NO;
        self.paused = NO;
        [self removeOverlayChildren];
    }
    shipSprite.physicsBody.velocity = CGVectorMake(newVelocity.x, -newVelocity.y);
    if (shipSprite.physicsBody) {
        [[shipSprite childNodeWithName:shipThrusterSpriteName] runAction:shipSprite.userData[shipThrusterAnimation] withKey:shipThrusterAnimation];
    }
}


//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    /* Called when a touch begins */
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInNode:self];
//    SKNode *node = [self nodeAtPoint:location];
//    if ([node.name isEqualToString:pauseSpriteName]) {
//        [self pauseTapped:nil];
//    }
//    if ([node.name isEqualToString:upgradeSpriteName]) {
//        [self upgradeTapped:nil];
//    }
//    if ([node.name isEqualToString:gameCenterSpriteName]) {
//        [self showGameCenter];
//    }
//    if ([node.name isEqualToString:twitterSpriteName]) {
//        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
//        {
//            SLComposeViewController *tweetSheetOBJ = [SLComposeViewController
//                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
//            [tweetSheetOBJ setInitialText:[NSString stringWithFormat:@"I'm playing ABIMSIM! Check it out! %@",appStoreLink]];
//            [self.viewController presentViewController:tweetSheetOBJ animated:YES completion:nil];
//        }
//    }
//    if ([node.name isEqualToString:facebokSpriteName]) {
//        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
//        {
//            SLComposeViewController *facebookSheetOBJ = [SLComposeViewController
//                                                      composeViewControllerForServiceType:SLServiceTypeFacebook];
//            [facebookSheetOBJ setInitialText:[NSString stringWithFormat:@"I'm playing ABIMSIM! Check it out! %@",appStoreLink]];
//            [self.viewController presentViewController:facebookSheetOBJ animated:YES completion:nil];
//        }
//    }
//}




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
        }
        else {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        if (firstBody.categoryBitMask == asteroidCategory && secondBody.categoryBitMask == powerUpSpaceMineExplodingRingCategory) {
            if (firstBody.node.userData[orbitJoint]) {
                [self.physicsWorld removeJoint:firstBody.node.userData[orbitJoint]];
            }
        }

        if ((firstBody.categoryBitMask == asteroidCategory || firstBody.categoryBitMask == asteroidInShieldCategory) && secondBody.categoryBitMask == asteroidShieldCategory) {
            NSString *imageName = @"";
            if ([secondBody.node.userData[planetNumber] intValue] == asteroidShield0) {
                imageName = @"AsteroidShield_Impact_0";
            } else {
                imageName = @"AsteroidShield_Impact_1";
            }
            SKSpriteNode *impactSprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            [secondBody.node addChild:impactSprite];
            SKAction *fadeAway = [SKAction fadeAlphaTo:0 duration:0.5];
            SKAction *remove = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                node.name = removedThisSprite;
            }];
            SKAction *sequence = [SKAction sequence:@[fadeAway,remove]];
            [impactSprite runAction:sequence];
            CGPoint p1 = secondBody.node.position;
            CGPoint p2 = firstBody.node.position;
            
            CGFloat f = [self pointPairToBearingDegrees:p1 secondPoint:p2] - 90;
            impactSprite.zRotation = DegreesToRadians(f);
        }
        
        if ((firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == asteroidShieldCategory) || (firstBody.categoryBitMask == asteroidShieldCategory && secondBody.categoryBitMask == blackHoleCategory)) {
            possibleBubblesPopped++;
            NSString *imageName = @"";
            float scale = 0;
            float duration = 0.5;
            if ([secondBody.node.userData[planetNumber] intValue] == asteroidShield0) {
                imageName = @"AsteroidShield_Pop_0";
                scale = 0.625;
            } else {
                imageName = @"AsteroidShield_Pop_1";
                scale = 0.65;
            }
            SKSpriteNode *nodeToUse;
            if  (secondBody.categoryBitMask == asteroidShieldCategory) {
                nodeToUse = (SKSpriteNode*)secondBody.node;
            } else {
                nodeToUse = (SKSpriteNode*)firstBody.node;
            }

            SKSpriteNode *explosionSprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            explosionSprite.position = nodeToUse.position;
            [explosionSprite setScale:scale];
            explosionSprite.zPosition = 10;
            [self addChild:explosionSprite];
            SKAction *fadeAction = [SKAction fadeAlphaTo:0 duration:0.5];
            SKAction *scaleAction = [SKAction scaleTo:1 duration:duration];
            SKAction *groupAction = [SKAction group:@[fadeAction, scaleAction]];
            [explosionSprite runAction:[SKAction sequence:@[groupAction, [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                node.name = removedThisSprite;
            }]]]];
            nodeToUse.name = removedThisSprite;
            for (SKSpriteNode *asteroid in [self children]) {
                if ([asteroid.name isEqual:asteroidInShieldCategoryName] &&
                    [asteroid.userData[asteroidShieldTag] intValue] == [secondBody.node.userData[asteroidShieldTag] intValue]) {
                    asteroid.physicsBody.categoryBitMask = asteroidCategory;
                    asteroid.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | shipCategory | asteroidCategory | planetCategory | asteroidShieldCategory | powerUpSpaceMineExplodingRingCategory;
                    asteroid.physicsBody.contactTestBitMask = goalCategory | shipCategory | asteroidShieldCategory;
                    asteroid.zRotation = DegreesToRadians(arc4random() % 360);
                    float velocity = MAX_VELOCITY;
                    asteroid.physicsBody.velocity = CGVectorMake(velocity * cosf(asteroid.zRotation), velocity * -sinf(asteroid.zRotation));
                }
            }
            return;
        }
        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == powerUpSpaceMineCategory) {
            if ([secondBody.node.name isEqualToString:explodingSpaceMine] ||
                [secondBody.node.name isEqualToString:explodedSpaceMine]) {
                return;
            }
            secondBody.node.name = explodingSpaceMine;
            explodingMine = (SKSpriteNode*)secondBody.node;
            [secondBody.node removeAllActions];
            [[secondBody.node childNodeWithName:powerUpSpaceMineGlowName] removeFromParent];
            [secondBody.node runAction:secondBody.node.userData[powerUpSpaceMineExplosionGlowAnimation] completion:^{
                ;
            }];

            SKAction *sequenceAction = [SKAction sequence:@[[SKAction waitForDuration:0.5],secondBody.node.userData[powerUpSpaceMineExplosionRingAnimation],[SKAction waitForDuration:1]]];
            [secondBody.node runAction:sequenceAction completion:^{
                secondBody.node.name = explodedSpaceMine;
                explodedMine = (SKSpriteNode*)secondBody.node;
            }];
            [self runAction:spaceMineSoundAction];
        }

        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == goalCategory) {
            if ([safeToTransition isEqualToNumber:@YES]) {
                safeToTransition = @NO;
                secondBody.node.name = removedThisSprite;
                [self transitionStars];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self advanceToNextLevel];
                });

            }
        }
        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == planetCategory) {
            SKSpriteNode *planet = (SKSpriteNode*)secondBody.node;
            int planetNum = [planet.userData[planetNumber] intValue];
            [self checkPlanetHitAchievement:planetNum];
        }
        if (firstBody.categoryBitMask == asteroidCategory && secondBody.categoryBitMask == goalCategory) {
            firstBody.node.name = removedThisSprite;
        }
        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == powerUpShieldCategory) {
            secondBody.node.name = removedThisSprite;
            hasShield = YES;
            shieldHitPoints = 1 + [ABIMSIMDefaults integerForKey:kShieldDurabilityLevel];
//            shieldFireHitPoints = [ABIMSIMDefaults integerForKey:kShieldFireDurabilityLevel];
            [self updateShipPhysics];
        }

        if ([firstBody.node.name isEqualToString:sunObjectSpriteName]) {
            if (secondBody.categoryBitMask == shipCategory) {
                [self checkHitAchievement];
                if (hasShield) {
//                    if (shieldFireHitPoints > 0) {
//                        shieldFireHitPoints--;
//                    } else {
//                        shieldHitPoints = 0;
//                        hasShield = NO;
//                        [self updateShipPhysics];
//                    }
                    shieldHitPoints--;
                    hasShield = shieldHitPoints > 0;
                    [self updateShipPhysics];
                } else {
                    [self sendAchievementWithIdentifier:@"setTheControlsForTheHeartOfTheSun"];
                    [self killShipAndStartOver];
                }
            } else {
                secondBody.node.name = removedThisSprite;
            }
        }
        if ([secondBody.node.name isEqualToString:sunObjectSpriteName]) {
            if (firstBody.categoryBitMask == shipCategory) {
                [self checkHitAchievement];
                if (hasShield) {
                    shieldHitPoints--;
                    hasShield = shieldHitPoints > 0;
                    [self updateShipPhysics];
                } else {
                    [self sendAchievementWithIdentifier:@"setTheControlsForTheHeartOfTheSun"];
                    [self killShipAndStartOver];
                }
            } else {
                firstBody.node.name = removedThisSprite;
            }
        }
        if ([secondBody.node.name isEqualToString:blackHoleCategoryName]) {
            CGPoint p1 = [self childNodeWithName:blackHoleCategoryName].position;
            CGPoint p2 = firstBody.node.position;
            if ([firstBody.node.name isEqualToString:starSpriteName]) {
                if ([firstBody.node.parent isEqual:starFrontLayer]) {
                    p2.y += starFrontLayer.position.y;
                } else {
                    p2.y += starBackLayer.position.y;
                }
            }

            if ([firstBody.node.name isEqualToString:shipCategoryName]) {
                firstBody.node.name = @"dyingShip";
                shipSprite = nil;
            } else if ([firstBody.node.name isEqualToString:starSpriteName]) {
                firstBody.node.name = @"dyingStar";
            } else {
                firstBody.node.name = @"dying";
            }
            CGFloat r = DegreesToRadians([self pointPairToBearingDegrees:p1 secondPoint:p2]);
            float distance = sqrtf(powf(p1.x - p2.x,2) + powf(p1.y - p2.y, 2));
            SKSpriteNode *shipShieldImage;
            SKSpriteNode *shipImage;
            if ([firstBody.node.name isEqualToString:@"dyingShip"]) {
                shipShieldImage = (SKSpriteNode*)[[self childNodeWithName:@"dyingShip"] childNodeWithName:shipShieldSpriteName];
                shipImage = (SKSpriteNode*)[[self childNodeWithName:@"dyingShip"] childNodeWithName:shipImageSpriteName];

                shipShieldImage.name = @"dying";
                shipImage.name = @"dyingShip";

                [shipShieldImage removeFromParent];
                [shipImage removeFromParent];
                
                shipShieldImage.position = CGPointMake(distance*cosf(r), distance*sinf(r));
                shipImage.position = CGPointMake(distance*cosf(r), distance*sinf(r));
            } else {
                [firstBody.node removeFromParent];
                firstBody.node.position = CGPointMake(distance*cosf(r), distance*sinf(r));
            }
            if (firstBody.node) {
                if ([firstBody.node.name isEqualToString:@"dyingShip"]) {
                    [secondBody.node addChild:shipShieldImage];
                    [secondBody.node addChild:shipImage];
                } else {
                   [secondBody.node addChild:firstBody.node];
                }
            }
            float duration = 0.25;
            SKAction *deathAction =[SKAction sequence:@[[SKAction group:@[[SKAction moveTo:CGPointZero duration:duration],[SKAction scaleTo:0 duration:duration]]], [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                if (![node.name isEqualToString:@"dyingStar"]) {
                    if ([node.name isEqualToString:@"dyingShip"]) {
                        [self sendAchievementWithIdentifier:@"blackHole"];
                        [self killShipAndStartOver];
                    } else {
                        node.name = removedThisSprite;
                    }
                } else {
                    node.name = starSpriteName;
                }
            }]]];
            for (SKSpriteNode *child in firstBody.node.children) {
                [child runAction:deathAction];
            }
            if ([firstBody.node.name isEqualToString:@"dyingShip"]) {
                [shipShieldImage runAction:deathAction];
                [shipImage runAction:deathAction];
                firstBody.node.name = shipCategoryName;
            } else {
                [firstBody.node runAction:deathAction];
            }

            if (![firstBody.node.name isEqualToString:@"dyingStar"] &&
                ![firstBody.node.name isEqualToString:starSpriteName]) {
                    firstBody.node.name = removedThisSprite;
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
    if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == asteroidCategory) {
        [self checkHitAchievement];
        if (hasShield) {
            shieldHitPoints--;
            if (shieldHitPoints <= 0) {
                hasShield = NO;
                [self updateShipPhysics];
            } else {
                NSString *imageName = @"ShipShield_Impact";
                SKSpriteNode *impactSprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
                [[firstBody.node childNodeWithName:shipShieldSpriteName] addChild:impactSprite];
                SKAction *fadeAway = [SKAction fadeAlphaTo:0 duration:0.5];
                SKAction *remove = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                    node.name = removedThisSprite;
                }];
                SKAction *sequence = [SKAction sequence:@[fadeAway,remove]];
                [impactSprite runAction:sequence];
                CGPoint p1 = firstBody.node.position;
                CGPoint p2 = secondBody.node.position;
                
                CGFloat f = [self pointPairToBearingDegrees:p1 secondPoint:p2] - 90;
                impactSprite.zRotation = DegreesToRadians(f);

            }
        } else {
            shipHitPoints--;
            if (shipHitPoints <= 0) {
                [self killShipAndStartOver];
            }
        }
    }

}

-(void)killShipAndStartOver {
    int pointsEarned = self.currentLevel;
    pointsEarned += self.currentLevel / 10;
    pointsEarned += self.bubblesPopped * 5;
    pointsEarned += self.blackHolesSurvived * 4;
    pointsEarned += self.sunsSurvived * 3;
    [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets]+pointsEarned forKey:kUserDuckets];
    [ABIMSIMDefaults synchronize];
    GKScore *newScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"distance"];
    newScore.value = self.currentLevel;
    [GKScore reportScores:@[newScore] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Score Submit Error: %@", error);
        }
    }];
    [[self childNodeWithName:shipCategoryName] childNodeWithName:shipShieldSpriteName].hidden = YES;
    [[self childNodeWithName:shipCategoryName] childNodeWithName:shipImageSpriteName].hidden = YES;
    [[self childNodeWithName:shipCategoryName] childNodeWithName:shipThrusterSpriteName].hidden = YES;
    [self childNodeWithName:shipCategoryName].physicsBody = nil;

    [[AudioController sharedController] playerDeath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.paused = YES;
        [self.viewController showGameOverView];
        self.gameOver = YES;
        flickRecognizer.enabled = NO;
    });
}

#pragma mark - Level generation

-(SKSpriteNode*)createShip {
    SKSpriteNode *shipImage = [SKSpriteNode spriteNodeWithImageNamed:@"Ship"];
    shipImage.name = shipImageSpriteName;
    SKSpriteNode *shipThruster = [SKSpriteNode spriteNodeWithImageNamed:@"EngineExhaust"];
    shipThruster.name = shipThrusterSpriteName;
    shipThruster.alpha = 0;
    SKSpriteNode *shipShieldImage = [SKSpriteNode spriteNodeWithImageNamed:@"ShipShield"];
    shipShieldImage.name = shipShieldSpriteName;
    shipShieldImage.alpha = 0;
    SKSpriteNode *ship = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:shipShieldImage.size];
    [ship addChild:shipImage];
    [ship addChild:shipThruster];
    [ship addChild:shipShieldImage];
    ship.name = shipCategoryName;
    ship.position = CGPointMake(self.frame.size.width/2, -kExtraSpaceOffScreen + ship.size.height/2);
    ship.zPosition = 1;
    ship.userData = [NSMutableDictionary dictionary];
    SKAction *shieldSetup = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [node removeActionForKey:shipThrusterAnimation];
        node.alpha = 1;
        node.scale = 0.71;
    }];
    SKAction *growAction = [SKAction scaleTo:1.1 duration:0.3];
    SKAction *snapBack = [SKAction scaleTo:1.0 duration:0.1];
    SKAction *sequence = [SKAction sequence:@[shieldSetup,growAction,snapBack]];
    ship.userData[shipShieldOnAnimation] = sequence;
    
    SKAction *thrusterSetup = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        node.alpha = 0;
        node.scale = 0.71;
    }];
    SKAction *thrusterGrowAction = [SKAction scaleTo:1.1 duration:0.1];
    SKAction *thrusterSnapBack = [SKAction scaleTo:1.0 duration:0.1];
    SKAction *thrusterSizeSequenceAction = [SKAction sequence:@[thrusterGrowAction,thrusterSnapBack]];
    SKAction *thrusterFadeInAction = [SKAction fadeAlphaTo:1 duration:0.2];
    SKAction *thrusterWaitAction = [SKAction waitForDuration:0.1];
    SKAction *thrusterFadeOutAction = [SKAction fadeAlphaTo:0 duration:0.1];
    SKAction *thrusterFadeSequenceAction = [SKAction sequence:@[thrusterFadeInAction,thrusterWaitAction,thrusterFadeOutAction]];
    SKAction *sizeAndFadeGroupAction = [SKAction group:@[thrusterSizeSequenceAction,thrusterFadeSequenceAction]];
    SKAction *thrusterSequence = [SKAction sequence:@[thrusterSetup,sizeAndFadeGroupAction]];
    ship.userData[shipThrusterAnimation] = thrusterSequence;

//    shipThrusterAnimation
//    NSMutableArray *shipTextures = [NSMutableArray arrayWithCapacity:60];
//    for (int i = 0; i < 60; i++) {
//        NSString *assetName = [NSString stringWithFormat:@"Ship_%.3d",i];
//        [shipTextures addObject:[SKTexture textureWithImageNamed:assetName]];
//    }
//    SKAction *animationAction = [SKAction animateWithTextures:shipTextures timePerFrame:0.05];
//    [shipImage runAction:[SKAction repeatActionForever:animationAction]];
    return ship;
}

-(void)resetWorld {
    lastShieldLevel = lastMineLevel = 0;
    
    [background setTexture:backgroundTextures[0]];
    background.alpha = 1;
    [background2 setTexture:backgroundTextures[1]];
    background2.alpha = 0;

    [self removeOverlayChildren];
    [self removeCurrentSprites];
    self.currentLevel = 0;
    self.bubblesPopped = 0;
    self.sunsSurvived = 0;
    self.blackHolesSurvived = 0;
    hasShield = [ABIMSIMDefaults boolForKey:kShieldOnStart];
    if (hasShield) {
        shieldHitPoints = 1 + [ABIMSIMDefaults integerForKey:kShieldDurabilityLevel];
    } else {
        shieldHitPoints = 0;
    }
    shipHitPoints = 1;

    ((SKLabelNode*)[self childNodeWithName:levelNodeName]).text = [NSString stringWithFormat:@"%d",self.currentLevel];

    safeToTransition = @YES;
    SKSpriteNode *goal = (SKSpriteNode*)[self childNodeWithName:goalCategoryName];
    [goal removeFromParent];
    if (!shipSprite) {
        shipSprite = [self createShip];
        [self addChild:shipSprite];
    }
    [shipSprite childNodeWithName:shipShieldSpriteName].hidden = NO;
    [shipSprite childNodeWithName:shipImageSpriteName].hidden = NO;
    [shipSprite childNodeWithName:shipThrusterSpriteName].hidden = NO;
    [self updateShipPhysics];
    shipSprite.physicsBody.velocity = CGVectorMake(0, MAX_VELOCITY);
    
    shipSprite.physicsBody.collisionBitMask = borderCategory | asteroidCategory | planetCategory;
    shipSprite.position = CGPointMake(self.frame.size.width/2, -kExtraSpaceOffScreen + shipSprite.size.height/2);

    for (NSMutableArray *sprites in spritesArrays) {
        for (SKSpriteNode *sprite in sprites) {
            [sprite removeFromParent];
        }
        [sprites removeAllObjects];
    }
    [spritesArrays removeAllObjects];
    
    if (!self.transitioningToMenu) {
        [self transitionStars];
        [self generateInitialLevelsAndShowSprites:YES];
    }
    shipWarping = YES;
    self.reset = NO;
    flickRecognizer.enabled = YES;
}

-(void)transitionStars {
    float yVelocity = ((SKSpriteNode*)[self childNodeWithName:shipCategoryName]).physicsBody.velocity.dy;
    SKSpriteNode *oldStarFrontLayer = starFrontLayer;
    SKSpriteNode *oldStarBackLayer = starBackLayer;
    starBackLayer = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, self.size.height * starBackMovement)];
    starFrontLayer = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, self.size.height * starFrontMovement)];
    starBackLayer.zPosition = 0;
    starFrontLayer.zPosition = 0;
    starFrontLayer.anchorPoint = CGPointZero;
    starBackLayer.anchorPoint = CGPointZero;
    starBackLayer.position = starFrontLayer.position = CGPointMake(0, 0);
    [self insertChild:starBackLayer atIndex:0];
    [self insertChild:starFrontLayer atIndex:0];

    if (!starSprites) {
        starSprites = [NSMutableArray array];
        for (int i = 0; i < 12; i++) {
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"LargeStar"];
            star.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
            star.physicsBody.dynamic = NO;
            star.physicsBody.categoryBitMask = starCategory;
            star.physicsBody.collisionBitMask = 0;
            star.physicsBody.contactTestBitMask = blackHoleCategory;
            star.name = starSpriteName;
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
            [star setScale:0];
            [star runAction:[SKAction scaleTo:1 duration:0.5]];
        }
        for (int i = 0; i < 12; i++) {
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"LargeStar"];
            star.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
            star.physicsBody.dynamic = NO;
            star.physicsBody.categoryBitMask = starCategory;
            star.physicsBody.collisionBitMask = 0;
            star.physicsBody.contactTestBitMask = blackHoleCategory;
            star.name = starSpriteName;
            [starSprites addObject:star];
            [star setScale:0];
            star.colorBlendFactor = 1.0;
            if (i < 6) {
                [starBackLayer addChild:star];
            } else {
                [starFrontLayer addChild:star];
            }
        }
    } else {
        int i = 0;
        int half = 0;
        BOOL shrinkBackHalf = self.currentLevel % 2 == 0;
        for (SKSpriteNode *star in starSprites) {
            float x = arc4random() % (int)self.frame.size.width * 1;
            float y;
            if (i < 6) {
                y = arc4random() % (int)(self.frame.size.height * starBackMovement * 1);
            } else {
                y = arc4random() % (int)(self.frame.size.height * starFrontMovement * 1);
            }
            float scale = 0;
            if ((shrinkBackHalf && half == 0) ||
                (!shrinkBackHalf && half == 1)) {
                [star removeFromParent];
                if (i < 6) {
                    [starBackLayer addChild:star];
                } else {
                    [starFrontLayer addChild:star];
                }
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
                [star removeAllActions];
                star.physicsBody = nil;
                star.position = CGPointMake(x, y);
                [star runAction:[SKAction scaleTo:scale duration:0.5] completion:^{
                    star.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
                    star.physicsBody.dynamic = NO;
                    star.physicsBody.categoryBitMask = starCategory;
                    star.physicsBody.collisionBitMask = 0;
                    star.physicsBody.contactTestBitMask = blackHoleCategory;
                    star.name = starSpriteName;
                }];
            } else {
                SKAction *spawnAction = [SKAction group:@[[SKAction moveByX:0 y:yVelocity * 0.125 duration:0.5],
                                                          [SKAction runBlock:^{
                    [star runAction:[SKAction scaleTo:0 duration:0.5] completion:^{
                        [star removeFromParent];
                        if (i < 6) {
                            [starBackLayer addChild:star];
                        } else {
                            [starFrontLayer addChild:star];
                        }
                        [oldStarFrontLayer removeFromParent];
                        [oldStarBackLayer removeFromParent];
                    }];
                }]]];
                [star runAction:spawnAction];
            }
            i++;
            if (i > 11) {
                i = 0;
                half++;
            }
        }
    }
}

-(void)generateInitialLevelsAndShowSprites:(BOOL)show {
    self.currentLevel = 1;
    ((SKLabelNode*)[self childNodeWithName:levelNodeName]).text = @"1";
    for (int i = 1; i <= kNumberOfLevelsToGenerate; i++) {
        NSMutableArray *spriteArray = [NSMutableArray array];
        NSMutableArray *asteroids = [self asteroidsForLevel:i];
        [spriteArray addObjectsFromArray:asteroids];
        NSMutableArray *planets = [self planetsForLevel:i];
        [spriteArray addObjectsFromArray:planets];
        for (SKSpriteNode *planet in planets) {
            if ([planet isKindOfClass:[BlackHole class]]) {
                for (SKSpriteNode *sprite in asteroids) {
                    sprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory | asteroidInShieldCategory | planetCategory | asteroidShieldCategory | powerUpSpaceMineExplodingRingCategory;
                }
                break;
            }
        }
        NSMutableArray *powerUps = [self powerUpsForLevel:i];
        [spriteArray addObjectsFromArray:powerUps];
        CGRect goalRect;
        goalRect = CGRectMake(self.frame.origin.x, self.frame.size.height + kExtraSpaceOffScreen, self.frame.size.width, 15);
        SKNode* goal = [SKNode node];
        goal.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:goalRect];
        goal.name = goalCategoryName;
        goal.physicsBody.categoryBitMask = goalCategory;
        [spriteArray addObject:goal];
        
        [spritesArrays addObject:spriteArray];
    }
    currentSpriteArray = [spritesArrays firstObject];
    if (show) {
        [self showCurrentSprites];
    }
}

-(void)removeCurrentSprites {
    for (int i = 0; i < currentSpriteArray.count; i++) {
        if ([[currentSpriteArray[i] name] isEqual:asteroidCategoryName] ||
            [[currentSpriteArray[i] name] isEqual:asteroidInShieldCategoryName]) {
            [currentSpriteArray[i] removeFromParent];
        }
        if ([[currentSpriteArray[i] name] isEqual:planetCategoryName] ||
            [[currentSpriteArray[i] name] isEqual:sunObjectSpriteName] ||
            [[currentSpriteArray[i] name] isEqual:asteroidShieldCategoryName] ||
            [[currentSpriteArray[i] name] isEqual:blackHoleCategoryName]  ) {
            [currentSpriteArray[i] removeFromParent];
            for (SKSpriteNode *moon in ((SKSpriteNode*)currentSpriteArray[i]).userData[moonsArray]) {
                [moon removeFromParent];
            }
        }
        if ([[currentSpriteArray[i] name] isEqual:powerUpSpaceMineName] ||
            [[currentSpriteArray[i] name] isEqual:powerUpShieldName]) {
            [currentSpriteArray[i] removeFromParent];
        }
        
    }
    [currentSpriteArray removeAllObjects];
}

-(void)advanceToNextLevel {
    if (showingSun) {
        self.sunsSurvived++;
    }
    if (currentBlackHole) {
        self.blackHolesSurvived++;
    }
    self.bubblesPopped += possibleBubblesPopped;
    [self removeOverlayChildren];
    [self removeCurrentSprites];
    
    NSMutableArray *asteroids = [self asteroidsForLevel:self.currentLevel+kNumberOfLevelsToGenerate];
    [currentSpriteArray addObjectsFromArray:asteroids];
    NSMutableArray *planets = [self planetsForLevel:self.currentLevel+kNumberOfLevelsToGenerate];
    [currentSpriteArray addObjectsFromArray:planets];
    NSMutableArray *powerUps = [self powerUpsForLevel:self.currentLevel+kNumberOfLevelsToGenerate];
    [currentSpriteArray addObjectsFromArray:powerUps];

    self.currentLevel++;
    [self checkLevelAchievements];
    if (self.currentLevel % 10 == 0) {
        int backgroundNumber = self.currentLevel / 10;
        backgroundNumber++;
        if (backgroundNumber > 6) backgroundNumber = 6;
        if (background.alpha == 0) {
            [background runAction:[SKAction fadeAlphaTo:1 duration:0.5]];
            [background2 runAction:[SKAction fadeAlphaTo:0 duration:0.5] completion:^{
                [background2 setTexture:backgroundTextures[backgroundNumber]];
            }];
        } else {
            [background runAction:[SKAction fadeAlphaTo:0 duration:0.5] completion:^{
                [background setTexture:backgroundTextures[backgroundNumber]];
            }];
            [background2 runAction:[SKAction fadeAlphaTo:1 duration:0.5]];
        }
    }

    ((SKLabelNode*)[self childNodeWithName:levelNodeName]).text = [NSString stringWithFormat:@"%d",self.currentLevel];
    CGRect goalRect;
    goalRect = CGRectMake(self.frame.origin.x, self.frame.size.height + kExtraSpaceOffScreen, self.frame.size.width, 1);
    SKNode* goal = [SKNode node];
    goal.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:goalRect];
    goal.name = goalCategoryName;
    goal.physicsBody.categoryBitMask = goalCategory;
    [currentSpriteArray addObject:goal];

    
    [spritesArrays addObject:spritesArrays[0]];
    [spritesArrays removeObjectAtIndex:0];
    currentSpriteArray = spritesArrays[0];
    [self showCurrentSprites];
    safeToTransition = @YES;
    [self childNodeWithName:shipCategoryName].physicsBody.collisionBitMask = borderCategory | asteroidCategory | planetCategory;
    [self childNodeWithName:shipCategoryName].position = CGPointMake([self childNodeWithName:shipCategoryName].position.x, -kExtraSpaceOffScreen + ((SKSpriteNode*)[self childNodeWithName:shipCategoryName]).size.height/2);
    shipWarping = YES;
}

-(void)showCurrentSprites {
    currentBlackHole = nil;
    explodedMine = nil;
    explodingMine = nil;
    showingSun = NO;
    possibleBubblesPopped = 0;
    for (SKSpriteNode *sprite in currentSpriteArray) {
        if ([sprite.name isEqual:asteroidCategoryName] ||
            [sprite.name isEqual:asteroidInShieldCategoryName]) {
            sprite.hidden = NO;
            [self addChild:sprite];
        } else if ([sprite.name isEqual:planetCategoryName] ||
                   [sprite.name isEqual:sunObjectSpriteName] ||
                   [sprite.name isEqual:asteroidShieldCategoryName] ||
                   [sprite.name isEqual:blackHoleCategoryName] ) {
            if ([sprite.name isEqual:blackHoleCategoryName]) {
                currentBlackHole = sprite;
            }
            if ([sprite.name isEqual:sunObjectSpriteName]) {
                showingSun = YES;
            }
            sprite.hidden = NO;
            [self addChild:sprite];
            for (SKSpriteNode *moon in sprite.userData[moonsArray]) {
                moon.hidden = NO;
                [self addChild:moon];
                [self.physicsWorld addJoint:moon.userData[orbitJoint]];
                moon.physicsBody.angularVelocity = 100;
            }
            if ([sprite.name isEqual:asteroidShieldCategoryName]) {
                [sprite runAction:sprite.userData[asteroidShieldPulseAnimationAction]];
            }
            if ([sprite.name isEqual:blackHoleCategoryName]) {
                [sprite runAction:sprite.userData[blackHoleAnimation]];
            }

        } else if ([sprite.name isEqual:goalCategoryName]) {
            [self addChild:sprite];
        } else if ([sprite.name isEqual:powerUpShieldName]) {
            sprite.hidden = NO;
            [self addChild:sprite];
            [sprite runAction:sprite.userData[powerUpShieldPulseAnimation]];
        } else if ([sprite.name isEqual:powerUpSpaceMineName]) {
            sprite.hidden = NO;
            [self addChild:sprite];
            [sprite runAction:sprite.userData[powerUpSpaceMinePulseAnimation]];
            [sprite runAction:sprite.userData[powerUpSpaceMineRotationAnimation]];
        }
    }
    if (self.currentLevel == 1 && !self.reset) {
        SKSpriteNode *directions = [SKSpriteNode spriteNodeWithImageNamed:@"Instructions_Screen1"];
        directions.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + directions.size.height * 2);
        [self addChild:directions];
        directions.alpha = 0;
        directions.zPosition = 100;
        directions.name = directionsSpriteName;
        
        SKSpriteNode *swipeToStart = [SKSpriteNode spriteNodeWithImageNamed:@"SwipeToStartText"];
        swipeToStart.position = CGPointMake(self.frame.size.width/2, ((SKSpriteNode*)[self childNodeWithName:shipCategoryName]).size.height*3 - swipeToStart.size.height);
        [self addChild:swipeToStart];
        swipeToStart.alpha = 0;
        swipeToStart.name = directionsSecondarySpriteName;

        SKSpriteNode *shipDashedLine = [SKSpriteNode spriteNodeWithImageNamed:@"ShipDashedLine"];
        shipDashedLine.position = CGPointMake(self.frame.size.width/2, ((SKSpriteNode*)[self childNodeWithName:shipCategoryName]).size.height*2);
        [self addChild:shipDashedLine];
        shipDashedLine.alpha = 0;
        shipDashedLine.name = directionsSecondaryBlinkingSpriteName;

        SKSpriteNode *goalDashedLine = [SKSpriteNode spriteNodeWithImageNamed:@"TopDashedLine"];
        goalDashedLine.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - goalDashedLine.size.height);
        [self addChild:goalDashedLine];
        goalDashedLine.alpha = 0;
        goalDashedLine.name = directionsSecondaryBlinkingSpriteName;
    }
}

-(void)removeOverlayChildren {
    while ([self childNodeWithName:directionsSpriteName]) {
        [[self childNodeWithName:directionsSpriteName] removeFromParent];
    }
    while ([self childNodeWithName:directionsSecondarySpriteName]) {
        [[self childNodeWithName:directionsSecondarySpriteName] removeFromParent];
    }
    while ([self childNodeWithName:directionsSecondaryBlinkingSpriteName]) {
        [[self childNodeWithName:directionsSecondaryBlinkingSpriteName] removeFromParent];
    }
    while ([self childNodeWithName:upgradeSpriteName]) {
        [[self childNodeWithName:upgradeSpriteName] removeFromParent];
    }
    while ([self childNodeWithName:gameCenterSpriteName]) {
        [[self childNodeWithName:gameCenterSpriteName] removeFromParent];
    }
    while ([self childNodeWithName:facebokSpriteName]) {
        [[self childNodeWithName:facebokSpriteName] removeFromParent];
    }
    while ([self childNodeWithName:twitterSpriteName]) {
        [[self childNodeWithName:twitterSpriteName] removeFromParent];
    }
}

-(SKSpriteNode*)randomizeSprite:(SKSpriteNode*)sprite {
    float x = arc4random() % (int)self.frame.size.width * 1;
    float maxHeight = self.frame.size.height - bufferZoneHeight - (sprite.size.height/2.0);
    float y = (arc4random() % ((int)maxHeight)) + bufferZoneHeight + (sprite.size.height/2.0);
    sprite.position = CGPointMake(x, y);
    if ([sprite.name isEqualToString:asteroidCategoryName]) {
        sprite.zRotation = DegreesToRadians(arc4random() % 360);
        float velocity = arc4random() % (MAX_VELOCITY/2);
        sprite.physicsBody.velocity = CGVectorMake(velocity * cosf(sprite.zRotation), velocity * -sinf(sprite.zRotation));
    }
    return sprite;
}

#pragma mark - Black Hole

-(SKSpriteNode*)blackHole {
    return [BlackHole blackHole];
}


#pragma mark - Power Ups

-(NSMutableArray*)powerUpsForLevel:(int)level {
    NSMutableArray *powerUps = [[NSMutableArray alloc] init];
    if ([ABIMSIMDefaults integerForKey:kShieldOccuranceLevel] > 0) {
        if (level - lastShieldLevel >= 10 || (level >= 5 && lastShieldLevel == 0)) {
            long number = 10 * ([ABIMSIMDefaults integerForKey:kShieldOccuranceLevel] + (lastMineLevel == 0 ? 5 : 0));
            if (((arc4random() % 100)+1) <= number) {
                SKSpriteNode *shieldPowerUp = [self shieldPowerUp];
                [powerUps addObject:shieldPowerUp];
                lastShieldLevel = level;
            }
        }
    }
    if ([ABIMSIMDefaults integerForKey:kMineOccuranceLevel] > 0) {
        if (level - lastMineLevel >= 10 || (level >= 5 && lastMineLevel == 0)) {
            long number = 10 * ([ABIMSIMDefaults integerForKey:kMineOccuranceLevel] + (lastMineLevel == 0 ? 5 : 0));
            if (((arc4random() % 100)+1) <= number) {
                SKSpriteNode *spaceMinePowerUp = [self spaceMinePowerUp];
                [powerUps addObject:spaceMinePowerUp];
                lastMineLevel = level;
            }
        }
    }
    if (powerUps.count == 2) {
        SKSpriteNode *shield = powerUps[0];
        shield.position = CGPointMake(shield.position.x - 30, shield.position.y);
        SKSpriteNode *mine = powerUps[1];
        mine.position = CGPointMake(mine.position.x + 30, mine.position.y);
        
    }
    return powerUps;
}

-(SKSpriteNode*)spaceMinePowerUp {
    SKSpriteNode *spaceMinePowerUp = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceMine_Friendly_0"];
    spaceMinePowerUp.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:29];
    spaceMinePowerUp.physicsBody.dynamic = NO;
    spaceMinePowerUp.physicsBody.categoryBitMask = powerUpSpaceMineCategory;
    spaceMinePowerUp.physicsBody.contactTestBitMask = shipCategory;
    spaceMinePowerUp.name = powerUpSpaceMineName;
    spaceMinePowerUp.position = CGPointMake(self.size.width/2, 100);
    spaceMinePowerUp.zPosition = 1;
    spaceMinePowerUp.userData = [NSMutableDictionary dictionary];
    SKSpriteNode *glowSprite = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceMine_CenterGlow_0"];
    glowSprite.name = powerUpSpaceMineGlowName;
    [spaceMinePowerUp addChild:glowSprite];
    glowSprite.alpha = 0;
    
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:0.5];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.5];
    SKAction *repeat = [SKAction repeatActionForever:[SKAction sequence:@[fadeIn,fadeOut]]];
    
    SKAction *animationAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [[node childNodeWithName:powerUpSpaceMineGlowName] runAction:repeat];
    }];
    spaceMinePowerUp.userData[powerUpSpaceMinePulseAnimation] = animationAction;
    
    if (!spaceMineTextures) {
        NSMutableArray *textures = [NSMutableArray arrayWithCapacity:9];
        for (int i = 0; i < 9; i++) {
            NSString *imageName = [NSString stringWithFormat:@"SpaceMine_Friendly_%d",i];
            UIImage *image = [UIImage imageNamed:imageName];
            SKTexture* spaceMine = [SKTexture textureWithImage:image];
            [textures addObject:spaceMine];
        }
        spaceMineTextures = [NSArray arrayWithArray:textures];
    }
    
    SKAction *animation = [SKAction animateWithTextures:spaceMineTextures timePerFrame:0.1 resize:NO restore:NO];
    SKAction *repeatAnimation = [SKAction repeatActionForever:animation];
    spaceMinePowerUp.userData[powerUpSpaceMineRotationAnimation] = repeatAnimation;

    [self addSpaceMineExplosionRingAnimationsToSprite:spaceMinePowerUp];
    
    return spaceMinePowerUp;
}

-(void)addSpaceMineExplosionRingAnimationsToSprite:(SKSpriteNode*)sprite {
    if (!sprite.userData) {
        sprite.userData = [NSMutableDictionary new];
    }
    NSString *imageName = @"SpaceMine_ExplodingRing_0";
    float scale = 0;
    float duration = 1;
    SKSpriteNode *ring1 = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    [sprite addChild:ring1];
    ring1.name = powerUpSpaceMineExplodeRingName;
    ring1.alpha = 0;
    [ring1 setScale:scale];
    SKAction *expandRingAction = [SKAction scaleTo:1.25 duration:duration];
    SKAction *blockAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [node setScale:scale];
        [node setAlpha:1];
    }];
    SKAction *sequenceAction = [SKAction sequence:@[blockAction, expandRingAction]];
    SKAction *animationAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [[node childNodeWithName:powerUpSpaceMineExplodeRingName] runAction:sequenceAction completion:^{
//            [node removeFromParent];
            node.name = removedThisSprite;
        }];
    }];
    sprite.userData[powerUpSpaceMineExplosionRingAnimation] = animationAction;

    imageName = @"SpaceMine_LargeGlow_0";
    scale = 0;
    duration = 1;
    SKSpriteNode *largeGlow = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    [sprite addChild:largeGlow];
    largeGlow.name = powerUpSpaceMineExplodeGlowName;
    largeGlow.alpha = 0;
    [largeGlow setScale:scale];
    SKAction *expandRingActionB = [SKAction scaleTo:1 duration:duration/2.f];
    SKAction *alphaInRingActionB = [SKAction fadeAlphaTo:1 duration:duration/2.f];
    SKAction *alphaOutRingActionB = [SKAction fadeAlphaTo:0 duration:duration];
    SKAction *removeImageAction = [SKAction customActionWithDuration:0.1 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [sprite setTexture:nil];
    }];
    SKAction *groupActionB = [SKAction group:@[expandRingActionB,alphaInRingActionB]];
    SKAction *groupActionC = [SKAction group:@[alphaOutRingActionB,removeImageAction]];
    SKAction *sequenceActionB = [SKAction sequence:@[groupActionB, groupActionC]];
    SKAction *blockActionB = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [node setScale:scale];
        [node setAlpha:0];
    }];
    SKAction *sequenceActionC = [SKAction sequence:@[blockActionB, sequenceActionB]];
    SKAction *animationActionB = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [[node childNodeWithName:powerUpSpaceMineExplodeGlowName] runAction:sequenceActionC];
    }];
    sprite.userData[powerUpSpaceMineExplosionGlowAnimation] = animationActionB;
}


-(SKSpriteNode*)shieldPowerUp {
    SKSpriteNode *shieldPowerUp = [SKSpriteNode spriteNodeWithImageNamed:@"ShieldPowerUp"];
    shieldPowerUp.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:29];
    shieldPowerUp.physicsBody.dynamic = NO;
    shieldPowerUp.physicsBody.categoryBitMask = powerUpShieldCategory;
    shieldPowerUp.physicsBody.contactTestBitMask = shipCategory;
    shieldPowerUp.name = powerUpShieldName;
    shieldPowerUp.position = CGPointMake(self.size.width/2, 100);
    shieldPowerUp.zPosition = 1;
    shieldPowerUp.userData = [NSMutableDictionary dictionary];
    SKSpriteNode *glowSprite = [SKSpriteNode spriteNodeWithImageNamed:@"ShieldPowerUp_Animated"];
    glowSprite.name = powerUpShieldRingName;
    [shieldPowerUp addChild:glowSprite];
    glowSprite.alpha = 0;
    
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:0.3];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:1.0];
    SKAction *repeat = [SKAction repeatActionForever:[SKAction sequence:@[fadeIn,fadeOut]]];
    
    SKAction *animationAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [[node childNodeWithName:powerUpShieldRingName] runAction:repeat];
    }];
    shieldPowerUp.userData[powerUpShieldPulseAnimation] = animationAction;
    
    return shieldPowerUp;
}

-(void)updateShipPhysics {
    SKSpriteNode *ship = (SKSpriteNode*)[self childNodeWithName:shipCategoryName];
    CGVector velocity = ship.physicsBody.velocity;
    float width = 40;
    if (hasShield) {
        width = ship.size.width;
        if (self.currentLevel != 0) {
            [self runAction:shieldUpSoundAction];
            [[ship childNodeWithName:shipShieldSpriteName] runAction:ship.userData[shipShieldOnAnimation]];
        } else {
            [ship childNodeWithName:shipShieldSpriteName].alpha = 1;
            [[ship childNodeWithName:shipShieldSpriteName] setScale:1];
        }
    } else {
        if (self.currentLevel != 0) {
            [self runAction:shieldDownSoundAction];
            NSString *imageName = @"ShipShield_Pop";
            float scale = 0.64;
            float duration = 0.5;
            SKSpriteNode *explosionSprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
            [explosionSprite setScale:scale];
            explosionSprite.zPosition = 10;
            [ship addChild:explosionSprite];
            SKAction *fadeAction = [SKAction fadeAlphaTo:0 duration:0.5];
            SKAction *scaleAction = [SKAction scaleTo:1 duration:duration];
            SKAction *groupAction = [SKAction group:@[fadeAction, scaleAction]];
            [explosionSprite runAction:[SKAction sequence:@[groupAction, [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                [node removeFromParent];
            }]]]];
        }
        [ship childNodeWithName:shipShieldSpriteName].alpha = 0;
    }
    ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:width/2];
    ship.physicsBody.friction = 0.0f;
    ship.physicsBody.restitution = 1.0f;
    ship.physicsBody.linearDamping = 0.0f;
    ship.physicsBody.allowsRotation = NO;
    ship.physicsBody.categoryBitMask = shipCategory;
    ship.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | asteroidCategory | planetCategory;
    ship.physicsBody.contactTestBitMask = goalCategory | asteroidCategory | planetCategory | powerUpShieldCategory | powerUpSpaceMineCategory | asteroidShieldCategory;
    ship.physicsBody.mass = width;
    ship.physicsBody.velocity = velocity;
}

#pragma mark - Asteroids

-(NSMutableArray*)asteroidsForLevel:(int)level {
    NSMutableArray *asteroids = [NSMutableArray array];
    int numOfAsteroids = arc4random() % ([self maxNumberOfAsteroidsForLevel:level]+1);
    if (numOfAsteroids < [self minNumberOfAsteroidsForLevel:level]) {
        numOfAsteroids = [self minNumberOfAsteroidsForLevel:level];
    }
    for (int j = 0; j < numOfAsteroids; j++) {
        SKSpriteNode *asteroid = [self randomAsteroidForLevel:level];
        [self randomizeSprite:asteroid];
        if (level == 1) {
            asteroid.position = CGPointMake(asteroid.position.x, self.frame.size.height/4 * 3);
            asteroid.physicsBody.velocity = CGVectorMake(0, 0);
        }
        asteroid.hidden = YES;
        [asteroids addObject:asteroid];
    }

    return asteroids;
}

-(int)maxAsteroidNumForLevel:(int)level {
    if (level <= 2) {
        return 1;
    } else if (level <= 5) {
        return 2;
    } else if (level <= 10) {
        return 3;
    } else if (level <= 15) {
        return 4;
    } else if (level <= 20) {
        return 5;
    } else if (level <= 25) {
        return 6;
    } else if (level <= 30) {
        return 7;
    } else if (level <= 35) {
        return 8;
    } else if (level <= 40) {
        return 9;
    } else if (level <= 45) {
        return 10;
    } else if (level <= 55) {
        return 11;
    } else {
        return 12;
    }
}

-(int)maxNumberOfAsteroidsForLevel:(int)level {
    if (level <= 1) {
        return 1;
    } else if (level <= 2) {
        return 2;
    } else if (level <= 7) {
        return 3;
    } else if (level <= 15) {
        return 4;
    } else if (level <= 30) {
        return 5;
    } else if (level <= 40) {
        return 6;
    } else if (level <= 45) {
        return 7;
    } else if (level <= 50) {
        return 8;
    } else if (level <= 60) {
        return 9;
    } else {
        return 10;
    }
}

-(int)minNumberOfAsteroidsForLevel:(int)level {
    if (level <= 1) {
        return 1;
    } else if (level <= 2) {
        return 2;
    } else if (level <= 25) {
        return 3;
    } else if (level <= 35) {
        return 4;
    } else if (level <= 50) {
        return 5;
    } else if (level <= 65) {
        return 6;
    } else if (level <= 70) {
        return 7;
    } else if (level <= 75) {
        return 8;
    } else if (level <= 90) {
        return 9;
    } else {
        return 10;
    }
}

-(SKSpriteNode*)randomAsteroidForLevel:(int)level {
    int asteroidNum = arc4random() % [self maxAsteroidNumForLevel:level];
    NSString *imageName = [NSString stringWithFormat:@"Asteroid_%d",asteroidNum];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:imageName]];
    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForAsteroidNum:asteroidNum withSprite:sprite]];
    sprite.physicsBody.friction = 0.0f;
    sprite.physicsBody.restitution = 1.0f;
    sprite.physicsBody.linearDamping = 0.0f;
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.categoryBitMask = asteroidCategory;
    sprite.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | shipCategory | asteroidCategory | asteroidInShieldCategory | planetCategory | asteroidShieldCategory | powerUpSpaceMineExplodingRingCategory;
    sprite.physicsBody.contactTestBitMask = goalCategory | shipCategory | asteroidShieldCategory;

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
    sprite.zPosition = 1;
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


#pragma mark - Planets

-(NSMutableArray*)planetsForLevel:(int)level {
    NSMutableArray *planets = [NSMutableArray array];
    int numOfPlanets = arc4random() % ([self maxNumberOfPlanetsForLevel:level] + 1);
    if (numOfPlanets < [self minNumberOfPlanetsForLevel:level]) {
        numOfPlanets = [self minNumberOfPlanetsForLevel:level];
    }
    BOOL forceSun = NO;
    if (level > 25) {
        if (arc4random() % 8 == 0) {
            forceSun = YES;
        }
    }
    for (int j = 0; j < numOfPlanets; j++) {
        SKSpriteNode *planet;
        if (j == 0 && forceSun) {
            planet = [self randomSun];
        } else {
            planet = [self randomPlanetForLevel:level sunFlavor:forceSun currentPlanets:planets];
        }
        planet.hidden = YES;
        float thisWidth;
        if ([planet.userData[planetNumber] intValue] == 5) {
            thisWidth = largePlanetWidth;
        } else if (planet.size.width >= planet.size.height) {
            thisWidth = planet.size.width;
        } else {
            thisWidth = planet.size.height;
        }
        CGPoint thisCenter = planet.position;
        float otherWidthA, otherWidthB;
        CGPoint otherCenterA, otherCenterB;
        float distanceA, distanceB;
        distanceA = distanceB = MAXFLOAT;
        otherWidthA = otherWidthB = 0;
        if (planets.count > 0) {
            SKSpriteNode *otherPlanetA = planets[0];
            if ([otherPlanetA.userData[planetNumber] intValue] == 5) {
                otherWidthA = largePlanetWidth;
            } else if (otherPlanetA.size.width >= otherPlanetA.size.height) {
                otherWidthA = otherPlanetA.size.width;
            } else {
                otherWidthA = otherPlanetA.size.height;
            }
            otherCenterA = otherPlanetA.position;
            distanceA = sqrtf(powf(thisCenter.x - otherCenterA.x, 2) + pow(thisCenter.y - otherCenterA.y, 2));
        }
        if (planets.count > 1) {
            SKSpriteNode *otherPlanetB = planets[1];
            if ([otherPlanetB.userData[planetNumber] intValue] == 5) {
                otherWidthB = largePlanetWidth;
            } else if (otherPlanetB.size.width >= otherPlanetB.size.height) {
                otherWidthB = otherPlanetB.size.width;
            } else {
                otherWidthB = otherPlanetB.size.height;
            }
            otherCenterB = otherPlanetB.position;
            distanceB = sqrtf(powf(thisCenter.x - otherCenterB.x, 2) + pow(thisCenter.y - otherCenterB.y, 2));
        }
        BOOL addPlanet = YES;
        int attempt = 0;
        while ((distanceA - (thisWidth/2) - (otherWidthA/2) < ((SKSpriteNode*)[self childNodeWithName:shipCategoryName]).size.width + 10) ||
               (distanceB - (thisWidth/2) - (otherWidthB/2) < ((SKSpriteNode*)[self childNodeWithName:shipCategoryName]).size.width + 10)) {
            if (attempt > 200) {
                addPlanet = NO;
                break;
            }
            [self randomizeSprite:planet];
            if ([planet.userData[planetNumber] intValue] == 5) {
                [self adjustGiantPlanet:planet];
            }
            thisCenter = planet.position;
            if (planets.count > 0) {
                distanceA = sqrtf(powf(thisCenter.x - otherCenterA.x, 2) + pow(thisCenter.y - otherCenterA.y, 2));
            }
            if (planets.count > 1) {
                distanceB = sqrtf(powf(thisCenter.x - otherCenterB.x, 2) + pow(thisCenter.y - otherCenterB.y, 2));
            }
            attempt++;
        }
        if (addPlanet) {
            if ([planet.userData[planetNumber] intValue] >= asteroidShield0) {
                float radius = [self radiusForPlanetNum:[planet.userData[planetNumber] intValue]];
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddArc(path, NULL, 0, 0, radius, 0, M_PI * 2, YES);
                planet.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
                planet.physicsBody.categoryBitMask = asteroidShieldCategory;
                planet.physicsBody.contactTestBitMask = asteroidShieldCategory;
            } else {
                planet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:[self radiusForPlanetNum:[planet.userData[planetNumber] intValue]]];
                planet.physicsBody.categoryBitMask = planetCategory;
                planet.physicsBody.contactTestBitMask = planetCategory;
                if (forceSun) {
                    planet.physicsBody.contactTestBitMask = shipCategory | asteroidCategory;
                }
            }
            planet.physicsBody.mass = 100000;
            planet.physicsBody.dynamic = YES;
            planet.physicsBody.collisionBitMask = shipCategory | asteroidCategory | asteroidInShieldCategory | asteroidShieldCategory;
            planet.physicsBody.allowsRotation = NO;
            if (![self addRingPhysicsBodyIfApplicableForPlanet:planet] && ![planet.name isEqualToString:sunObjectSpriteName] && [planet.userData[planetNumber] intValue] < 5) {
                planet.userData[moonsArray] = @[[self moonForPlanetNum:[planet.userData[planetNumber] intValue] withPlanet:planet]];
            }
            if ([planet.userData[planetNumber] intValue] >= asteroidShield0) {
                [self addAsteroidShieldAnimationsToSprite:planet];
            }
            [planets addObject:planet];
        }
    }
    NSMutableArray *asteroidsToAdd = [NSMutableArray array];
    int shieldCount = 0;
    BOOL bigPlanet = NO;
    for (SKSpriteNode *aPlanet in planets) {
        if ([aPlanet.userData[planetNumber] intValue] >= asteroidShield0) {
            aPlanet.userData[asteroidShieldTag] = @(shieldCount);
            aPlanet.zPosition = 10;
            int levelToUse = level;
            if (levelToUse > 14) {
                levelToUse = 14;
            }
            for (int i = 0; i < [aPlanet.userData[planetNumber] intValue]; i++) {
                SKSpriteNode *asteroid = [self randomAsteroidForLevel:levelToUse];
                asteroid.position = aPlanet.position;
                asteroid.zRotation = DegreesToRadians(arc4random() % 360);
                float velocity = 20;
                asteroid.physicsBody.velocity = CGVectorMake(velocity * cosf(asteroid.zRotation), velocity * -sinf(asteroid.zRotation));
                asteroid.name = asteroidInShieldCategoryName;
                asteroid.physicsBody.categoryBitMask = asteroidInShieldCategory;
                asteroid.physicsBody.collisionBitMask = shipCategory | asteroidCategory | asteroidInShieldCategory | planetCategory | asteroidShieldCategory;
                asteroid.physicsBody.contactTestBitMask = shipCategory | asteroidShieldCategory;
                asteroid.userData = [NSMutableDictionary new];
                asteroid.userData[asteroidShieldTag] = @(shieldCount);
                asteroid.zPosition = 0;
                [asteroidsToAdd addObject:asteroid];
            }
            shieldCount++;
        } else if ([aPlanet.userData[planetNumber] intValue] == 5) {
            bigPlanet = YES;
        }
    }
    [planets addObjectsFromArray:asteroidsToAdd];
    if (!forceSun && !bigPlanet) {
        if (arc4random() % 8 == 0 && level > 25) {
            [planets addObject:[self blackHole]];
        }
    }
    return planets;
}

-(BOOL)addRingPhysicsBodyIfApplicableForPlanet:(SKSpriteNode*)planet {
    if ([planet.userData[planetFlavorNumber] isEqualToNumber:@2] && [planet.userData[planetNumber] intValue] < 5) {
        SKSpriteNode *extraBodySprite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:planet.size];
        extraBodySprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForRingWithPlanetNum:[planet.userData[planetNumber] intValue] withSprite:planet]];
        extraBodySprite.physicsBody.dynamic = NO;
        extraBodySprite.physicsBody.categoryBitMask = planetCategory;
        extraBodySprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory;
        extraBodySprite.physicsBody.allowsRotation = NO;
        extraBodySprite.physicsBody.mass = 100000;
        [planet addChild:extraBodySprite];
        return YES;
    }
    return NO;
}

-(void)addAsteroidShieldAnimationsToSprite:(SKSpriteNode*)sprite {
    if (!sprite.userData) {
        sprite.userData = [NSMutableDictionary new];
    }
    NSString *imageName = @"AsteroidShield_Ring_0";
    float scale = 0.76;
    if ([sprite.userData[planetNumber] intValue] == asteroidShield1) {
        imageName = @"AsteroidShield_Ring_1";
        scale = 0.77;
    }
    float duration = 1;
    SKSpriteNode *ring1 = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    [sprite addChild:ring1];
    ring1.name = asteroidShieldRing1SpriteName;
    ring1.alpha = 0;
    [ring1 setScale:scale];
    SKAction *expandRingAction = [SKAction scaleTo:1 duration:duration];
    SKAction *alphaOutRingAction = [SKAction fadeAlphaTo:0 duration:duration];
    SKAction *groupAction = [SKAction group:@[expandRingAction,alphaOutRingAction,[SKAction waitForDuration:(duration+0.1)]]];
    SKAction *blockAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [node setScale:scale];
        [node setAlpha:1];
    }];
    SKAction *sequenceAction = [SKAction sequence:@[blockAction, groupAction]];
    SKAction *repeatAction = [SKAction repeatActionForever:sequenceAction];
    SKAction *animationAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        [[node childNodeWithName:asteroidShieldRing1SpriteName] runAction:repeatAction];
    }];
    sprite.userData[asteroidShieldPulseAnimationAction] = animationAction;
}

-(int)maxPlanetNumForLevel:(int)level {
    if (level <= 5) {
        return 1;
    } else if (level <= 10) {
        return 2;
    } else if (level <= 15) {
        return 3;
    } else if (level <= 20) {
        return 4;
    } else if (level <= 25) {
        return 5;
    } else {
        return 6;
    }
}

-(int)maxNumberOfPlanetsForLevel:(int)level {
    if (level <= 3) {
        return 0;
    } else if (level <= 10) {
        return 1;
    } else if (level <= 20) {
        return 2;
    } else {
        return 3;
    }
}

-(int)minNumberOfPlanetsForLevel:(int)level {
    if (level <= 15) {
        return 0;
    } else if (level <= 30) {
        return 1;
    } else {
        return 2;
    }
}

-(SKSpriteNode*)randomPlanetForLevel:(int)level sunFlavor:(BOOL)sunFlavor currentPlanets:planets {

    int planetNum = arc4random() % [self maxPlanetNumForLevel:level];
    int planetFlavor =  arc4random() % 3;
    if (sunFlavor) {
        planetFlavor = 3;
    }
    BOOL safeToContinue = NO;
    while (!safeToContinue) {
        safeToContinue = YES;
        for (SKSpriteNode *planet in planets) {
            if ([planet.userData[planetNumber] intValue] == planetNum &&
                [planet.userData[planetFlavorNumber] intValue] == planetFlavor) {
                safeToContinue = NO;
                planetNum = arc4random() % [self maxPlanetNumForLevel:level];
                planetFlavor =  arc4random() % 3;
                if (sunFlavor) {
                    planetFlavor = 3;
                }
                break;
            }
        }
    }
    NSString *imageName = [NSString stringWithFormat:@"Planet_%d_%d",planetNum, planetFlavor];
    BOOL isAsteroidShield = NO;
    if ((planetNum == 4 || planetNum == 3) && !sunFlavor) {
        if (arc4random() % 2 == 0) { //50%
            if (planetNum == 4) {
                imageName = @"AsteroidShield_1";
            } else {
                imageName = @"AsteroidShield_0";
            }
            isAsteroidShield = YES;
        }
    }
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:imageName]];
    
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
    if (planetNum == 5) {
        [self adjustGiantPlanet:sprite];
    }
    if (sunFlavor) {
        sprite.name = sunObjectSpriteName;
    } else if (isAsteroidShield) {
        sprite.name = asteroidShieldCategoryName;
    } else {
        sprite.name = planetCategoryName;
    }
    
    sprite.userData = [NSMutableDictionary dictionary];
    if (isAsteroidShield) {
        if (planetNum == 3) {
            sprite.userData[planetNumber] = @(asteroidShield0);
        } else {
            sprite.userData[planetNumber] = @(asteroidShield1);
        }
    } else {
        sprite.userData[planetNumber] = @(planetNum);
    }
    sprite.userData[planetFlavorNumber] = @(planetFlavor);
    sprite.zPosition = 1;
    return sprite;
}

-(SKSpriteNode*)randomSun {
    int planetNum = 5;
    NSString *imageName = [NSString stringWithFormat:@"Planet_%d_S",planetNum];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    
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
    sprite.position = CGPointMake(0, sprite.position.y);
    if (planetNum == 5) {
        [self adjustGiantPlanet:sprite];
    }
    sprite.name = sunObjectSpriteName;
    
    sprite.userData = [NSMutableDictionary dictionary];
    sprite.userData[planetNumber] = @(planetNum);
    sprite.userData[planetFlavorNumber] = @(4);
    sprite.zPosition = 1;
    sprite.zRotation =arc4random() % 360;
    return sprite;

}

-(void)adjustGiantPlanet:(SKSpriteNode*)planet {
    float additionalDistance = 175;
    if (planet.position.x > self.frame.size.width/2) {
        [planet setPosition:CGPointMake((planet.frame.size.width/2) + self.frame.size.width - additionalDistance,planet.position.y)];
    } else {
        [planet setPosition:CGPointMake((planet.frame.size.width/-2) + additionalDistance ,planet.position.y)];
    }
}

-(SKSpriteNode*)moonForPlanetNum:(int)planetNum withPlanet:(SKSpriteNode*)planet {
    NSString *imageName = [NSString stringWithFormat:@"Asteroid_%d",planetNum];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:imageName]];
    float distance = planet.size.width/2 + sprite.size.width/2;
    float angle = arc4random() % 360;
    sprite.position = CGPointMake(planet.position.x + (cosf(DegreesToRadians(angle)) * distance), planet.position.y + (sinf(DegreesToRadians(angle)) * distance)) ;

    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForAsteroidNum:planetNum withSprite:sprite]];
    sprite.physicsBody.friction = 0.0f;
    sprite.physicsBody.restitution = 1.0f;
    sprite.physicsBody.linearDamping = 0.0f;
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.categoryBitMask = asteroidCategory;
    sprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory | planetCategory | powerUpSpaceMineExplodingRingCategory;
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
    sprite.name = asteroidCategoryName;
    SKPhysicsJointPin *centerPin = [SKPhysicsJointPin jointWithBodyA:sprite.physicsBody bodyB: planet.physicsBody anchor:planet.position];
    sprite.userData = [NSMutableDictionary dictionary];
    sprite.userData[orbitJoint] = centerPin;
    sprite.hidden = YES;
    sprite.zPosition = 1;
    return sprite;
}

-(float)radiusForPlanetNum:(int)planetNum {
    switch (planetNum) {
        case 0:
            return 25.0f;
            break;
        case 1:
            return 32.5f;
            break;
        case 2:
            return 40.5f;
            break;
        case 3:
            return 50.0f;
            break;
        case 4:
            return 60.0f;
            break;
        case 5:
            return 325.f;
            break;
        case asteroidShield0:
            return 50.0;
            break;
        case asteroidShield1:
            return 60.0f;
        default:
            return 30.f;
            break;
    }
}

-(CGMutablePathRef)pathForRingWithPlanetNum:(int)planetNum withSprite:(SKSpriteNode*)sprite {
    CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
    CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    
    switch (planetNum) {
        case 0: {
            CGPathMoveToPoint(path, NULL, 30 - offsetX, 37 - offsetY);
            CGPathAddLineToPoint(path, NULL, 21 - offsetX, 38 - offsetY);
            CGPathAddLineToPoint(path, NULL, 5 - offsetX, 37 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 34 - offsetY);
            CGPathAddLineToPoint(path, NULL, 0 - offsetX, 31 - offsetY);
            CGPathAddLineToPoint(path, NULL, 12 - offsetX, 24 - offsetY);
            CGPathAddLineToPoint(path, NULL, 32 - offsetX, 17 - offsetY);
            CGPathAddLineToPoint(path, NULL, 89 - offsetX, 8 - offsetY);
            CGPathAddLineToPoint(path, NULL, 104 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path, NULL, 108 - offsetX, 15 - offsetY);
            CGPathAddLineToPoint(path, NULL, 89 - offsetX, 26 - offsetY);
        }
            break;
        case 1: {
            CGPathMoveToPoint(path, NULL, 37 - offsetX, 46 - offsetY);
            CGPathAddLineToPoint(path, NULL, 14 - offsetX, 36 - offsetY);
            CGPathAddLineToPoint(path, NULL, 8 - offsetX, 27 - offsetY);
            CGPathAddLineToPoint(path, NULL, 9 - offsetX, 23 - offsetY);
            CGPathAddLineToPoint(path, NULL, 20 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 45 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 111 - offsetX, 36 - offsetY);
            CGPathAddLineToPoint(path, NULL, 125 - offsetX, 43 - offsetY);
            CGPathAddLineToPoint(path, NULL, 131 - offsetX, 50 - offsetY);
            CGPathAddLineToPoint(path, NULL, 129 - offsetX, 55 - offsetY);
            CGPathAddLineToPoint(path, NULL, 119 - offsetX, 58 - offsetY);
            CGPathAddLineToPoint(path, NULL, 96 - offsetX, 58 - offsetY);
        }
            break;
        case 2: {
            CGPathMoveToPoint(path, NULL, 38 - offsetX, 81 - offsetY);
            CGPathAddLineToPoint(path, NULL, 28 - offsetX, 76 - offsetY);
            CGPathAddLineToPoint(path, NULL, 17 - offsetX, 67 - offsetY);
            CGPathAddLineToPoint(path, NULL, 10 - offsetX, 55 - offsetY);
            CGPathAddLineToPoint(path, NULL, 7 - offsetX, 44 - offsetY);
            CGPathAddLineToPoint(path, NULL, 10 - offsetX, 31 - offsetY);
            CGPathAddLineToPoint(path, NULL, 19 - offsetX, 19 - offsetY);
            CGPathAddLineToPoint(path, NULL, 29 - offsetX, 12 - offsetY);
            CGPathAddLineToPoint(path, NULL, 41 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path, NULL, 68 - offsetX, 4 - offsetY);
            
            SKSpriteNode *extraBodySprite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:sprite.size];
            CGMutablePathRef path2 = CGPathCreateMutable();
            CGPathMoveToPoint(path2, NULL, 84 - offsetX, 81 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 99 - offsetX, 73 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 109 - offsetX, 62 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 114 - offsetX, 50 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 114 - offsetX, 39 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 108 - offsetX, 25 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 100 - offsetX, 16 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 91 - offsetX, 10 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 80 - offsetX, 6 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 68 - offsetX, 4 - offsetY);
            CGPathAddLineToPoint(path2, NULL, 58 - offsetX, 4 - offsetY);
            CGPathCloseSubpath(path2);
            extraBodySprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path2];
            extraBodySprite.physicsBody.dynamic = NO;
            extraBodySprite.physicsBody.categoryBitMask = planetCategory;
            extraBodySprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory | planetCategory;
            extraBodySprite.physicsBody.allowsRotation = NO;
            [sprite addChild:extraBodySprite];

        }
            break;
        case 3: {
            CGPathMoveToPoint(path, NULL, 34 - offsetX, 80 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 73 - offsetY);
            CGPathAddLineToPoint(path, NULL, 4 - offsetX, 64 - offsetY);
            CGPathAddLineToPoint(path, NULL, 3 - offsetX, 54 - offsetY);
            CGPathAddLineToPoint(path, NULL, 13 - offsetX, 42 - offsetY);
            CGPathAddLineToPoint(path, NULL, 37 - offsetX, 32 - offsetY);
            CGPathAddLineToPoint(path, NULL, 123 - offsetX, 32 - offsetY);
            CGPathAddLineToPoint(path, NULL, 144 - offsetX, 40 - offsetY);
            CGPathAddLineToPoint(path, NULL, 157 - offsetX, 56 - offsetY);
            CGPathAddLineToPoint(path, NULL, 155 - offsetX, 63 - offsetY);
            CGPathAddLineToPoint(path, NULL, 142 - offsetX, 73 - offsetY);
            CGPathAddLineToPoint(path, NULL, 125 - offsetX, 80 - offsetY);
        }
            break;
        case 4: {
            CGPathMoveToPoint(path, NULL, 24 - offsetX, 57 - offsetY);
            CGPathAddLineToPoint(path, NULL, 10 - offsetX, 20 - offsetY);
            CGPathAddLineToPoint(path, NULL, 10 - offsetX, 7 - offsetY);
            CGPathAddLineToPoint(path, NULL, 16 - offsetX, 5 - offsetY);
            CGPathAddLineToPoint(path, NULL, 27 - offsetX, 12 - offsetY);
            CGPathAddLineToPoint(path, NULL, 53 - offsetX, 39 - offsetY);
            CGPathAddLineToPoint(path, NULL, 114 - offsetX, 137 - offsetY);
            CGPathAddLineToPoint(path, NULL, 129 - offsetX, 179 - offsetY);
            CGPathAddLineToPoint(path, NULL, 128 - offsetX, 187 - offsetY);
            CGPathAddLineToPoint(path, NULL, 125 - offsetX, 190 - offsetY);
            CGPathAddLineToPoint(path, NULL, 111 - offsetX, 182 - offsetY);
            CGPathAddLineToPoint(path, NULL, 85 - offsetX, 155 - offsetY);
        }
            break;
        default:
            break;
    }
    
    CGPathCloseSubpath(path);
    return path;
}

#pragma mark - Extra

- (CGFloat) pointPairToBearingDegrees:(CGPoint)startingPoint secondPoint:(CGPoint) endingPoint {
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}


@end
