//
//  GameScene
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/5/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#define kExtraSpaceOffScreen 67
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

#define kAsteroidSpriteArrayKey @"kAsteroidSpriteArrayKey%d"
#define kPlanetSpriteArrayKey @"kPlanetSpriteArrayKey%d"
#define kPlanetHoverActionKey @"kPlanetHoverActionKey"

#import "GameScene.h"
#import "HexColor.h"
#import "UpgradeScene.h"
#import "AudioController.h"
#import "PhysicsContstants.h"
#import "SpriteUserDataConstants.h"
#import "BlackHole.h"
#import "SessionM.h"
#import "BaseSprite.h"

@implementation GameScene  {
    NSMutableArray *spritesArrays;
    NSMutableArray *starSprites;
    NSMutableArray *currentSpriteArray;
    NSMutableArray *backgroundNodes;
    NSMutableArray *planetPreRenderArray;
    NSNumber *safeToTransition;
    BaseSprite *starBackLayer;
    BaseSprite *starFrontLayer;
    BaseSprite *alternateBackLayer;
    BaseSprite *alternateFrontLayer;
    BaseSprite *currentFrontLayer;
    BaseSprite *currentBackLayer;
    BaseSprite *shipSprite, *currentBlackHole, *explodingMine, *explodedMine, *explodingNuke;
    BaseSprite *shieldPowerUpSprite, *minePowerUpSprite;
    SKLabelNode *levelNode, *parsecsNode;
    BOOL shipWarping;
    BOOL hasShield;
    BOOL showingSun;
    BOOL advanceLevel;
    BOOL nukeUsedThisLevel;
    int possibleBubblesPopped, lastShieldLevel, lastMineLevel;
    
    NSInteger shieldHitPoints;
    NSInteger shipHitPoints;
    
    UIPanGestureRecognizer *flickRecognizer;
    UITapGestureRecognizer *tapRecognizer;
    BOOL showGameCenter, walkthroughSeen;
    int lastLevelPanned;
    NSTimeInterval lastTimeHit;
    int timesHitWithinSecond;
    int sceneHeight, sceneWidth, viewHeight;
    
    SKAction *shieldUpSoundAction;
    SKAction *shieldDownSoundAction;
    SKAction *shieldHitSoundAction;
    SKAction *spaceMineSoundAction;
    SKAction *playerDeathSoundAction;
    SKAction *asteroidSunSoundAction;
    SKAction *asteroidSunDeathAction;
    SKAction *asteroidMineDeathAction;
    SKAction *blackholeDeathAction;

    CGPoint lastShipPosition, pendingVelocity;
    CGSize shipSize;
    
    int shieldDurabilityLevel, shieldOnStart, shieldOccuranceLevel, mineBlastSpeedLevel, mineOccuranceLevel, sfxSetting, holsterNukes, holsterCapacity;
}

static NSMutableArray *backgroundTextures;
static NSMutableArray *planetTextures;
static NSMutableArray *asteroidTextures;
static NSMutableArray *powerUpTextures;
static NSMutableArray *spaceMineTextures;
static NSMutableArray *impactSpriteArrays;
static NSMutableArray *holsterNukeSpritesArray;
static NSMutableDictionary *asteroidSpritesDictionary;
static NSMutableDictionary *planetSpritesDictionary;

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * (M_PI / 180);
};


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        sceneHeight = self.frame.size.height;
        sceneWidth = self.frame.size.width;
        
        [self setDefaultValues];
        
        walkthroughSeen = [ABIMSIMDefaults boolForKey:kWalkthroughSeen];
        self.initialPause = !walkthroughSeen;

        shieldUpSoundAction = [SKAction playSoundFileNamed:@"activateShieldTrimmed.caf" waitForCompletion:NO];
        shieldDownSoundAction = [SKAction playSoundFileNamed:@"deactivateShieldTrimmed.caf" waitForCompletion:NO];
        shieldHitSoundAction = [SKAction playSoundFileNamed:@"deactivateShieldTrimmed.caf" waitForCompletion:NO];
        spaceMineSoundAction = [SKAction playSoundFileNamed:@"explosionMineTrimmed.caf" waitForCompletion:NO];
        playerDeathSoundAction = [SKAction playSoundFileNamed:@"explosionTrimmed.caf" waitForCompletion:NO];
        asteroidSunSoundAction = [SKAction playSoundFileNamed:@"asteroidSun.caf" waitForCompletion:NO];
        
        SKAction *changeColorAction = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1 duration:0.25];
        SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.3];
        SKAction *groupAction = [SKAction group:@[changeColorAction, fadeOut]];
        asteroidSunDeathAction = groupAction;
        
        changeColorAction = [SKAction colorizeWithColor:[UIColor greenColor] colorBlendFactor:1 duration:0.1];
        fadeOut = [SKAction fadeAlphaTo:0 duration:0.15];
        groupAction = [SKAction group:@[changeColorAction, fadeOut]];
        asteroidMineDeathAction = groupAction;
        
        float duration = 0.25;
        blackholeDeathAction = [SKAction group:@[[SKAction moveTo:CGPointZero duration:duration],
                                                  [SKAction scaleTo:0 duration:duration]]];

        
        lastTimeHit = 0;
        timesHitWithinSecond = 0;
        
        if (!backgroundTextures) {
            backgroundTextures = [NSMutableArray arrayWithCapacity:8];
            for (int j = 0; j < 10; j++) {
                NSString *textureName = [NSString stringWithFormat:@"Background_%d", j];
                NSLog(@"%@",textureName);
                [backgroundTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:textureName]]];
            }
        }
        [SKTexture preloadTextures:backgroundTextures withCompletionHandler:^{
            ;
        }];
        
        if (!planetTextures) {
            planetTextures = [NSMutableArray array];
            for (int i = 0; i < 6; i++) {
                for (int j = 0; j < 4; j++) {
                    NSString *textureName = [NSString stringWithFormat:@"Planet_%d_%d", i, j];
                    NSLog(@"%@",textureName);
                    [planetTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:textureName]]];
                }
            }
            [planetTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"Planet_4_4"]]];
            [planetTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"Planet_5_S"]]];
            [planetTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"AsteroidShield_0"]]];
            [planetTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"AsteroidShield_1"]]];
        }
        [SKTexture preloadTextures:planetTextures withCompletionHandler:^{
            planetPreRenderArray = [NSMutableArray new];
            for (SKTexture *planetTexture in planetTextures) {
                BaseSprite *planet = [[BaseSprite alloc] initWithTexture:planetTexture];
                planet.zPosition = -1000;
                [self insertChild:planet atIndex:0];
                [planetPreRenderArray addObject:planet];
            }
        }];
        
        if (!asteroidTextures) {
            asteroidTextures = [NSMutableArray array];
            for (int i = 0; i < 12; i++) {
                NSString *textureName = [NSString stringWithFormat:@"Asteroid_%d", i];
                NSLog(@"%@",textureName);
                [asteroidTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:textureName]]];
            }
        }
        [SKTexture preloadTextures:asteroidTextures withCompletionHandler:^{
            ;
        }];
        
        if (!asteroidSpritesDictionary) {
            asteroidSpritesDictionary = [NSMutableDictionary new];
            for (int i = 0; i < 12; i++) {
                NSMutableArray *asteroidsArray = [NSMutableArray arrayWithCapacity:10];
                for (int j = 0; j < 10; j++) {
                    BaseSprite *sprite = [BaseSprite spriteNodeWithTexture:asteroidTextures[i]];
                    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForAsteroidNum:i withSprite:sprite]];
                    sprite.physicsBody.friction = 0.0f;
                    sprite.physicsBody.restitution = 1.0f;
                    sprite.physicsBody.linearDamping = 0.0f;
                    sprite.physicsBody.dynamic = YES;
                    sprite.physicsBody.categoryBitMask = asteroidCategory;
                    sprite.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | shipCategory | asteroidCategory | asteroidInShieldCategory | planetCategory | planetRingCategory | asteroidShieldCategory;
                    sprite.physicsBody.contactTestBitMask = goalCategory | shipCategory | asteroidShieldCategory | powerUpSpaceMineExplodingRingCategory;
                    sprite.physicsBody.mass = sprite.size.width;
                    sprite.name = asteroidCategoryName;
                    sprite.physicsBody.allowsRotation = YES;
                    sprite.colorBlendFactor = 1.0;
                    sprite.zPosition = 1;
                    sprite.userData = [NSMutableDictionary dictionary];
                    sprite.userData[asteroidsIndex] = @(i);
                    [asteroidsArray addObject:sprite];
                }
                [asteroidSpritesDictionary setObject:asteroidsArray forKey:[NSString stringWithFormat:kAsteroidSpriteArrayKey,i]];
            }
        }
        if (!planetSpritesDictionary) {
            planetSpritesDictionary = [NSMutableDictionary new];
            for (int i = 0; i < 6; i++) {
                for (int j = 0; j < 4; j++) {
                    int planetIndex = i * 4 + j;
                    SKTexture *planetTexture = [planetTextures objectAtIndex:planetIndex];
                    BaseSprite* sprite = [BaseSprite spriteNodeWithTexture:planetTexture];
                    if (j == 3) {
                        sprite.name = sunObjectSpriteName;
                    } else {
                        sprite.name = planetCategoryName;
                    }

                    sprite.userData = [NSMutableDictionary dictionary];
                    sprite.userData[planetNumber] = @(i);
                    sprite.userData[planetFlavorNumber] = @(j);
                    sprite.userData[planetsIndex] = @(planetIndex);
                    sprite.zPosition = 1;
                    [planetSpritesDictionary setObject:@[sprite].mutableCopy forKey:[NSString stringWithFormat:kPlanetSpriteArrayKey,planetIndex]];
                }
            }
            for (int i = 0; i < 4; i++) {
                [planetSpritesDictionary setObject:[NSMutableArray new] forKey:[NSString stringWithFormat:kPlanetSpriteArrayKey,(int)[planetSpritesDictionary allKeys].count]];
            }
        }
        
        if (!spaceMineTextures) {
            spaceMineTextures = [NSMutableArray array];
            for (int i = 0; i < 9; i++) {
                NSString *textureName = [NSString stringWithFormat:@"SpaceMine_Friendly_%d", i];
                NSLog(@"%@",textureName);
                [spaceMineTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:textureName]]];
            }
        }
        
        [SKTexture preloadTextures:spaceMineTextures withCompletionHandler:^{
            ;
        }];

        [BlackHole blackHole];
        
        if (!powerUpTextures) {
            powerUpTextures = [NSMutableArray arrayWithCapacity:5];
            [powerUpTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"SpaceMine_ExplodingRing_0"]]];
            [powerUpTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"SpaceMine_LargeGlow_0"]]];
            [powerUpTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"SpaceMine_CenterGlow_0"]]];
            
            [powerUpTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"ShieldPowerUp"]]];
            [powerUpTextures addObject:[SKTexture textureWithImage:[UIImage imageNamed:@"ShieldPowerUp_Animated"]]];
        }
        [SKTexture preloadTextures:powerUpTextures withCompletionHandler:^{
            ;
        }];
        
        if (!impactSpriteArrays) {
            impactSpriteArrays = [NSMutableArray arrayWithCapacity:2];
            NSMutableArray *smallerImpactArray = [NSMutableArray arrayWithCapacity:10];
            for (int i = 0; i < 10; i++) {
                BaseSprite *impactSprite = [BaseSprite spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"AsteroidShield_Impact_0"]]];
                SKAction *prepair = [SKAction runBlock:^{
                    impactSprite.alpha = 1;
                }];
                SKAction *fadeAway = [SKAction fadeAlphaTo:0 duration:0.5];
                impactSprite.userData = [NSMutableDictionary dictionary];
                impactSprite.userData[asteroidShieldImpactAnimation] = [SKAction sequence:@[prepair, fadeAway]];
                impactSprite.userData[planetNumber] = @(asteroidShield0);
                impactSprite.name = asteroidShieldImpactSpriteName;
                [smallerImpactArray addObject:impactSprite];
            }
            [impactSpriteArrays addObject:smallerImpactArray];
            NSMutableArray *largerImpactArray = [NSMutableArray arrayWithCapacity:10];
            for (int i = 0; i < 10; i++) {
                BaseSprite *impactSprite = [BaseSprite spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"AsteroidShield_Impact_1"]]];
                SKAction *prepair = [SKAction runBlock:^{
                    impactSprite.alpha = 1;
                }];
                SKAction *fadeAway = [SKAction fadeAlphaTo:0 duration:0.5];
                impactSprite.userData = [NSMutableDictionary dictionary];
                impactSprite.userData[asteroidShieldImpactAnimation] = [SKAction sequence:@[prepair, fadeAway]];
                impactSprite.userData[planetNumber] = @(asteroidShield1);
                impactSprite.name = asteroidShieldImpactSpriteName;
                [largerImpactArray addObject:impactSprite];
            }
            [impactSpriteArrays addObject:largerImpactArray];
        }
        
        if (!holsterNukeSpritesArray) {
            holsterNukeSpritesArray = [NSMutableArray arrayWithCapacity:10];
            int gap = 5;
            int baseX = self.size.width/2 + (16*3) + (gap * 3) - 1;
            for (int i = 0; i < 10; i++) {
                BaseSprite *holsterNukeSprite = [BaseSprite spriteNodeWithImageNamed:@"AvailableHolster_"];
                holsterNukeSprite.position = CGPointMake(baseX - holsterNukeSprite.size.width/2 - ((holsterNukeSprite.size.width + gap) * i), 22.5);
                holsterNukeSprite.alpha = 0;
                holsterNukeSprite.zPosition = 1000;
                [holsterNukeSpritesArray insertObject:holsterNukeSprite atIndex:0];
            }
        }
        for (BaseSprite *holsterNukeSprite in holsterNukeSpritesArray) {
            [holsterNukeSprite removeFromParent];
            [self addChild:holsterNukeSprite];
            holsterNukeSprite.alpha = 0;
        }
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, -kExtraSpaceOffScreen, size.width, size.height+kExtraSpaceOffScreen*2)];
        borderBody.categoryBitMask = borderCategory;
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        self.physicsWorld.contactDelegate = self;
        
        backgroundNodes = [NSMutableArray new];
        for (int i = 0; i < backgroundTextures.count; i++) {
            BaseSprite *backgroundNode = [BaseSprite spriteNodeWithTexture:backgroundTextures[i]];
            backgroundNode.alpha = 1;
            backgroundNode.size = self.size;
            backgroundNode.anchorPoint = CGPointZero;
            backgroundNode.zPosition = -1;
            backgroundNode.userData = [NSMutableDictionary new];
            backgroundNode.userData[backgroundNodeAlphaInAction] = [SKAction fadeAlphaTo:1 duration:0.5];
            backgroundNode.userData[backgroundNodeAlphaOutAction] = [SKAction fadeAlphaTo:0 duration:0.5];
            [self insertChild:backgroundNode atIndex:0];
            [backgroundNodes addObject:backgroundNode];
        }
        
        BaseSprite *secondaryBorderSprite = [BaseSprite spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height+kExtraSpaceOffScreen)];
        secondaryBorderSprite.anchorPoint = CGPointZero;
        secondaryBorderSprite.position = CGPointZero;
        SKPhysicsBody* secondaryBorderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, size.width, size.height+kExtraSpaceOffScreen)];
        secondaryBorderBody.friction = 0.0f;
        secondaryBorderBody.categoryBitMask = secondaryBorderCategory;
        secondaryBorderSprite.physicsBody = secondaryBorderBody;
        [self addChild:secondaryBorderSprite];

        starBackLayer = [[BaseSprite alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height * starBackMovement)];
        alternateBackLayer = [[BaseSprite alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height * starBackMovement)];
        starFrontLayer = [[BaseSprite alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height * starFrontMovement)];
        alternateFrontLayer = [[BaseSprite alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(size.width, size.height * starFrontMovement)];

        starFrontLayer.anchorPoint = alternateFrontLayer.anchorPoint = CGPointZero;
        starBackLayer.anchorPoint = alternateBackLayer.anchorPoint = CGPointZero;
        starBackLayer.position = starFrontLayer.position = alternateBackLayer.position = alternateFrontLayer.position = CGPointMake(0, 0);
//        [self addChild:starBackLayer];
//        [self addChild:starFrontLayer];

        lastShieldLevel = lastMineLevel = 0;
        
        hasShield = shieldOnStart;
        if (hasShield) {
            shieldHitPoints = 1 + shieldDurabilityLevel;
        } else {
            shieldHitPoints = 0;
        }
        shipHitPoints = 1;
        shipSprite = [self createShip];
        [self addSpaceMineExplosionRingAnimationsToSprite:shipSprite];

        spritesArrays = [NSMutableArray array];
        currentSpriteArray = [NSMutableArray array];
        
        levelNode = [[SKLabelNode alloc] initWithFontNamed:@"Moki-Lean"];
        levelNode.alpha = 0.7f;
        levelNode.fontSize = 15;
        levelNode.text = [NSString stringWithFormat:@"%d",self.currentLevel];
        levelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        levelNode.position = CGPointMake(15, 15);
        levelNode.zPosition = 100;
        levelNode.name = levelNodeName;
        levelNode.hidden = YES;
        [self addChild:levelNode];
        
        parsecsNode = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
        parsecsNode.alpha = 0.7f;
        parsecsNode.fontSize = 12;
        parsecsNode.text = @"PARSEC";
        parsecsNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        parsecsNode.position = CGPointMake(levelNode.position.x + levelNode.frame.size.width + 1, 16);
        parsecsNode.zPosition = 100;
        parsecsNode.name = levelParsecsNodeName;
        parsecsNode.hidden = YES;
        [self addChild:parsecsNode];
        
        shipWarping = YES;

        [self addChild:shipSprite];
        [self updateShipPhysics];

        shipSprite.physicsBody.collisionBitMask = borderCategory | asteroidCategory | planetCategory | planetRingCategory;
        
        CGRect goalRect;
        goalRect = CGRectMake(self.frame.origin.x, sceneHeight + kExtraSpaceOffScreen, sceneWidth, 15);
        SKNode* goal = [SKNode node];
        goal.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:goalRect];
        goal.name = goalCategoryName;
        goal.physicsBody.categoryBitMask = goalCategory;
        [self addChild:goal];

        [self generateInitialLevelsAndShowSprites:NO];
        safeToTransition = @YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

-(void)setDefaultValues {
    shieldDurabilityLevel = (int)[ABIMSIMDefaults integerForKey:kShieldDurabilityLevel];
    shieldOnStart = (int)[ABIMSIMDefaults integerForKey:kShieldOnStart];
    shieldOccuranceLevel = (int)[ABIMSIMDefaults integerForKey:kShieldOccuranceLevel];
    mineBlastSpeedLevel = (int)[ABIMSIMDefaults integerForKey:kMineBlastSpeedLevel];
    mineOccuranceLevel = (int)[ABIMSIMDefaults integerForKey:kMineOccuranceLevel];
    sfxSetting = (int)[ABIMSIMDefaults integerForKey:kSFXSetting];
    holsterNukes = (int)[ABIMSIMDefaults integerForKey:kHolsterNukes];
    holsterCapacity = (int)[ABIMSIMDefaults integerForKey:kHolsterCapacity];
}

-(void)configureHolsterNukeSprites {
    if (holsterCapacity == 0) {
        for (BaseSprite *holsterNuke in holsterNukeSpritesArray) {
            holsterNuke.alpha = 0;
        }
        parsecsNode.alpha = 0.7;
        return;
    }
    parsecsNode.alpha = 0;
    for (int i = 0; i < holsterNukes; i++) {
        BaseSprite *holsterNuke = holsterNukeSpritesArray[i];
        holsterNuke.alpha = 1;
        [holsterNuke setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"FullHolster_"]]];
        if (!holsterNuke.parent) {
            [self addChild:holsterNuke];
        }
    }
    for (int i = holsterNukes; i < holsterCapacity; i++) {
        BaseSprite *holsterNuke = holsterNukeSpritesArray[i];
        holsterNuke.alpha = 1;
        [holsterNuke setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"AvailableHolster_"]]];
        if (!holsterNuke.parent) {
            [self addChild:holsterNuke];
        }
    }
    for (int i = holsterCapacity; i < 10; i++) {
        BaseSprite *holsterNuke = holsterNukeSpritesArray[i];
        holsterNuke.alpha = 0.4;
        [holsterNuke setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"AvailableHolster_"]]];
        if (!holsterNuke.parent) {
            [self addChild:holsterNuke];
        }
    }
}

-(void)applicationWillResignActive {
    if (self.viewController.mainMenuView.alpha == 0 &&
        self.viewController.pausedView.alpha == 0 &&
        self.viewController.gameOverView.alpha == 0 &&
        self.viewController.upgradesView.alpha == 0 &&
        !self.initialPause) {
        [self pause];
    }
}

-(void)applicationDidBecomeActive {
    if (self.viewController.pausedView.alpha != 0) {
        self.view.paused = YES;
    }
}

-(void)transitionFromMainMenu {
    self.view.paused = NO;
    [self setDefaultValues];
    [[AudioController sharedController] gameplay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    self.currentLevel = 0;
    [self transitionStars];
    self.currentLevel = 1;
    [self showCurrentSprites];
    [self showTutorialIfNeeded];
    self.viewController.pauseButton.hidden = NO;
    self.viewController.pauseButton.alpha = 0;
    levelNode.hidden = NO;
    levelNode.alpha = 0;
    parsecsNode.hidden = NO;
    parsecsNode.alpha = 0;

    if (!walkthroughSeen) {
        [shipSprite runAction:[SKAction moveTo:CGPointMake(sceneWidth/2, shipSize.height*2) duration:0.5] completion:^{
            self.view.paused = NO;
            self.initialPause = YES;
            [self configureGestureRecognizers:YES];
            
        }];
        SKAction *move = [SKAction moveTo:CGPointMake(sceneWidth/2, sceneHeight/2) duration:0.5];
        SKAction *alphaIn = [SKAction fadeAlphaTo:1 duration:0.5];
        SKAction *group = [SKAction group:@[move, alphaIn]];
        [[self childNodeWithName:directionsSpriteName] runAction:group completion:^{
            for (BaseSprite *direction in [self children]) {
                if ([direction.name isEqualToString:directionsSecondarySpriteName]) {
                    [direction runAction:[SKAction sequence:@[[SKAction waitForDuration:0.5],alphaIn]]];
                } else if ([direction.name isEqualToString:directionsSecondaryBlinkingSpriteName]) {
                    SKAction *wait = [SKAction waitForDuration:0.5];
                    SKAction *alphaIn = [SKAction fadeAlphaTo:1 duration:1];
                    SKAction *alphaOut = [SKAction fadeAlphaTo:0 duration:1];
                    SKAction *sequence = [SKAction sequence:@[alphaIn, alphaOut, [SKAction waitForDuration:0.5]]];
                    [direction runAction:[SKAction sequence:@[wait,[SKAction repeatActionForever:sequence]]]];
                }
            }
        }];
    } else {
        [self configureGestureRecognizers:YES];
        shipSprite.physicsBody.velocity = CGVectorMake(0, MAX_VELOCITY);
    }

    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        if ([ABIMSIMDefaults boolForKey:kWalkthroughSeen]) {
            self.viewController.pauseButton.alpha = 0.7;
        }
        levelNode.alpha = 0.7;
        parsecsNode.alpha = 0.7;
        [self configureHolsterNukeSprites];
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
    viewHeight = self.view.frame.size.height;
    flickRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:flickRecognizer];
    [self.view addGestureRecognizer:tapRecognizer];
    [self configureGestureRecognizers:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.paused = NO;
        for (int i = 0; i < backgroundNodes.count; i++) {
            BaseSprite *backgroundNode = backgroundNodes[i];
            backgroundNode.alpha = i == 0;
        }
        for (BaseSprite *planet in planetPreRenderArray) {
            [planet removeFromParent];
        }
        planetPreRenderArray = nil;
    });
}

-(void)willMoveFromView:(SKView *)view {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeGestureRecognizer:flickRecognizer];
}

-(void)configureGestureRecognizers:(BOOL)enabled {
    flickRecognizer.enabled = tapRecognizer.enabled = enabled;
}

-(void)pause {
    if ([shipSprite childNodeWithName:shipImageSpriteName].hidden) {
        return;
    }
    self.view.paused = YES;
    [self configureGestureRecognizers:NO];
    [self.viewController showPausedView];
}

-(void)update:(CFTimeInterval)currentTime {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self pause];
    }
//    if (self.view.paused) {
//        if (self.resuming && !flickRecognizer.enabled) {
//            [self configureGestureRecognizers:YES];
//        }
//        return;
//    }
    if (pendingVelocity.x || pendingVelocity.y) {
        shipSprite.physicsBody.velocity = CGVectorMake(pendingVelocity.x, -pendingVelocity.y);
        pendingVelocity = CGPointZero;
    }
    if (advanceLevel) {
        [self advanceToNextLevel];
    }
    
    if (shieldHitPoints <= 0 && hasShield) {
        hasShield = NO;
        [self updateShipPhysics];
    } else if (shieldHitPoints > 0 && !hasShield) {
        hasShield = YES;
        [self updateShipPhysics];
    }
        
    if (shipSprite.physicsBody.velocity.dx!=0 || shipSprite.physicsBody.velocity.dy!=0)
        shipSprite.zRotation = atan2f(-shipSprite.physicsBody.velocity.dx, shipSprite.physicsBody.velocity.dy);
    
    if (self.reset) {
        [self resetWorld];
        return;
    }

    /* Called before each frame is rendered */
    if (shipWarping && shipSprite.position.y > shipSprite.frame.size.height/2 && !self.gameOver) {
        shipWarping = NO;
        shipSprite.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | asteroidCategory | planetCategory | planetRingCategory;
    }
    if (shipSprite) {
        float yPercentageFromCenter = (shipSprite.position.y - (viewHeight/2.0))  / (viewHeight / 2.0);
        float frontMaxY = ((viewHeight * starFrontMovement) - viewHeight)/2.0;
        float backMaxY = ((viewHeight * starBackMovement) - viewHeight)/2.0;
        float frontY = (yPercentageFromCenter * frontMaxY);
        frontY = frontY + (frontMaxY);
        float backY = (yPercentageFromCenter * backMaxY);
        backY = backY + (backMaxY);
        currentFrontLayer.position = CGPointMake(currentFrontLayer.position.x, -frontY);
        currentBackLayer.position = CGPointMake(currentBackLayer.position.x, -backY);
    }
    
    static int maxSpeed = MAX_VELOCITY;
    float speed = sqrt(shipSprite.physicsBody.velocity.dx*shipSprite.physicsBody.velocity.dx + shipSprite.physicsBody.velocity.dy * shipSprite.physicsBody.velocity.dy);
    if (speed > maxSpeed) {
        shipSprite.physicsBody.linearDamping = 0.4f;
    } else {
        shipSprite.physicsBody.linearDamping = 0.0f;
    }
    if (currentBlackHole) {
        for (BaseSprite *sprite in currentBlackHole.children) {
            if (sprite.remove) {
                if (sprite.size.width < 5) {
                    [sprite removeFromParent];
                    sprite.remove = NO;
                    sprite.alpha = 1;
                    sprite.xScale = sprite.yScale = 1;
                    for (BaseSprite *child in sprite.children) {
                        child.xScale = child.yScale = 1;
                    }
                }
            }
        }
        [self applyBlackHolePullToSprite:shipSprite];
    }
    
    for (BaseSprite *sprite in self.children) {
        if (sprite.remove) {
            [sprite removeFromParent];
            sprite.remove = NO;
            sprite.alpha = 1;
            sprite.xScale = sprite.yScale = 1;
            for (BaseSprite *child in sprite.children) {
                child.xScale = child.yScale = 1;
            }
            continue;
        } else if (currentBlackHole) {
            if ([sprite.name isEqualToString:asteroidCategoryName] ||
                [sprite.name isEqualToString:planetCategoryName] ||
                [sprite.name isEqualToString:asteroidShieldCategoryName] ||
                [sprite.name isEqualToString:asteroidInShieldCategoryName]) {
                if (sprite.parent || [sprite.name isEqualToString:asteroidInShieldCategoryName]) {
                    [self applyBlackHolePullToSprite:sprite];
                }
            }
        }
        if (![sprite.name isEqualToString:asteroidCategoryName] &&
            ![sprite.name isEqualToString:asteroidInShieldCategoryName]) {
            continue;
        }
        
        if (sprite.position.y - sprite.size.height/2 > sceneHeight) {
            if (sprite.parent && [sprite.name isEqualToString:asteroidCategoryName]) {
                [sprite removeFromParent];
                sprite.remove = NO;
                sprite.alpha = 1;
                sprite.xScale = sprite.yScale = 1;
                continue;
            }
        }
        if (fabs(sprite.physicsBody.angularVelocity) > MAX_ANGULAR_VELOCITY) {
            sprite.physicsBody.angularDamping = 1.0f;
        } else {
            sprite.physicsBody.angularDamping = 0.0f;
        }
        float speed = sqrt(sprite.physicsBody.velocity.dx*sprite.physicsBody.velocity.dx + sprite.physicsBody.velocity.dy * sprite.physicsBody.velocity.dy);
        if (speed > maxSpeed) {
            sprite.physicsBody.linearDamping = 0.4f;
        } else {
            sprite.physicsBody.linearDamping = 0.0f;
        }

    }
    
    if (explodingMine) {
        BaseSprite *explodingRing = (BaseSprite*)[explodingMine childNodeWithName:powerUpSpaceMineExplodeRingName];
        if (explodingRing.size.width > 0) {
            explodingRing.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:explodingRing.size.width/2];
            explodingRing.physicsBody.dynamic = NO;
            explodingRing.physicsBody.categoryBitMask = powerUpSpaceMineExplodingRingCategory;
            explodingRing.physicsBody.contactTestBitMask = asteroidCategory | asteroidInShieldCategory;
        }
    }
    if (explodingNuke) {
        if (explodingNuke.size.width > 0) {
            explodingNuke.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:explodingNuke.size.width/2];
            explodingNuke.physicsBody.dynamic = NO;
            explodingNuke.physicsBody.categoryBitMask = powerUpSpaceMineExplodingRingCategory;
            explodingNuke.physicsBody.contactTestBitMask = asteroidCategory | asteroidInShieldCategory;
        }
    }
    if (explodedMine) {
        __block BaseSprite *mine = explodedMine;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BaseSprite *explodingRing = (BaseSprite*)[explodingMine childNodeWithName:powerUpSpaceMineExplodeRingName];
            [explodingRing removeFromParent];
            [mine removeFromParent];
        });
        explodedMine = nil;
    }
    if (self.transitioningToMenu) {
        self.transitioningToMenu = NO;
        self.view.paused = YES;
//        self.initialPause = YES;
    }
}

-(void)applyBlackHolePullToSprite:(BaseSprite*)sprite {
    CGPoint p1 = currentBlackHole.position;
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
    float magnitude = (sceneHeight / distance);
    if (sprite.name == shipCategoryName) {
        magnitude = powf(magnitude, 4.5);
    } else {
        magnitude = powf(magnitude, 4);
    }
    [sprite.physicsBody applyImpulse:CGVectorMake(-x*magnitude, -y*magnitude)];
    if (sprite.name == planetCategoryName || sprite.name == asteroidShieldCategoryName || sprite.name == starSpriteName) {
        if (magnitude > 250) {
            magnitude = 250;
        }
        [sprite runAction:[SKAction moveBy:CGVectorMake(-x * (magnitude/100), -y*(magnitude/100)) duration:0]];
    }
}

#pragma mark - Achievements
-(void)checkPlanetHitAchievement:(int)planetNum {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
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
    });
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *identifier = @"";
        switch (self.currentLevel) {
            case 2:
                SMAction(@"parsecs2");
                break;
            case 3:
                SMAction(@"parsecs3");
                break;
            case 4:
                SMAction(@"parsecs4");
                break;
            case 5:
                SMAction(@"parsecs5");
                break;
            case 6:
                SMAction(@"parsecs6");
                break;
            case 7:
                SMAction(@"parsecs7");
                break;
            case 8:
                SMAction(@"parsecs8");
                break;
            case 9:
                SMAction(@"parsecs9");
                break;
            case 10:
                identifier = @"learningToFly";
                SMAction(@"parsecs10");
                break;
            case 15:
                SMAction(@"parsecs15");
                break;
            case 20:
                identifier = @"explorerReporting";
                SMAction(@"parsecs20");
                break;
            case 25:
                SMAction(@"parsecs25");
                break;
            case 30:
                identifier = @"adventureIsOutThere";
                SMAction(@"parsecs30");
                break;
            case 35:
                SMAction(@"parsecs35");
                break;
            case 40:
                identifier = @"gettinKindaHectic";
                SMAction(@"parsecs40");
                break;
            case 45:
                SMAction(@"parsecs45");
                break;
            case 50:
                identifier = @"deepSpace";
                SMAction(@"parsecs50");
                break;
            case 60:
                identifier = @"toBoldyGo";
                SMAction(@"parsecs60");
                break;
            case 70:
                identifier = @"whereNoManHasGoneBefore";
                SMAction(@"parsecs70");
                break;
            case 80:
                identifier = @"acrossTheCosmos";
                SMAction(@"parsecs80");
                break;
            case 90:
                identifier = @"theObservableUniverse";
                SMAction(@"parsecs90");
                break;
            case 100:
                identifier = @"theEdgeOfSpace";
                SMAction(@"parsecs100");
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
    });
}

-(void)sendAchievementWithIdentifier:(NSString*)identifier {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self smActionForIdentifier:identifier];
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
                                 [ABIMSIMDefaults setBool:YES forKey:identifier];
                                 [ABIMSIMDefaults synchronize];
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
    });
}

-(void)smActionForIdentifier:(NSString*)identifier {
    if ([identifier isEqualToString:@"setTheControlsForTheHeartOfTheSun"]) {
        SMAction(@"sunDeath");
    } else if ([identifier isEqualToString:@"Autopilot"]) {
        SMAction(@"autopilot");
    } else if ([identifier isEqualToString:@"blackHole"]) {
        SMAction(@"blackHoleDeath");
    } else if ([identifier isEqualToString:@"poorUnfortunateSoul"]) {
        SMAction(@"poorSoul");
    } else if ([identifier isEqualToString:@"tripleCrown"]) {
        SMAction(@"tripleCrown");
    } else if ([identifier isEqualToString:@"tripleDouble"]) {
        SMAction(@"tripleDouble");
    }
}

#pragma mark - Touch Handling

-(void)handlePanGesture:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateEnded || (self.view.paused && !self.initialPause && !self.resuming)) {
        return;
    }
    lastLevelPanned = self.currentLevel;
    CGPoint addVelocity = [recognizer velocityInView:recognizer.view];
    CGPoint newVelocity = addVelocity;
    float velocity = sqrtf(powf(newVelocity.x, 2) + powf(newVelocity.y, 2));
    newVelocity.x = MAX_VELOCITY * ( newVelocity.x / velocity );
    newVelocity.y = MAX_VELOCITY * ( newVelocity.y / velocity );
    pendingVelocity = newVelocity;
    if (shipSprite.physicsBody) {
        [[shipSprite childNodeWithName:shipThrusterSpriteName] runAction:shipSprite.userData[shipThrusterAnimation] withKey:shipThrusterAnimation];
    }
    if (self.initialPause) {
        self.initialPause = NO;
        [self removeOverlayChildren];
        self.viewController.pauseButton.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.viewController.pauseButton.alpha = 0.7;
        } completion:^(BOOL finished) {
            if(finished) {
                self.physicsWorld.speed = 1;
            }
        }];
    }
}

-(void)handleTapGesture:(UITapGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if (holsterNukes > 0 && !nukeUsedThisLevel) {
            holsterNukes--;
            nukeUsedThisLevel = YES;
            [self nuke];
            [self configureHolsterNukeSprites];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [ABIMSIMDefaults setInteger:holsterNukes forKey:kHolsterNukes];
                [ABIMSIMDefaults synchronize];
            });
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
        }
        else {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        if ((firstBody.categoryBitMask == asteroidCategory || firstBody.categoryBitMask == asteroidInShieldCategory) && secondBody.categoryBitMask == powerUpSpaceMineExplodingRingCategory) {
            [firstBody.node runAction:asteroidMineDeathAction completion:^{
                ((BaseSprite*)firstBody.node).remove = YES;
            }];
        }

        if ((firstBody.categoryBitMask == asteroidCategory || firstBody.categoryBitMask == asteroidInShieldCategory) && secondBody.categoryBitMask == asteroidShieldCategory) {
            NSMutableArray *impactArray;
            if ([secondBody.node.userData[planetNumber] intValue] == asteroidShield0) {
                impactArray = impactSpriteArrays[0];
            } else {
                impactArray = impactSpriteArrays[1];
            }
            BaseSprite *impactSprite;
            if (impactArray.count) {
                impactSprite = impactArray[0];
                impactSprite.alpha = 1;
                [impactArray removeObjectAtIndex:0];
            } else {
                NSString *imageName = @"";
                if ([secondBody.node.userData[planetNumber] intValue] == asteroidShield0) {
                    imageName = @"AsteroidShield_Impact_0";
                } else {
                    imageName = @"AsteroidShield_Impact_1";
                }
                impactSprite = [BaseSprite spriteNodeWithImageNamed:imageName];
                SKAction *prepair = [SKAction runBlock:^{
                    impactSprite.alpha = 1;
                }];
                SKAction *fadeAway = [SKAction fadeAlphaTo:0 duration:0.5];
                impactSprite.userData = [NSMutableDictionary dictionary];
                impactSprite.userData[asteroidShieldImpactAnimation] = [SKAction sequence:@[prepair, fadeAway]];
                impactSprite.userData[planetNumber] = secondBody.node.userData[planetNumber];
                impactSprite.name = asteroidShieldImpactSpriteName;
            }
            [secondBody.node addChild:impactSprite];
            [impactSprite runAction:impactSprite.userData[asteroidShieldImpactAnimation] completion:^{
                [impactSprite removeFromParent];
                if ([impactSprite.userData[planetNumber] intValue] == asteroidShield0) {
                    NSMutableArray *anImpactArray = impactSpriteArrays[0];
                    [anImpactArray addObject:impactSprite];
                    impactSpriteArrays[0] = anImpactArray;
                } else {
                    NSMutableArray *anImpactArray = impactSpriteArrays[1];
                    [anImpactArray addObject:impactSprite];
                    impactSpriteArrays[1] = anImpactArray;
                }
                
            }];
            CGPoint p1 = secondBody.node.position;
            CGPoint p2 = firstBody.node.position;
            
            CGFloat f = [self pointPairToBearingDegrees:p1 secondPoint:p2] - 90;
            impactSprite.zRotation = DegreesToRadians(f);
        }
        
        if ((firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == asteroidShieldCategory) || (firstBody.categoryBitMask == asteroidShieldCategory && secondBody.categoryBitMask == blackHoleCategory)) {
            possibleBubblesPopped++;
            BaseSprite *nodeToUse;
            if  (secondBody.categoryBitMask == asteroidShieldCategory) {
                nodeToUse = (BaseSprite*)secondBody.node;
            } else {
                nodeToUse = (BaseSprite*)firstBody.node;
            }
            
            BaseSprite *explosionSprite = (BaseSprite*)nodeToUse.userData[@"asteroidBubblePopExplosion"];
            explosionSprite.position = nodeToUse.position;
            if ([nodeToUse.userData[planetNumber] intValue] == asteroidShield0) {
                explosionSprite.scale = 0.625;
            } else {
                explosionSprite.scale = 0.65;
            }

            if (!explosionSprite.parent && explosionSprite) {
                [self addChild:explosionSprite];
            }
            [explosionSprite runAction:explosionSprite.userData[@"asteroidBubblePopExplosionAction"] completion:^{
                explosionSprite.remove = YES;
            }];
            
            nodeToUse.remove = YES;
            for (BaseSprite *asteroid in [self children]) {
                if ([asteroid.name isEqual:asteroidInShieldCategoryName] &&
                    [asteroid.userData[asteroidShieldTag] intValue] == [secondBody.node.userData[asteroidShieldTag] intValue]) {
                    asteroid.physicsBody.categoryBitMask = asteroidCategory;
                    asteroid.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | shipCategory | asteroidCategory | planetCategory | planetRingCategory | asteroidShieldCategory;
                    asteroid.physicsBody.contactTestBitMask = goalCategory | shipCategory | asteroidShieldCategory | powerUpSpaceMineExplodingRingCategory;
                    asteroid.zRotation = DegreesToRadians(arc4random() % 360);
                    float velocity = MAX_VELOCITY;
                    asteroid.physicsBody.velocity = CGVectorMake(velocity * cosf(asteroid.zRotation), velocity * -sinf(asteroid.zRotation));
                    asteroid.name = asteroidCategoryName;
                    [asteroid.userData removeObjectForKey:asteroidShieldTag];
                }
            }
            return;
        }
        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == powerUpSpaceMineCategory) {
            if ([secondBody.node.name isEqualToString:explodingSpaceMine] ||
                [secondBody.node.name isEqualToString:explodedSpaceMine]) {
                return;
            }
            nukeUsedThisLevel = YES;

            secondBody.node.name = explodingSpaceMine;
            explodingMine = (BaseSprite*)secondBody.node;
            [secondBody.node removeAllActions];
            [[secondBody.node childNodeWithName:powerUpSpaceMineGlowName] removeFromParent];
            [secondBody.node runAction:secondBody.node.userData[powerUpSpaceMineExplosionGlowAnimation] completion:^{
                ;
            }];
            float durationTotal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 5.25 : 1.75;
            float durationReduction = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0.85 : 0.25;
            SKAction *sequenceAction = [SKAction sequence:@[[SKAction waitForDuration:0.5],secondBody.node.userData[powerUpSpaceMineExplosionRingAnimation],[SKAction waitForDuration:durationTotal - (mineBlastSpeedLevel * durationReduction)]]];
            [secondBody.node runAction:sequenceAction completion:^{
                secondBody.node.name = explodedSpaceMine;
                explodedMine = (BaseSprite*)secondBody.node;
            }];
            if (sfxSetting) {
                [self runAction:spaceMineSoundAction];
            }
        }

        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == goalCategory) {
            if ([safeToTransition isEqualToNumber:@YES]) {
                safeToTransition = @NO;
                [self transitionStars];
                advanceLevel = YES;
            }
        }
        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == planetCategory) {
            BaseSprite *planet = (BaseSprite*)secondBody.node;
            int planetNum = [planet.userData[planetNumber] intValue];
            [self checkPlanetHitAchievement:planetNum];
        }
        if (firstBody.categoryBitMask == asteroidCategory && secondBody.categoryBitMask == goalCategory) {
            ((BaseSprite*)firstBody.node).remove = YES;
        }
        if (firstBody.categoryBitMask == shipCategory && secondBody.categoryBitMask == powerUpShieldCategory) {
            hasShield = NO;
            ((BaseSprite*)secondBody.node).remove = YES;
            shieldHitPoints = 1 + shieldDurabilityLevel;
        }

        if ([secondBody.node.name isEqualToString:sunObjectSpriteName]) {
            if (firstBody.categoryBitMask == shipCategory) {
                [self checkHitAchievement];
                if (hasShield) {
                    shieldHitPoints--;
                    [self updateShipShield];
                    if (shieldHitPoints > 0) {
                        CGPoint p1 = firstBody.node.position;
                        CGPoint p2 = secondBody.node.position;
                        CGFloat f;
                        if (firstBody.velocity.dy >= 0 ) {
                            f = [self pointPairToBearingDegrees:p1 secondPoint:p2] - 90;
                        } else {
                            f = [self pointPairToBearingDegrees:p1 secondPoint:p2] - 180;
                        }
                        [firstBody.node childNodeWithName:shipShieldImpactSpriteName].zRotation = DegreesToRadians(f);
                        [[firstBody.node childNodeWithName:shipShieldImpactSpriteName] runAction:firstBody.node.userData[shipShieldImpactAnimation]];
                        [[firstBody.node childNodeWithName:shipShieldHitSpriteName] runAction:firstBody.node.userData[shipShieldHitAnimation]];
                        if (sfxSetting) {
                            [self runAction:shieldHitSoundAction];
                        }
                    }
                } else {
                    [self sendAchievementWithIdentifier:@"setTheControlsForTheHeartOfTheSun"];
                    [self killShipAndStartOver];
                }
            } else {
                if (firstBody.node.name == asteroidCategoryName) {
                    [firstBody.node runAction:asteroidSunDeathAction completion:^{
                        ((BaseSprite*)firstBody.node).remove = YES;
                    }];
                } else {
                    ((BaseSprite*)firstBody.node).remove = YES;
                }
                if (sfxSetting) {
                    [self runAction:asteroidSunSoundAction];
                }
            }
        }
        if ([secondBody.node.name isEqualToString:blackHoleCategoryName]) {
            if (((BaseSprite*)firstBody.node).remove) {
                return;
            }
            CGPoint p1 = [self childNodeWithName:blackHoleCategoryName].position;
            CGPoint p2 = firstBody.node.position;
            CGFloat r = DegreesToRadians([self pointPairToBearingDegrees:p1 secondPoint:p2]);
            float distance = sqrtf(powf(p1.x - p2.x,2) + powf(p1.y - p2.y, 2));
            BaseSprite *shipShieldImage;
            BaseSprite *shipImage;
            if ([firstBody.node.name isEqualToString:shipCategoryName]) {
                shipShieldImage = (BaseSprite*)[shipSprite childNodeWithName:shipShieldSpriteName];
                shipImage = (BaseSprite*)[shipSprite childNodeWithName:shipImageSpriteName];

                [shipShieldImage removeFromParent];
                [shipImage removeFromParent];
                
                shipShieldImage.position = CGPointMake(distance*cosf(r), distance*sinf(r));
                shipImage.position = CGPointMake(distance*cosf(r), distance*sinf(r));
            } else {
                [firstBody.node removeFromParent];
                firstBody.node.position = CGPointMake(distance*cosf(r), distance*sinf(r));
            }
            if (firstBody.node) {
                if ([firstBody.node.name isEqualToString:shipCategoryName]) {
                    [secondBody.node addChild:shipShieldImage];
                    [secondBody.node addChild:shipImage];
                } else {
                   [secondBody.node addChild:firstBody.node];
                }
            }
            if ([firstBody.node.name isEqualToString:shipCategoryName]) {
                [shipShieldImage runAction:blackholeDeathAction completion:^{
                    [self sendAchievementWithIdentifier:@"blackHole"];
                    [self killShipAndStartOver];
                }];
                [shipImage runAction:blackholeDeathAction];
            } else {
                [firstBody.node runAction:blackholeDeathAction];
            }
            ((BaseSprite*)firstBody.node).remove = YES;
            if ([firstBody.node.name isEqualToString:shipCategoryName]) {
                shipSprite = nil;
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
            [self updateShipShield];
            if (shieldHitPoints > 0) {
                CGPoint p1 = firstBody.node.position;
                CGPoint p2 = secondBody.node.position;
                CGFloat f;
                if (firstBody.velocity.dy >= 0 ) {
                    f = [self pointPairToBearingDegrees:p1 secondPoint:p2] - 90;
                } else {
                    f = [self pointPairToBearingDegrees:p1 secondPoint:p2] + 90;
                }
                [firstBody.node childNodeWithName:shipShieldImpactSpriteName].zRotation = DegreesToRadians(f);
                [[firstBody.node childNodeWithName:shipShieldImpactSpriteName] runAction:firstBody.node.userData[shipShieldImpactAnimation]];
                [[firstBody.node childNodeWithName:shipShieldHitSpriteName] runAction:firstBody.node.userData[shipShieldHitAnimation]];
                if (sfxSetting) {
                    [self runAction:shieldHitSoundAction];
                }
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
    if ([shipSprite childNodeWithName:shipImageSpriteName].hidden) {
        return;
    }
    __block int pointsEarned = self.currentLevel;
    pointsEarned += self.currentLevel / 10;
    pointsEarned += self.bubblesPopped * 5;
    pointsEarned += self.blackHolesSurvived * 4;
    pointsEarned += self.sunsSurvived * 3;
    [shipSprite childNodeWithName:shipShieldSpriteName].hidden = YES;
    [shipSprite childNodeWithName:shipImageSpriteName].hidden = YES;
    [shipSprite childNodeWithName:shipThrusterSpriteName].hidden = YES;
    [[shipSprite childNodeWithName:shipExplosionSpriteName] runAction:shipSprite.userData[shipExplosionAnimation]];

    [[AudioController sharedController] playerDeath];
    if (sfxSetting) {
        [self runAction:playerDeathSoundAction];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.paused = YES;
        [self.viewController showGameOverView];
        self.gameOver = YES;
        [self configureGestureRecognizers:NO];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets]+pointsEarned forKey:kUserDuckets];
        [ABIMSIMDefaults synchronize];

        NSString *leaderBoardID = @"distance";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            leaderBoardID = @"distance_iPad";
        }
        GKScore *newScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderBoardID];
        newScore.value = self.currentLevel;
        [GKScore reportScores:@[newScore] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Score Submit Error: %@", error);
            }
        }];
        if (self.bubblesPopped >= 5 &&
            self.sunsSurvived >= 5 &&
            self.blackHolesSurvived >= 5) {
            [self sendAchievementWithIdentifier:@"tripleCrown"];
        }
        if (self.bubblesPopped >= 10 &&
            self.sunsSurvived >= 10 &&
            self.blackHolesSurvived >= 10) {
            [self sendAchievementWithIdentifier:@"tripleDouble"];
        }
    });

}

#pragma mark - Level generation

-(BaseSprite*)createShip {
    BaseSprite *shipImage = [BaseSprite spriteNodeWithImageNamed:@"Ship"];
    shipImage.name = shipImageSpriteName;
    BaseSprite *shipThruster = [BaseSprite spriteNodeWithImageNamed:@"EngineExhaust"];
    shipThruster.name = shipThrusterSpriteName;
    shipThruster.alpha = 0;
    BaseSprite *shipShieldImage = [BaseSprite spriteNodeWithImageNamed:@"ShipShield"];
    shipShieldImage.name = shipShieldSpriteName;
    shipShieldImage.alpha = 0;
    shipShieldImage.position = CGPointMake(0, 5);
    BaseSprite *shipShieldHitImage = [BaseSprite spriteNodeWithImageNamed:@"ShipShieldHit"];
    shipShieldHitImage.name = shipShieldHitSpriteName;
    shipShieldHitImage.alpha = 0;
    shipShieldHitImage.position = CGPointMake(0, 5);
    BaseSprite *impactSprite = [BaseSprite spriteNodeWithImageNamed:@"ShipShield_Impact"];
    impactSprite.name = shipShieldImpactSpriteName;
    impactSprite.alpha = 0;
    impactSprite.position = CGPointMake(0, 5);
    BaseSprite *explosionSprite = [BaseSprite spriteNodeWithImageNamed:@"ShipExplosion"];
    explosionSprite.name = shipExplosionSpriteName;
    explosionSprite.position = CGPointMake(0, 0);
    explosionSprite.alpha = 0;
    [explosionSprite setScale:0];
    
    BaseSprite *ship = [BaseSprite spriteNodeWithColor:[UIColor clearColor] size:shipShieldImage.size];
    [ship addChild:shipImage];
    [ship addChild:shipThruster];
    [ship addChild:shipShieldImage];
    [ship addChild:shipShieldHitImage];
    [ship addChild:impactSprite];
    [ship addChild:explosionSprite];

    ship.name = shipCategoryName;
    ship.position = CGPointMake(sceneWidth/2, -kExtraSpaceOffScreen + ship.size.height/2);
    ship.zPosition = 1;
    ship.userData = [NSMutableDictionary dictionary];
    SKAction *shieldSetup = [SKAction runBlock:^{
        [ship removeActionForKey:shipThrusterAnimation];
        shipShieldImage.alpha = 1;
        shipShieldImage.scale = 0.71;
    }];
    SKAction *growAction = [SKAction scaleTo:1.1 duration:0.3];
    SKAction *snapBack = [SKAction scaleTo:1.0 duration:0.1];
    SKAction *sequence = [SKAction sequence:@[shieldSetup,growAction,snapBack]];
    ship.userData[shipShieldOnAnimation] = sequence;
    
    SKAction *thrusterSetup = [SKAction runBlock:^{
        shipThruster.alpha = 0;
        shipThruster.scale = 0.71;
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
    
    SKAction *showImpact = [SKAction fadeAlphaTo:1 duration:0.01];
    SKAction *fadeAway = [SKAction fadeAlphaTo:0 duration:0.25];
    SKAction *impactSequence = [SKAction sequence:@[showImpact,fadeAway]];
    ship.userData[shipShieldImpactAnimation] = impactSequence;
    
    SKAction *showShieldHit = [SKAction fadeAlphaTo:1 duration:0.01];
    SKAction *fadeShieldHitAway = [SKAction fadeAlphaTo:0 duration:0.25];
    SKAction *shieldHitSequence = [SKAction sequence:@[showShieldHit,fadeShieldHitAway]];
    ship.userData[shipShieldHitAnimation] = shieldHitSequence;

    SKAction *explFadeAction = [SKAction fadeAlphaTo:1 duration:0.1];
    SKAction *explScaleAction = [SKAction scaleTo:0.75 duration:0.1];
    SKAction *explFadeOutAction = [SKAction fadeAlphaTo:0 duration:0.25];
    SKAction *explScaleDown = [SKAction scaleTo:1 duration:0.25];
    SKAction *explGroupAction = [SKAction group:@[explFadeAction, explScaleAction]];
    SKAction *explGroupAction2 = [SKAction group:@[explFadeOutAction, explScaleDown]];
    SKAction *explSetup = [SKAction runBlock:^{
        [explosionSprite setScale:0.4];
        [explosionSprite setAlpha:0];
        [self configureGestureRecognizers:NO];
        ship.physicsBody.collisionBitMask = 0;
        ship.physicsBody.contactTestBitMask = 0;
    }];
    SKAction *removeShipPhysicsBodyAction = [SKAction runBlock:^{
        [self configureGestureRecognizers:YES];
        ship.physicsBody = nil;
    }];
    SKAction *explSequence = [SKAction sequence:@[explSetup, explGroupAction, explGroupAction2, removeShipPhysicsBodyAction]];
    ship.userData[shipExplosionAnimation] = explSequence;

    shipSize = ship.size;
    explodingNuke = nil;
    return ship;
}

-(void)resetWorld {
    [self setDefaultValues];
    [self configureHolsterNukeSprites];
    nukeUsedThisLevel = NO;
    lastShieldLevel = lastMineLevel = 0;
    
    for (int i = 0; i < backgroundNodes.count; i++) {
        BaseSprite *backgroundNode = backgroundNodes[i];
        backgroundNode.alpha = i == 0;
    }

    [self removeOverlayChildren];
    [self removeCurrentSprites];
    [starFrontLayer removeFromParent];
    [starBackLayer removeFromParent];
    [alternateFrontLayer removeFromParent];
    [alternateBackLayer removeFromParent];
    
    self.currentLevel = 0;
    self.bubblesPopped = 0;
    self.sunsSurvived = 0;
    self.blackHolesSurvived = 0;
    hasShield = shieldOnStart;
    if (hasShield) {
        shieldHitPoints = 1 + shieldDurabilityLevel;
    } else {
        shieldHitPoints = 0;
    }
    shipHitPoints = 1;

    levelNode.text = [NSString stringWithFormat:@"%d",self.currentLevel];
    parsecsNode.position = CGPointMake(levelNode.position.x + levelNode.frame.size.width + 1, 16);
    parsecsNode.text = @"PARSEC";

    safeToTransition = @YES;
    if (!shipSprite) {
        shipSprite = [self createShip];
        [self addChild:shipSprite];
        [self addSpaceMineExplosionRingAnimationsToSprite:shipSprite];
    }
    [shipSprite childNodeWithName:shipShieldSpriteName].hidden = NO;
    [shipSprite childNodeWithName:shipImageSpriteName].hidden = NO;
    [shipSprite childNodeWithName:shipThrusterSpriteName].hidden = NO;
    [self updateShipPhysics];
    shipSprite.physicsBody.velocity = CGVectorMake(0, 0);
    
    shipSprite.physicsBody.collisionBitMask = borderCategory | asteroidCategory | planetCategory | planetRingCategory;
    shipSprite.position = CGPointMake(sceneWidth/2, -kExtraSpaceOffScreen + shipSprite.size.height/2);

    for (NSMutableArray *sprites in spritesArrays) {
        for (BaseSprite *sprite in sprites) {
            [sprite removeFromParent];
            if ([sprite.name isEqual:asteroidCategoryName] ||
                [sprite.name isEqual:asteroidInShieldCategoryName]) {
                BaseSprite *asteroid = sprite;
                NSMutableArray *asteroidArray = [asteroidSpritesDictionary objectForKey:[NSString stringWithFormat:kAsteroidSpriteArrayKey, [asteroid.userData[asteroidsIndex] intValue]]];
                [asteroidArray addObject:asteroid];
                [asteroidSpritesDictionary setObject:asteroidArray forKey:[NSString stringWithFormat:kAsteroidSpriteArrayKey, [asteroid.userData[asteroidsIndex] intValue]]];
            }
            if ([sprite.name isEqual:planetCategoryName] ||
                 [sprite.name isEqual:sunObjectSpriteName] ||
                [sprite.name isEqual:asteroidShieldCategoryName]) {
                BaseSprite *planet = sprite;
                NSMutableArray *planetArray = [planetSpritesDictionary objectForKey:[NSString stringWithFormat:kPlanetSpriteArrayKey, [planet.userData[planetsIndex] intValue]]];
                [planetArray addObject:planet];
                [planetSpritesDictionary setObject:planetArray forKey:[NSString stringWithFormat:kPlanetSpriteArrayKey, [planet.userData[planetsIndex] intValue]]];
            }

        }
        [sprites removeAllObjects];
    }
    [spritesArrays removeAllObjects];
    
    if (!self.transitioningToMenu) {
        [self transitionStars];
        [self generateInitialLevelsAndShowSprites:YES];
//        [self configureGestureRecognizers:YES];
    } else {
        [self generateInitialLevelsAndShowSprites:NO];
        [self configureGestureRecognizers:NO];
        levelNode.hidden = NO;
        levelNode.alpha = 0;
        parsecsNode.hidden = NO;
        parsecsNode.alpha = 0;
        for (BaseSprite *holsterNuke in holsterNukeSpritesArray) {
            holsterNuke.alpha = 0;
        }
    }
    shipWarping = YES;
    self.reset = NO;
}

-(void)transitionStars {
    float yVelocity = shipSprite.physicsBody.velocity.dy;
    BaseSprite *oldStarFrontLayer;
    BaseSprite *oldStarBackLayer;
    BaseSprite *newStarFrontLayer;
    BaseSprite *newStarBackLayer;
    if (self.currentLevel % 2 == 0) {
        oldStarFrontLayer = starFrontLayer;
        oldStarBackLayer = starBackLayer;
        newStarFrontLayer = alternateFrontLayer;
        newStarBackLayer = alternateBackLayer;
    } else {
        oldStarFrontLayer = alternateFrontLayer;
        oldStarBackLayer = alternateBackLayer;
        newStarFrontLayer = starFrontLayer;
        newStarBackLayer = starBackLayer;
    }
    currentBackLayer = newStarBackLayer;
    currentFrontLayer = newStarFrontLayer;

    newStarBackLayer.zPosition = 0;
    newStarFrontLayer.zPosition = 0;
    newStarFrontLayer.anchorPoint = CGPointZero;
    newStarBackLayer.anchorPoint = CGPointZero;
    newStarBackLayer.position = newStarFrontLayer.position = CGPointMake(0, 0);
    [newStarBackLayer removeFromParent];
    [newStarFrontLayer removeFromParent];
    [self insertChild:newStarBackLayer atIndex:0];
    [self insertChild:newStarFrontLayer atIndex:0];

    int allStars = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 48 : 12;
    int halfStars = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 24 : 6;
    if (!starSprites) {
        starSprites = [NSMutableArray array];
        for (int i = 0; i < allStars; i++) {
            BaseSprite *star = [BaseSprite spriteNodeWithImageNamed:@"LargeStar"];
            star.alpha = 0.4;
            star.name = starSpriteName;
            [starSprites addObject:star];
            float x = arc4random() % (int)sceneWidth * 1;
            float y;
            if (i < halfStars) {
                y = arc4random() % (int)(sceneHeight * starBackMovement * 1);
            } else {
                y = arc4random() % (int)(sceneHeight * starFrontMovement * 1);
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
            if (i < halfStars) {
                [newStarBackLayer addChild:star];
            } else {
                [newStarFrontLayer addChild:star];
            }
            [star setScale:0];
            [star runAction:[SKAction scaleTo:1 duration:0.5]];
        }
        for (int i = 0; i < allStars; i++) {
            BaseSprite *star = [BaseSprite spriteNodeWithImageNamed:@"LargeStar"];
            star.alpha = 0.4;
            star.name = starSpriteName;
            [starSprites addObject:star];
            [star setScale:0];
            star.colorBlendFactor = 1.0;
            if (i < halfStars) {
                [oldStarBackLayer addChild:star];
            } else {
                [oldStarFrontLayer addChild:star];
            }
        }
    } else {
        int i = 0;
        int half = 0;
        BOOL shrinkBackHalf = self.currentLevel % 2 == 0;
        for (BaseSprite *star in starSprites) {
            float x = arc4random() % (int)sceneWidth * 1;
            float y;
            if (i < halfStars) {
                y = arc4random() % (int)(sceneHeight * starBackMovement * 1);
            } else {
                y = arc4random() % (int)(sceneHeight * starFrontMovement * 1);
            }
            float scale = 0;
            if ((shrinkBackHalf && half == 0) ||
                (!shrinkBackHalf && half == 1)) {
//                [star removeFromParent];
//                if (i < halfStars) {
//                    [newStarBackLayer addChild:star];
//                } else {
//                    [newStarFrontLayer addChild:star];
//                }
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
                    star.name = starSpriteName;
                }];
            } else {
                SKAction *spawnAction = [SKAction group:@[[SKAction moveByX:0 y:yVelocity * 0.125 duration:0.5],
                                                          [SKAction runBlock:^{
                    [star runAction:[SKAction scaleTo:0 duration:0.5] completion:^{
//                        [star removeFromParent];
                        if (i < UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 24 : 6) {
//                            [newStarBackLayer addChild:star];
                        } else {
//                            [newStarFrontLayer addChild:star];
                        }
                        [oldStarFrontLayer removeFromParent];
                        [oldStarBackLayer removeFromParent];
                    }];
                }]]];
                [star runAction:spawnAction];
            }
            i++;
            if (i > allStars - 1) {
                i = 0;
                half++;
            }
        }
    }
}

-(void)generateInitialLevelsAndShowSprites:(BOOL)show {
    nukeUsedThisLevel = NO;
    self.currentLevel = 1;
    levelNode.text = @"1";
    parsecsNode.position = CGPointMake(levelNode.position.x + levelNode.frame.size.width + 1, 16);
    parsecsNode.text = @"PARSEC";

    for (int i = 1; i <= kNumberOfLevelsToGenerate; i++) {
        NSMutableArray *spriteArray = [NSMutableArray array];
        NSMutableArray *asteroids = [self asteroidsForLevel:i];
        [spriteArray addObjectsFromArray:asteroids];
        NSMutableArray *planets = [self planetsForLevel:i];
        [spriteArray addObjectsFromArray:planets];
        NSMutableArray *powerUps = [self powerUpsForLevel:i];
        [spriteArray addObjectsFromArray:powerUps];
        
        [spritesArrays addObject:spriteArray];
    }
    currentSpriteArray = [spritesArrays firstObject];
    if (show) {
        [self showCurrentSprites];
    }
}

-(void)removeCurrentSprites {
    for (int i = 0; i < currentSpriteArray.count; i++) {
        BaseSprite *currentSprite = currentSpriteArray[i];
        [currentSprite removeAllActions];
        for (BaseSprite *child in ((BaseSprite*)currentSprite).children) {
            [child removeAllActions];
            if (child.name == asteroidShieldImpactSpriteName) {
                [child removeFromParent];
                if ([child.userData[planetNumber] intValue] == asteroidShield0) {
                    NSMutableArray *anImpactArray = impactSpriteArrays[0];
                    [anImpactArray addObject:child];
                    impactSpriteArrays[0] = anImpactArray;
                } else {
                    NSMutableArray *anImpactArray = impactSpriteArrays[1];
                    [anImpactArray addObject:child];
                    impactSpriteArrays[1] = anImpactArray;
                }
            }
        }
        if ([[currentSprite name] isEqual:asteroidCategoryName] ||
            [[currentSprite name] isEqual:asteroidInShieldCategoryName]) {
            [currentSprite removeFromParent];
            BaseSprite *asteroid = currentSprite;
            NSMutableArray *asteroidArray = [asteroidSpritesDictionary objectForKey:[NSString stringWithFormat:kAsteroidSpriteArrayKey, [asteroid.userData[asteroidsIndex] intValue]]];
            [asteroidArray addObject:asteroid];
            [asteroidSpritesDictionary setObject:asteroidArray forKey:[NSString stringWithFormat:kAsteroidSpriteArrayKey, [asteroid.userData[asteroidsIndex] intValue]]];
        }
        if ([[currentSprite name] isEqual:planetCategoryName] ||
            [[currentSprite name] isEqual:sunObjectSpriteName] ||
            [[currentSprite name] isEqual:asteroidShieldCategoryName] ||
            [[currentSprite name] isEqual:blackHoleCategoryName]) {
            [currentSprite removeFromParent];
            for (BaseSprite *moon in ((BaseSprite*)currentSprite).userData[moonsArray]) {
                [moon removeFromParent];
            }
            if (![[currentSprite name] isEqual:blackHoleCategoryName]) {
                BaseSprite *planet = currentSprite;
                NSMutableArray *planetArray = [planetSpritesDictionary objectForKey:[NSString stringWithFormat:kPlanetSpriteArrayKey, [planet.userData[planetsIndex] intValue]]];
                [planetArray addObject:planet];
                [planetSpritesDictionary setObject:planetArray forKey:[NSString stringWithFormat:kPlanetSpriteArrayKey, [planet.userData[planetsIndex] intValue]]];
            }
        }
        if ([[currentSprite name] isEqual:powerUpSpaceMineName] ||
            [[currentSprite name] isEqual:powerUpShieldName]) {
            [currentSprite removeFromParent];
        }
    }
    [currentSpriteArray removeAllObjects];
    
    if (explodingMine) {
        BaseSprite *explodingRing = (BaseSprite*)[explodingMine childNodeWithName:powerUpSpaceMineExplodeRingName];
        [explodingRing removeFromParent];
        [explodingMine removeFromParent];
    }
    if (explodingNuke) {
        [explodingNuke removeAllActions];
        explodingNuke.alpha = 0;
        [explodingNuke setScale:0];
        [explodingNuke setPosition:CGPointZero];
    }
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
    
    [spritesArrays addObject:spritesArrays[0]];
    [spritesArrays removeObjectAtIndex:0];
    currentSpriteArray = spritesArrays[0];
    [self showCurrentSprites];
    safeToTransition = @YES;
    shipSprite.physicsBody.collisionBitMask = borderCategory | asteroidCategory | planetCategory | planetRingCategory;
    shipSprite.position = CGPointMake(shipSprite.position.x, -kExtraSpaceOffScreen + shipSprite.size.height/2);
    shipWarping = YES;
    advanceLevel = NO;
    nukeUsedThisLevel = NO;
    
    self.currentLevel++;
    [self showTutorialIfNeeded];
    [self checkLevelAchievements];
    if (self.currentLevel % 10 == 0) {
        int backgroundNumber = self.currentLevel / 10;
        while (backgroundNumber >= backgroundNodes.count) {
            backgroundNumber -= backgroundNodes.count;
        }
        int previousBackgroudNumber = backgroundNumber - 1;
        if (previousBackgroudNumber < 0) {
            previousBackgroudNumber = (int)backgroundNodes.count - 1;
        }
        
        BaseSprite *backgroundNode = backgroundNodes[backgroundNumber];
        BaseSprite *previousBackground = backgroundNodes[previousBackgroudNumber];
        [backgroundNode runAction:backgroundNode.userData[backgroundNodeAlphaInAction]];
        [previousBackground runAction:backgroundNode.userData[backgroundNodeAlphaOutAction]];
    }
    
    levelNode.text = [NSString stringWithFormat:@"%d",self.currentLevel];
    parsecsNode.position = CGPointMake(levelNode.position.x + levelNode.frame.size.width + 1, 16);
    parsecsNode.text = @"PARSECS";
    
    __block NSMutableArray *array = spritesArrays.lastObject;
    __block int levelToGenerate = self.currentLevel+kNumberOfLevelsToGenerate-1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *asteroids = [self asteroidsForLevel:levelToGenerate];
        [array addObjectsFromArray:asteroids];
        NSMutableArray *planets = [self planetsForLevel:levelToGenerate];
        [array addObjectsFromArray:planets];
        NSMutableArray *powerUps = [self powerUpsForLevel:levelToGenerate];
        [array addObjectsFromArray:powerUps];
    });
}

-(void)showTutorialIfNeeded {
    if (self.currentLevel == 1 && !self.reset && !walkthroughSeen) {
        BaseSprite *directions = [BaseSprite spriteNodeWithImageNamed:@"Instructions_Screen1"];
        directions.position = CGPointMake(sceneWidth/2, sceneHeight/2 + directions.size.height);
        [self addChild:directions];
        directions.alpha = 0;
        directions.zPosition = 100;
        directions.name = directionsSpriteName;
        
        BaseSprite *swipeToStart = [BaseSprite spriteNodeWithImageNamed:@"SwipeToStartText"];
        swipeToStart.position = CGPointMake(sceneWidth/2, shipSize.height*3 - swipeToStart.size.height + 5);
        [self addChild:swipeToStart];
        swipeToStart.alpha = 0;
        swipeToStart.name = directionsSecondarySpriteName;
        
        BaseSprite *shipDashedLine = [BaseSprite spriteNodeWithImageNamed:@"ShipDashedLine"];
        shipDashedLine.position = CGPointMake(sceneWidth/2, shipSize.height*2 + 5);
        [self addChild:shipDashedLine];
        shipDashedLine.alpha = 0;
        shipDashedLine.name = directionsSecondaryBlinkingSpriteName;
        
        BaseSprite *goalDashedLine = [BaseSprite spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"TopDashedLine"]]];
        goalDashedLine.position = CGPointMake(sceneWidth/2, sceneHeight - goalDashedLine.size.height);
        [self addChild:goalDashedLine];
        goalDashedLine.alpha = 0;
        goalDashedLine.name = directionsSecondaryBlinkingSpriteName;
    } else if (!walkthroughSeen && self.currentLevel == 2) {
        BaseSprite *directions = [BaseSprite spriteNodeWithImageNamed:@"Instructions_Screen2"];
        directions.position = CGPointMake(sceneWidth/2, sceneHeight/2 + directions.size.height);
        [self addChild:directions];
        directions.alpha = 0;
        directions.zPosition = 100;
        directions.name = directionsSpriteName;
        
        SKAction *move = [SKAction moveTo:CGPointMake(sceneWidth/2, sceneHeight/2) duration:0.5];
        SKAction *alphaIn = [SKAction fadeAlphaTo:1 duration:0.5];
        SKAction *group = [SKAction group:@[move, alphaIn]];
        [[self childNodeWithName:directionsSpriteName] runAction:group completion:^{
            self.physicsWorld.speed = 0;
            self.initialPause = YES;
        }];
        [ABIMSIMDefaults setBool:YES forKey:kWalkthroughSeen];
        [ABIMSIMDefaults synchronize];
    }
}

-(void)showCurrentSprites {
    if (currentBlackHole) {
        [[AudioController sharedController] endBlackhole];
    }
    currentBlackHole = nil;
    explodedMine = nil;
    explodingMine = nil;
    showingSun = NO;
    possibleBubblesPopped = 0;
    for (BaseSprite *sprite in currentSpriteArray) {
        [sprite removeAllActions];
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
                [[AudioController sharedController] blackhole];
            }
            if ([sprite.name isEqual:sunObjectSpriteName]) {
                showingSun = YES;
            }
            sprite.xScale = sprite.yScale = 1;
            for (BaseSprite *child in sprite.children) {
                child.xScale = child.yScale = 1;
                child.hidden = NO;
                if ([sprite.name isEqual:planetCategoryName]) {
                    child.position = CGPointZero;
                }
            }
            sprite.hidden = NO;
            [self addChild:sprite];
            if (sprite.position.y < sceneHeight - sprite.size.height/2 - 10) {
                for (BaseSprite *moon in sprite.userData[moonsArray]) {
                    moon.hidden = NO;
                    [moon removeAllActions];
                    [self addChild:moon];
                    [self.physicsWorld addJoint:moon.userData[orbitJoint]];
                    moon.physicsBody.angularVelocity = 100;
                }
            }
            if ([sprite.name isEqual:asteroidShieldCategoryName]) {
                [sprite runAction:sprite.userData[asteroidShieldPulseAnimationAction]];
            }
            if ([sprite.name isEqual:blackHoleCategoryName]) {
                [sprite runAction:sprite.userData[blackHoleAnimation]];
            }
            if ([sprite.name isEqual:planetCategoryName] ||
                [sprite.name isEqual:sunObjectSpriteName]) {
                [sprite runAction:sprite.userData[kPlanetHoverActionKey]];
            }
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
}

-(void)removeOverlayChildren {
    if (self.currentLevel < 3 && !walkthroughSeen) {
        while ([self childNodeWithName:directionsSpriteName]) {
            [[self childNodeWithName:directionsSpriteName] removeFromParent];
        }
        while ([self childNodeWithName:directionsSecondarySpriteName]) {
            [[self childNodeWithName:directionsSecondarySpriteName] removeFromParent];
        }
        while ([self childNodeWithName:directionsSecondaryBlinkingSpriteName]) {
            [[self childNodeWithName:directionsSecondaryBlinkingSpriteName] removeFromParent];
        }
        if (self.currentLevel >= 2) {
            walkthroughSeen = YES;
        }
    }
}

-(BaseSprite*)randomizeSprite:(BaseSprite*)sprite {
    float x = arc4random() % (int)sceneWidth * 1;
    float maxHeight = sceneHeight - bufferZoneHeight - (sprite.size.height/2.0);
    float y = (arc4random() % ((int)maxHeight)) + bufferZoneHeight + (sprite.size.height/2.0);
    if (maxHeight < 0) {
        y = sceneHeight;
    }
    sprite.position = CGPointMake(x, y);
    if ([sprite.name isEqualToString:asteroidCategoryName]) {
        sprite.zRotation = DegreesToRadians(arc4random() % 360);
        float velocity = arc4random() % (MAX_VELOCITY/2);
        if (velocity < 20.f) {
            velocity = 20.f;
        } 
        sprite.physicsBody.velocity = CGVectorMake(velocity * cosf(sprite.zRotation), velocity * -sinf(sprite.zRotation));
    }
    return sprite;
}

#pragma mark - Black Hole

-(BaseSprite*)blackHole {
    return [BlackHole blackHole];
}

#pragma mark - Power Ups

-(NSMutableArray*)powerUpsForLevel:(int)level {
    NSMutableArray *powerUps = [[NSMutableArray alloc] init];
    if (shieldOccuranceLevel > 0) {
        if (level - lastShieldLevel >= 10 || (level >= 5 && lastShieldLevel == 0)) {
            long number = 10 * (shieldOccuranceLevel + (lastShieldLevel == 0 ? 5 : 0));
            if (((arc4random() % 100)+1) <= number) {
                BaseSprite *shieldPowerUp = [self shieldPowerUp];
                [powerUps addObject:shieldPowerUp];
                lastShieldLevel = level;
            }
        }
    }
    if (mineOccuranceLevel > 0) {
        if (level - lastMineLevel >= 10 || (level >= 5 && lastMineLevel == 0)) {
            long number = 10 * (mineOccuranceLevel + (lastMineLevel == 0 ? 5 : 0));
            if (((arc4random() % 100)+1) <= number) {
                BaseSprite *spaceMinePowerUp = [self spaceMinePowerUp];
                [powerUps addObject:spaceMinePowerUp];
                lastMineLevel = level;
            }
        }
    }
    if (powerUps.count == 2) {
        BaseSprite *shield = powerUps[0];
        shield.position = CGPointMake(shield.position.x - 30, shield.position.y);
        BaseSprite *mine = powerUps[1];
        mine.position = CGPointMake(mine.position.x + 30, mine.position.y);
        
    }
    return powerUps;
}

-(BaseSprite*)spaceMinePowerUp {
    if (!minePowerUpSprite) {
        minePowerUpSprite = [BaseSprite spriteNodeWithTexture:spaceMineTextures[0]];
        minePowerUpSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:29];
        minePowerUpSprite.physicsBody.dynamic = NO;
        minePowerUpSprite.physicsBody.categoryBitMask = powerUpSpaceMineCategory;
        minePowerUpSprite.physicsBody.contactTestBitMask = shipCategory;
        minePowerUpSprite.name = powerUpSpaceMineName;
        minePowerUpSprite.position = CGPointMake(self.size.width/2, 100);
        minePowerUpSprite.zPosition = 1;
        minePowerUpSprite.userData = [NSMutableDictionary dictionary];
        
        SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:0.5];
        SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.5];
        SKAction *repeat = [SKAction repeatActionForever:[SKAction sequence:@[fadeIn,fadeOut]]];
        SKAction *animationAction = [SKAction runBlock:^{
            [[minePowerUpSprite childNodeWithName:powerUpSpaceMineGlowName] runAction:repeat];
        }];
        minePowerUpSprite.userData[powerUpSpaceMinePulseAnimation] = animationAction;
        
        SKAction *animation = [SKAction animateWithTextures:spaceMineTextures timePerFrame:0.1 resize:NO restore:NO];
        SKAction *repeatAnimation = [SKAction repeatActionForever:animation];
        minePowerUpSprite.userData[powerUpSpaceMineRotationAnimation] = repeatAnimation;
        
    }
    [minePowerUpSprite removeAllChildren];
    [minePowerUpSprite removeAllActions];
    BaseSprite *glowSprite = [BaseSprite spriteNodeWithTexture:powerUpTextures[2]];
    glowSprite.name = powerUpSpaceMineGlowName;
    [minePowerUpSprite addChild:glowSprite];
    glowSprite.alpha = 0;
    minePowerUpSprite.name = powerUpSpaceMineName;
    minePowerUpSprite.alpha = 1;
    minePowerUpSprite.position = CGPointMake(self.size.width/2, 100);
    [self addSpaceMineExplosionRingAnimationsToSprite:minePowerUpSprite];
    
    return minePowerUpSprite;
}

-(void)addSpaceMineExplosionRingAnimationsToSprite:(BaseSprite*)sprite {
    if (!sprite.userData) {
        sprite.userData = [NSMutableDictionary new];
    }
    BOOL isShipSprite = [sprite isEqual:shipSprite];
    float durationTotal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 5.25 : 1.75;
    float durationReduction = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0.85 : 0.25;
    float shipDuration = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1.0 : 0.5;
    float duration = isShipSprite ? shipDuration : durationTotal - (mineBlastSpeedLevel * durationReduction);
    BaseSprite *ring1 = [BaseSprite spriteNodeWithTexture:powerUpTextures[0]];
    [sprite addChild:ring1];
    ring1.name = powerUpSpaceMineExplodeRingName;
    ring1.alpha = 0;
    [ring1 setScale:0];
    SKAction *expandRingAction;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        expandRingAction = [SKAction scaleTo:3 duration:duration];
    } else {
        if (sceneHeight <= 568) {
            expandRingAction = [SKAction scaleTo:1.25 duration:duration];
        } else if (sceneHeight < 736) {
            expandRingAction = [SKAction scaleTo:1.5 duration:duration];
        } else {
            expandRingAction = [SKAction scaleTo:1.75 duration:duration];
        }
    }
    SKAction *blockAction = [SKAction runBlock:^{
        [ring1 setScale:0];
        [ring1 setAlpha:1];
    }];
    SKAction *resetAction = [SKAction runBlock:^{
        [ring1 setScale:0];
        [ring1 setAlpha:0];
        [ring1 setPosition:CGPointZero];
    }];

    SKAction *sequenceAction;
    if (isShipSprite) {
        sequenceAction = [SKAction sequence:@[blockAction, expandRingAction, resetAction]];
    } else {
        sequenceAction = [SKAction sequence:@[blockAction, expandRingAction]];
    }
    SKAction *animationAction = [SKAction runBlock:^{
        [ring1 runAction:sequenceAction];
    }];
    sprite.userData[powerUpSpaceMineExplosionRingAnimation] = animationAction;

    if (!isShipSprite) {
        BaseSprite *largeGlow = [BaseSprite spriteNodeWithTexture:powerUpTextures[1]];
        [sprite addChild:largeGlow];
        largeGlow.name = powerUpSpaceMineExplodeGlowName;
        largeGlow.alpha = 0;
        [largeGlow setScale:0];
        SKAction *expandRingActionB = [SKAction scaleTo:1 duration:0.5];
        SKAction *alphaInRingActionB = [SKAction fadeAlphaTo:1 duration:0.5];
        SKAction *alphaOutRingActionB = [SKAction fadeAlphaTo:0 duration:0.5];
        SKAction *removeImageAction = [SKAction runBlock:^{
            [sprite setTexture:nil];
        }];
        SKAction *groupActionB = [SKAction group:@[expandRingActionB,alphaInRingActionB]];
        SKAction *groupActionC = [SKAction group:@[alphaOutRingActionB,removeImageAction]];
        SKAction *sequenceActionB = [SKAction sequence:@[groupActionB, groupActionC]];
        SKAction *blockActionB = [SKAction runBlock:^{
            [largeGlow setScale:0];
            [largeGlow setAlpha:0];
        }];
        SKAction *sequenceActionC = [SKAction sequence:@[blockActionB, sequenceActionB]];
        SKAction *animationActionB = [SKAction runBlock:^{
            [largeGlow runAction:sequenceActionC];
        }];
        sprite.userData[powerUpSpaceMineExplosionGlowAnimation] = animationActionB;
    }
}


-(BaseSprite*)shieldPowerUp {
    if (!shieldPowerUpSprite) {
        shieldPowerUpSprite  = [BaseSprite spriteNodeWithTexture:powerUpTextures[3]];
        shieldPowerUpSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:29];
        shieldPowerUpSprite.physicsBody.dynamic = NO;
        shieldPowerUpSprite.physicsBody.categoryBitMask = powerUpShieldCategory;
        shieldPowerUpSprite.physicsBody.contactTestBitMask = shipCategory;
        shieldPowerUpSprite.name = powerUpShieldName;
        shieldPowerUpSprite.position = CGPointMake(self.size.width/2, 100);
        shieldPowerUpSprite.zPosition = 1;
        shieldPowerUpSprite.userData = [NSMutableDictionary dictionary];
        BaseSprite *glowSprite = [BaseSprite spriteNodeWithTexture:powerUpTextures[4]];
        glowSprite.name = powerUpShieldRingName;
        [shieldPowerUpSprite addChild:glowSprite];
        glowSprite.alpha = 0;
        
        SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:0.3];
        SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:1.0];
        SKAction *repeat = [SKAction repeatActionForever:[SKAction sequence:@[fadeIn,fadeOut]]];
        
        SKAction *animationAction = [SKAction runBlock:^{
            [glowSprite runAction:repeat];
        }];
        shieldPowerUpSprite.userData[powerUpShieldPulseAnimation] = animationAction;
    }
    shieldPowerUpSprite.name = powerUpShieldName;
    shieldPowerUpSprite.position = CGPointMake(self.size.width/2, 100);
    shieldPowerUpSprite.alpha = 1;

    
    return shieldPowerUpSprite;
}

-(void)startShipVelocity {
    shipSprite.physicsBody.velocity = CGVectorMake(0, 10);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        shipSprite.physicsBody.velocity = CGVectorMake(0, MAX_VELOCITY);
        for (BaseSprite* sprite in self.children) {
            if ([sprite.name isEqualToString:asteroidCategoryName]) {
                float velocity = arc4random() % (MAX_VELOCITY/2);
                if (velocity < 20.f) {
                    velocity = 20.f;
                }
                sprite.physicsBody.velocity = CGVectorMake(velocity * cosf(sprite.zRotation), velocity * -sinf(sprite.zRotation));
            }
        }
    });
}

-(void)updateShipPhysics {
    CGVector velocity = shipSprite.physicsBody.velocity;
    float width = 40;
    if (hasShield) {
        width = shipSprite.size.width;
        if (self.currentLevel != 0) {
            if (sfxSetting) {
                [self runAction:shieldUpSoundAction];
            }
            [[shipSprite childNodeWithName:shipShieldSpriteName] runAction:shipSprite.userData[shipShieldOnAnimation]];
        } else {
            [shipSprite childNodeWithName:shipShieldSpriteName].alpha = 1;
            [[shipSprite childNodeWithName:shipShieldSpriteName] setScale:1];
        }
    } else {
        if (self.currentLevel != 0) {
            if (sfxSetting) {
                [self runAction:shieldDownSoundAction];
            }
            NSString *imageName = @"ShipShield_Pop";
            float scale = 0.64;
            float duration = 0.5;
            BaseSprite *explosionSprite = [BaseSprite spriteNodeWithImageNamed:imageName];
            explosionSprite.position = CGPointMake(0, 3);
            [explosionSprite setScale:scale];
            explosionSprite.zPosition = 10;
            [shipSprite addChild:explosionSprite];
            SKAction *fadeAction = [SKAction fadeAlphaTo:0 duration:0.5];
            SKAction *scaleAction = [SKAction scaleTo:1 duration:duration];
            SKAction *groupAction = [SKAction group:@[fadeAction, scaleAction]];
            [explosionSprite runAction:[SKAction sequence:@[groupAction, [SKAction runBlock:^{
                [explosionSprite removeFromParent];
            }]]]];
        }
        [shipSprite childNodeWithName:shipShieldSpriteName].alpha = 0;
    }
    shipSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:width/2];
    shipSprite.physicsBody.friction = 0.0f;
    shipSprite.physicsBody.restitution = 1.0f;
    shipSprite.physicsBody.linearDamping = 0.0f;
    shipSprite.physicsBody.allowsRotation = NO;
    shipSprite.physicsBody.categoryBitMask = shipCategory;
    shipSprite.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | asteroidCategory | planetCategory | planetRingCategory;
    shipSprite.physicsBody.contactTestBitMask = goalCategory | asteroidCategory | planetCategory | powerUpShieldCategory | powerUpSpaceMineCategory | asteroidShieldCategory;
    shipSprite.physicsBody.mass = width;
    shipSprite.physicsBody.velocity = velocity;
}

-(void)updateShipShield {
    if (shieldHitPoints <= 0) {
        [shipSprite childNodeWithName:shipShieldSpriteName].alpha = 1;
        return;
    }
    float minAlpha = 0.5;
    float currentShieldPercentage = ((shieldHitPoints - 1) * 1.0f) / (0.0f + shieldDurabilityLevel);
    float alpha = minAlpha + 0.5 * currentShieldPercentage;
    [shipSprite childNodeWithName:shipShieldSpriteName].alpha = alpha;
}

-(void)nuke {
    if (!explodingNuke) {
        explodingNuke = (BaseSprite*)[shipSprite childNodeWithName:powerUpSpaceMineExplodeRingName];
        [explodingNuke removeFromParent];
        [self addChild:explodingNuke];
    }
    explodingNuke.position = shipSprite.position;
    [shipSprite runAction:shipSprite.userData[powerUpSpaceMineExplosionRingAnimation]];
}

#pragma mark - Asteroids

-(NSMutableArray*)asteroidsForLevel:(int)level {
    NSMutableArray *asteroids = [NSMutableArray array];
    int numOfAsteroids = arc4random() % ([self maxNumberOfAsteroidsForLevel:level]+1);
    if (numOfAsteroids < [self minNumberOfAsteroidsForLevel:level]) {
        numOfAsteroids = [self minNumberOfAsteroidsForLevel:level];
    }
    for (int j = 0; j < numOfAsteroids; j++) {
        BaseSprite *asteroid = [self randomAsteroidForLevel:level];
        [self randomizeSprite:asteroid];
        if (asteroid.position.x < asteroid.frame.size.width/2) {
            asteroid.position = CGPointMake(asteroid.frame.size.width/2, asteroid.position.y);
        } else if (asteroid.position.x > sceneWidth - asteroid.frame.size.width/2) {
            asteroid.position = CGPointMake(sceneWidth - asteroid.frame.size.width/2, asteroid.position.y);
        }

        if (level == 1) {
            asteroid.position = CGPointMake(asteroid.position.x, sceneHeight/4 * 3);
//            if (![ABIMSIMDefaults boolForKey:kWalkthroughSeen]) {
                asteroid.physicsBody.velocity = CGVectorMake(0, 0);
//            }
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (level <= 1) {
            return 4;
        } else if (level <= 2) {
            return 8;
        } else if (level <= 7) {
            return 12;
        } else if (level <= 15) {
            return 16;
        } else if (level <= 30) {
            return 20;
        } else if (level <= 40) {
            return 24;
        } else if (level <= 45) {
            return 28;
        } else if (level <= 50) {
            return 32;
        } else if (level <= 60) {
            return 36;
        } else {
            return 40;
        }
    } else {
        if (level <= 1) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:1];
        } else if (level <= 2) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:2];
        } else if (level <= 7) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:3];
        } else if (level <= 15) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:4];
        } else if (level <= 30) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:5];
        } else if (level <= 40) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:6];
        } else if (level <= 45) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:7];
        } else if (level <= 50) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:8];
        } else if (level <= 60) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:9];
        } else {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:10];
        }
    }
}

-(int)minNumberOfAsteroidsForLevel:(int)level {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (level <= 1) {
            return 4;
        } else if (level <= 2) {
            return 8;
        } else if (level <= 25) {
            return 12;
        } else if (level <= 35) {
            return 16;
        } else if (level <= 50) {
            return 20;
        } else if (level <= 65) {
            return 24;
        } else if (level <= 70) {
            return 28;
        } else if (level <= 75) {
            return 32;
        } else if (level <= 90) {
            return 36;
        } else {
            return 40;
        }
    } else {
        if (level <= 1) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:1];
        } else if (level <= 2) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:2];
        } else if (level <= 25) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:3];
        } else if (level <= 35) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:4];
        } else if (level <= 50) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:5];
        } else if (level <= 65) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:6];
        } else if (level <= 70) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:7];
        } else if (level <= 75) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:8];
        } else if (level <= 90) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:9];
        } else {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:10];
        }
    }
}

-(BaseSprite*)randomAsteroidForLevel:(int)level {
    int asteroidIndex = arc4random() % [self maxAsteroidNumForLevel:level];
    BaseSprite *sprite;
    NSMutableArray *asteroidArray = [asteroidSpritesDictionary objectForKey:[NSString stringWithFormat:kAsteroidSpriteArrayKey, asteroidIndex]];
    if (asteroidArray.count) {
        sprite = asteroidArray[0];
        sprite.alpha = 1;
        [asteroidArray removeObjectAtIndex:0];
    } else {
        sprite = [BaseSprite spriteNodeWithTexture:asteroidTextures[asteroidIndex]];
        sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForAsteroidNum:asteroidIndex withSprite:sprite]];
        sprite.physicsBody.friction = 0.0f;
        sprite.physicsBody.restitution = 1.0f;
        sprite.physicsBody.linearDamping = 0.0f;
        sprite.physicsBody.dynamic = YES;
        sprite.physicsBody.categoryBitMask = asteroidCategory;
        sprite.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | shipCategory | asteroidCategory | asteroidInShieldCategory | planetCategory | planetRingCategory | asteroidShieldCategory;
        sprite.physicsBody.contactTestBitMask = goalCategory | shipCategory | asteroidShieldCategory | powerUpSpaceMineExplodingRingCategory;
        sprite.physicsBody.mass = sprite.size.width;
        sprite.name = asteroidCategoryName;
        sprite.physicsBody.allowsRotation = YES;
        sprite.colorBlendFactor = 1.0;
        sprite.zPosition = 1;
        sprite.userData = [NSMutableDictionary dictionary];
        sprite.userData[asteroidsIndex] = @(asteroidIndex);
    }
    if ([sprite.userData valueForKey:asteroidShieldTag]) {
        sprite.name = asteroidCategoryName;
        sprite.physicsBody.categoryBitMask = asteroidCategory;
        sprite.physicsBody.collisionBitMask = borderCategory | secondaryBorderCategory | shipCategory | asteroidCategory | asteroidInShieldCategory | planetCategory | planetRingCategory | asteroidShieldCategory;
        sprite.physicsBody.contactTestBitMask = goalCategory | shipCategory | asteroidShieldCategory | powerUpSpaceMineExplodingRingCategory;
        sprite.zPosition = 1;
        [sprite.userData removeObjectForKey:asteroidShieldTag];
    }

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
    return sprite;
}

-(CGMutablePathRef)pathForAsteroidNum:(int)asteroidNum withSprite:(BaseSprite*)sprite {
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
        BaseSprite *planet;
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
        float otherWidthA, otherWidthB, otherWidthC, otherWidthD, otherWidthE, otherWidthF, otherWidthG, otherWidthH, otherWidthI, otherWidthJ, otherWidthK;
        CGPoint otherCenterA, otherCenterB, otherCenterC, otherCenterD, otherCenterE, otherCenterF, otherCenterG, otherCenterH, otherCenterI, otherCenterJ, otherCenterK;
        float distanceA, distanceB, distanceC, distanceD, distanceE, distanceF, distanceG, distanceH, distanceI, distanceJ, distanceK;
        distanceA = distanceB = distanceC = distanceD = distanceE = distanceF = distanceG = distanceH = distanceI = distanceJ = distanceK = MAXFLOAT;
        otherWidthA = otherWidthB = otherWidthC = otherWidthD = otherWidthE = otherWidthF = otherWidthG = otherWidthH = otherWidthI = otherWidthJ = otherWidthK = 0;
        if (planets.count > 0) {
            BaseSprite *otherPlanetA = planets[0];
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
            BaseSprite *otherPlanetB = planets[1];
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
        if (planets.count > 2) {
            BaseSprite *otherPlanetC = planets[2];
            if ([otherPlanetC.userData[planetNumber] intValue] == 5) {
                otherWidthC = largePlanetWidth;
            } else if (otherPlanetC.size.width >= otherPlanetC.size.height) {
                otherWidthC = otherPlanetC.size.width;
            } else {
                otherWidthC = otherPlanetC.size.height;
            }
            otherCenterC = otherPlanetC.position;
            distanceC = sqrtf(powf(thisCenter.x - otherCenterC.x, 2) + pow(thisCenter.y - otherCenterC.y, 2));
        }
        if (planets.count > 3) {
            BaseSprite *otherPlanetD = planets[3];
            if ([otherPlanetD.userData[planetNumber] intValue] == 5) {
                otherWidthD = largePlanetWidth;
            } else if (otherPlanetD.size.width >= otherPlanetD.size.height) {
                otherWidthD = otherPlanetD.size.width;
            } else {
                otherWidthD = otherPlanetD.size.height;
            }
            otherCenterD = otherPlanetD.position;
            distanceD = sqrtf(powf(thisCenter.x - otherCenterD.x, 2) + pow(thisCenter.y - otherCenterD.y, 2));
        }
        if (planets.count > 4) {
            BaseSprite *otherPlanetE = planets[4];
            if ([otherPlanetE.userData[planetNumber] intValue] == 5) {
                otherWidthE = largePlanetWidth;
            } else if (otherPlanetE.size.width >= otherPlanetE.size.height) {
                otherWidthE = otherPlanetE.size.width;
            } else {
                otherWidthE = otherPlanetE.size.height;
            }
            otherCenterE = otherPlanetE.position;
            distanceE = sqrtf(powf(thisCenter.x - otherCenterE.x, 2) + pow(thisCenter.y - otherCenterE.y, 2));
        }
        if (planets.count > 5) {
            BaseSprite *otherPlanetF = planets[5];
            if ([otherPlanetF.userData[planetNumber] intValue] == 5) {
                otherWidthF = largePlanetWidth;
            } else if (otherPlanetF.size.width >= otherPlanetF.size.height) {
                otherWidthF = otherPlanetF.size.width;
            } else {
                otherWidthF = otherPlanetF.size.height;
            }
            otherCenterF = otherPlanetF.position;
            distanceF = sqrtf(powf(thisCenter.x - otherCenterF.x, 2) + pow(thisCenter.y - otherCenterF.y, 2));
        }
        if (planets.count > 6) {
            BaseSprite *otherPlanetG = planets[6];
            if ([otherPlanetG.userData[planetNumber] intValue] == 5) {
                otherWidthG = largePlanetWidth;
            } else if (otherPlanetG.size.width >= otherPlanetG.size.height) {
                otherWidthG = otherPlanetG.size.width;
            } else {
                otherWidthG = otherPlanetG.size.height;
            }
            otherCenterG = otherPlanetG.position;
            distanceG = sqrtf(powf(thisCenter.x - otherCenterG.x, 2) + pow(thisCenter.y - otherCenterG.y, 2));
        }
        if (planets.count > 7) {
            BaseSprite *otherPlanetH = planets[7];
            if ([otherPlanetH.userData[planetNumber] intValue] == 5) {
                otherWidthH = largePlanetWidth;
            } else if (otherPlanetH.size.width >= otherPlanetH.size.height) {
                otherWidthH = otherPlanetH.size.width;
            } else {
                otherWidthH = otherPlanetH.size.height;
            }
            otherCenterH = otherPlanetH.position;
            distanceH = sqrtf(powf(thisCenter.x - otherCenterH.x, 2) + pow(thisCenter.y - otherCenterH.y, 2));
        }
        if (planets.count > 8) {
            BaseSprite *otherPlanetI = planets[8];
            if ([otherPlanetI.userData[planetNumber] intValue] == 5) {
                otherWidthI = largePlanetWidth;
            } else if (otherPlanetI.size.width >= otherPlanetI.size.height) {
                otherWidthI = otherPlanetI.size.width;
            } else {
                otherWidthI = otherPlanetI.size.height;
            }
            otherCenterI = otherPlanetI.position;
            distanceI = sqrtf(powf(thisCenter.x - otherCenterI.x, 2) + pow(thisCenter.y - otherCenterI.y, 2));
        }
        if (planets.count > 9) {
            BaseSprite *otherPlanetJ = planets[9];
            if ([otherPlanetJ.userData[planetNumber] intValue] == 5) {
                otherWidthJ = largePlanetWidth;
            } else if (otherPlanetJ.size.width >= otherPlanetJ.size.height) {
                otherWidthJ = otherPlanetJ.size.width;
            } else {
                otherWidthJ = otherPlanetJ.size.height;
            }
            otherCenterJ = otherPlanetJ.position;
            distanceJ = sqrtf(powf(thisCenter.x - otherCenterJ.x, 2) + pow(thisCenter.y - otherCenterJ.y, 2));
        }
        if (planets.count > 10) {
            BaseSprite *otherPlanetK = planets[10];
            if ([otherPlanetK.userData[planetNumber] intValue] == 5) {
                otherWidthK = largePlanetWidth;
            } else if (otherPlanetK.size.width >= otherPlanetK.size.height) {
                otherWidthK = otherPlanetK.size.width;
            } else {
                otherWidthK = otherPlanetK.size.height;
            }
            otherCenterK = otherPlanetK.position;
            distanceK = sqrtf(powf(thisCenter.x - otherCenterK.x, 2) + pow(thisCenter.y - otherCenterK.y, 2));
        }

        BOOL addPlanet = YES;
        int attempt = 0;
        while ((distanceA - (thisWidth/2) - (otherWidthA/2) < shipSize.width + 10) ||
               (distanceB - (thisWidth/2) - (otherWidthB/2) < shipSize.width + 10) ||
               (distanceC - (thisWidth/2) - (otherWidthC/2) < shipSize.width + 10) ||
               (distanceD - (thisWidth/2) - (otherWidthD/2) < shipSize.width + 10) ||
               (distanceE - (thisWidth/2) - (otherWidthE/2) < shipSize.width + 10) ||
               (distanceF - (thisWidth/2) - (otherWidthF/2) < shipSize.width + 10) ||
               (distanceG - (thisWidth/2) - (otherWidthG/2) < shipSize.width + 10) ||
               (distanceH - (thisWidth/2) - (otherWidthH/2) < shipSize.width + 10) ||
               (distanceI - (thisWidth/2) - (otherWidthI/2) < shipSize.width + 10) ||
               (distanceJ - (thisWidth/2) - (otherWidthJ/2) < shipSize.width + 10) ||
               (distanceK - (thisWidth/2) - (otherWidthK/2) < shipSize.width + 10)) {
            if (attempt > 50) {
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
            if (planets.count > 2) {
                distanceC = sqrtf(powf(thisCenter.x - otherCenterC.x, 2) + pow(thisCenter.y - otherCenterC.y, 2));
            }
            if (planets.count > 3) {
                distanceD = sqrtf(powf(thisCenter.x - otherCenterD.x, 2) + pow(thisCenter.y - otherCenterD.y, 2));
            }
            if (planets.count > 4) {
                distanceE = sqrtf(powf(thisCenter.x - otherCenterE.x, 2) + pow(thisCenter.y - otherCenterE.y, 2));
            }
            if (planets.count > 5) {
                distanceF = sqrtf(powf(thisCenter.x - otherCenterF.x, 2) + pow(thisCenter.y - otherCenterF.y, 2));
            }
            if (planets.count > 6) {
                distanceG = sqrtf(powf(thisCenter.x - otherCenterG.x, 2) + pow(thisCenter.y - otherCenterG.y, 2));
            }
            if (planets.count > 7) {
                distanceH = sqrtf(powf(thisCenter.x - otherCenterH.x, 2) + pow(thisCenter.y - otherCenterH.y, 2));
            }
            if (planets.count > 8) {
                distanceI = sqrtf(powf(thisCenter.x - otherCenterI.x, 2) + pow(thisCenter.y - otherCenterI.y, 2));
            }
            if (planets.count > 9) {
                distanceJ = sqrtf(powf(thisCenter.x - otherCenterJ.x, 2) + pow(thisCenter.y - otherCenterJ.y, 2));
            }
            if (planets.count > 10) {
                distanceK = sqrtf(powf(thisCenter.x - otherCenterK.x, 2) + pow(thisCenter.y - otherCenterK.y, 2));
            }
            attempt++;
        }
        if (addPlanet) {
            if (!planet.physicsBody) {
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
                        if ([planet.userData[planetFlavorNumber] isEqual:@(4)]) {
                            planet.zRotation = arc4random() % 360;
                        }

                    }
                }
                planet.physicsBody.dynamic = NO;
                planet.physicsBody.collisionBitMask = shipCategory | asteroidCategory | asteroidInShieldCategory | asteroidShieldCategory;
                planet.physicsBody.allowsRotation = NO;
                if (![self addRingPhysicsBodyIfApplicableForPlanet:planet] && ![planet.name isEqualToString:sunObjectSpriteName] && [planet.userData[planetNumber] intValue] < 5 && [planet.userData[planetFlavorNumber] intValue] < 4) {
                    planet.userData[moonsArray] = @[[self moonForPlanetNum:[planet.userData[planetNumber] intValue] withPlanet:planet]];
                }
                if ([planet.userData[planetNumber] intValue] >= asteroidShield0) {
                    [self addAsteroidShieldAnimationsToSprite:planet];
                }
                if ([planet.userData[planetNumber] intValue] >= asteroidShield0) {
                    NSString *imageName = @"";
                    float scale = 0;
                    float duration = 0.5;
                    if ([planet.userData[planetNumber] intValue] == asteroidShield0) {
                        imageName = @"AsteroidShield_Pop_0";
                        scale = 0.625;
                    } else {
                        imageName = @"AsteroidShield_Pop_1";
                        scale = 0.65;
                    }
                    BaseSprite *explosionSprite = [BaseSprite spriteNodeWithImageNamed:imageName];
                    explosionSprite.zPosition = 10;
                    SKAction *fadeAction = [SKAction fadeAlphaTo:0 duration:0.5];
                    SKAction *scaleAction = [SKAction scaleTo:1 duration:duration];
                    SKAction *groupAction = [SKAction group:@[fadeAction, scaleAction]];
                    explosionSprite.userData = @{@"asteroidBubblePopExplosionAction" : groupAction }.mutableCopy;
                    planet.userData[@"asteroidBubblePopExplosion"] = explosionSprite;
                }
            } else {
                if (![planet.userData[planetFlavorNumber] isEqualToNumber:@2] && ![planet.name isEqualToString:sunObjectSpriteName] && [planet.userData[planetNumber] intValue] < 5) {
                    [self adjustMoon:planet.userData[moonsArray][0] forPlanet:planet];
                }
            }
            [planets addObject:planet];
        }
    }
    NSMutableArray *asteroidsToAdd = [NSMutableArray array];
    int shieldCount = 0;
    BOOL bigPlanet = NO;
    for (BaseSprite *aPlanet in planets) {
        if ([aPlanet.userData[planetNumber] intValue] >= asteroidShield0) {
            aPlanet.userData[asteroidShieldTag] = @(shieldCount);
            aPlanet.zPosition = 10;
            int levelToUse = level;
            if (levelToUse > 14) {
                levelToUse = 14;
            }
            for (int i = 0; i < [aPlanet.userData[planetNumber] intValue]; i++) {
                BaseSprite *asteroid = [self randomAsteroidForLevel:levelToUse];
                asteroid.position = aPlanet.position;
                asteroid.zRotation = DegreesToRadians(arc4random() % 360);
                float velocity = 20;
                asteroid.physicsBody.velocity = CGVectorMake(velocity * cosf(asteroid.zRotation), velocity * -sinf(asteroid.zRotation));
                asteroid.name = asteroidInShieldCategoryName;
                asteroid.physicsBody.categoryBitMask = asteroidInShieldCategory;
                asteroid.physicsBody.collisionBitMask = shipCategory | asteroidCategory | asteroidInShieldCategory | planetCategory | asteroidShieldCategory;
                asteroid.physicsBody.contactTestBitMask = shipCategory | asteroidShieldCategory;
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

-(BOOL)addRingPhysicsBodyIfApplicableForPlanet:(BaseSprite*)planet {
    if ([planet.userData[planetFlavorNumber] isEqualToNumber:@2] && [planet.userData[planetNumber] intValue] < 5) {
        BaseSprite *extraBodySprite = [BaseSprite spriteNodeWithColor:[UIColor clearColor] size:planet.size];
        extraBodySprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForRingWithPlanetNum:[planet.userData[planetNumber] intValue] withSprite:planet]];
        extraBodySprite.physicsBody.dynamic = NO;
        extraBodySprite.physicsBody.categoryBitMask = planetRingCategory;
        extraBodySprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory;
        extraBodySprite.physicsBody.allowsRotation = NO;
//        extraBodySprite.physicsBody.mass = 100000;
        [planet addChild:extraBodySprite];
        return YES;
    }
    return NO;
}

-(void)addAsteroidShieldAnimationsToSprite:(BaseSprite*)sprite {
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
    BaseSprite *ring1 = [BaseSprite spriteNodeWithImageNamed:imageName];
    [sprite addChild:ring1];
    ring1.name = asteroidShieldRing1SpriteName;
    ring1.alpha = 0;
    [ring1 setScale:scale];
    SKAction *expandRingAction = [SKAction scaleTo:1 duration:duration];
    SKAction *alphaOutRingAction = [SKAction fadeAlphaTo:0 duration:duration];
    SKAction *groupAction = [SKAction group:@[expandRingAction,alphaOutRingAction,[SKAction waitForDuration:(duration+0.1)]]];
    SKAction *blockAction = [SKAction runBlock:^{
        [ring1 setScale:scale];
        [ring1 setAlpha:1];
    }];
    SKAction *sequenceAction = [SKAction sequence:@[blockAction, groupAction]];
    SKAction *repeatAction = [SKAction repeatActionForever:sequenceAction];
    SKAction *animationAction = [SKAction runBlock:^{
        [[sprite childNodeWithName:asteroidShieldRing1SpriteName] runAction:repeatAction];
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (level <= 3) {
            return 2;
        } else if (level <= 10) {
            return 4;
        } else if (level <= 20) {
            return 8;
        } else {
            return 12;
        }
    } else {
        if (level <= 3) {
            return 0;
        } else if (level <= 10) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:1];
        } else if (level <= 20) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:2];
        } else {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:3];
        }
    }
}


-(int)minNumberOfPlanetsForLevel:(int)level {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (level <= 15) {
            return 2;
        } else if (level <= 30) {
            return 4;
        } else {
            return 8;
        }
    } else {
        if (level <= 15) {
            return 0;
        } else if (level <= 30) {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:1];
        } else {
            return [self iPhoneRoundedAdjustedNumberForScreenSize:2];
        }
    }
}

-(BaseSprite*)randomPlanetForLevel:(int)level sunFlavor:(BOOL)sunFlavor currentPlanets:(NSArray*)planets {

    int planetNum = arc4random() % [self maxPlanetNumForLevel:level];
    int planetFlavor = arc4random() % 3;
    if (planetNum == 4 && ((arc4random() % 4) == 0)) {
        planetFlavor = 4;
    }
    if (sunFlavor) {
        planetFlavor = 3;
    }
    BOOL safeToContinue = NO;
    int i = 0;
    while (!safeToContinue && i < 50) {
        safeToContinue = YES;
        i++;
        for (BaseSprite *planet in planets) {
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
    int bubbleCount = 0;
    for (BaseSprite *planet in planets) {
        if ([planet.userData[planetNumber] intValue] == asteroidShield0 ||
            [planet.userData[planetNumber] intValue] == asteroidShield1 ) {
            bubbleCount++;
        }
    }
    BOOL isAsteroidShield = NO;
    BaseSprite *sprite;
    int planetIndex = planetNum * 4 + planetFlavor;
    if ((planetNum == 4 || planetNum == 3) && !sunFlavor) {
        if (arc4random() % 2 == 0 && bubbleCount < 2) { //50%
            if (planetNum == 4) {
                planetIndex = (int)planetTextures.count-1;
            } else {
                planetIndex = (int)planetTextures.count-2;
            }
            isAsteroidShield = YES;
        } else if (planetNum == 4 && planetFlavor == 4) {
            planetIndex = (int)planetTextures.count-4;
        }
    }
    NSMutableArray *planetArray = [planetSpritesDictionary objectForKey:[NSString stringWithFormat:kPlanetSpriteArrayKey, planetIndex]];
    if (planetArray.count) {
        sprite = planetArray[0];
        [planetArray removeObjectAtIndex:0];
        [sprite removeAllActions];
    } else {
        SKTexture *planetTexture = [planetTextures objectAtIndex:planetIndex];
        sprite = [BaseSprite spriteNodeWithTexture:planetTexture];
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
        sprite.userData[planetsIndex] = @(planetIndex);
        sprite.zPosition = 1;
    }

    
    if (![sprite.userData objectForKey:kPlanetHoverActionKey]) {
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
        SKAction *hoverAction = [SKAction repeatActionForever:[SKAction followPath:hoverPath.CGPath asOffset:YES orientToPath:NO duration:30]];
        [sprite.userData setObject:hoverAction forKey:kPlanetHoverActionKey];
    }
    
    [self randomizeSprite:sprite];
    if (planetNum == 5) {
        [self adjustGiantPlanet:sprite];
    }
    return sprite;
}

-(BaseSprite*)randomSun {
    int planetIndex = (int)planetTextures.count-3;
    NSMutableArray *planetArray = [planetSpritesDictionary objectForKey:[NSString stringWithFormat:kPlanetSpriteArrayKey, planetIndex]];
    BaseSprite *sprite;
    if (planetArray.count) {
        sprite = planetArray[0];
        [planetArray removeObject:sprite];
        [sprite removeAllActions];
    } else {
        SKTexture *planetTexture = [planetTextures objectAtIndex:planetIndex];
        sprite = [BaseSprite spriteNodeWithTexture:planetTexture];
        sprite.name = sunObjectSpriteName;
        
        sprite.userData = [NSMutableDictionary dictionary];
        sprite.userData[planetNumber] = @(5);
        sprite.userData[planetFlavorNumber] = @(4);
        sprite.userData[planetsIndex] = @(planetIndex);
        sprite.zPosition = 1;
    }
    
    if (![sprite.userData objectForKey:kPlanetHoverActionKey]) {
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
        SKAction *hoverAction = [SKAction repeatActionForever:[SKAction followPath:hoverPath.CGPath asOffset:YES orientToPath:NO duration:30]];
        [sprite.userData setObject:hoverAction forKey:kPlanetHoverActionKey];
    }

    sprite.zRotation =0;

    
    SKAction *hoverAction;
    if ([sprite.userData objectForKey:kPlanetHoverActionKey]) {
        hoverAction = [sprite.userData objectForKey:kPlanetHoverActionKey];
    } else {
        UIBezierPath *hoverPath = [UIBezierPath bezierPath];
        [hoverPath moveToPoint:CGPointZero];
        [hoverPath addCurveToPoint:CGPointMake(0 + (sprite.size.width * 0.1), 0)
                     controlPoint1:CGPointMake(0, 0 + sprite.size.height * 0.1)
                     controlPoint2:CGPointMake(0 + (sprite.size.width * 0.1), 0 + sprite.size.height * 0.1)];
        [hoverPath addCurveToPoint:CGPointZero
                     controlPoint1:CGPointMake(0 + (sprite.size.width * 0.1), 0 - sprite.size.height * 0.1)
                     controlPoint2:CGPointMake(0, 0 - sprite.size.height * 0.1)];
        [hoverPath addCurveToPoint:CGPointMake(0 - (sprite.size.width * 0.1), 0)
                     controlPoint1:CGPointMake(0, 0 + sprite.size.height * 0.1)
                     controlPoint2:CGPointMake(0 - (sprite.size.width * 0.1), 0 + sprite.size.height * 0.1)];
        [hoverPath addCurveToPoint:CGPointZero
                     controlPoint1:CGPointMake(0 - (sprite.size.width * 0.1), 0 - sprite.size.height * 0.1)
                     controlPoint2:CGPointMake(0, 0 - sprite.size.height * 0.1)];
        hoverAction = [SKAction repeatActionForever:[SKAction followPath:hoverPath.CGPath asOffset:YES orientToPath:NO duration:30]];
    }
    
    [sprite runAction:hoverAction];
    [self randomizeSprite:sprite];
    sprite.position = CGPointMake(0, sprite.position.y);
    [self adjustGiantPlanet:sprite];

    return sprite;

}

-(void)adjustGiantPlanet:(BaseSprite*)planet {
    float additionalDistance = 175;
    if (planet.position.x > sceneWidth/2) {
        [planet setPosition:CGPointMake((planet.frame.size.width/2) + sceneWidth - additionalDistance,planet.position.y)];
    } else {
        [planet setPosition:CGPointMake((planet.frame.size.width/-2) + additionalDistance ,planet.position.y)];
    }
}

-(BaseSprite*)moonForPlanetNum:(int)planetNum withPlanet:(BaseSprite*)planet {
    BaseSprite *sprite = [BaseSprite spriteNodeWithTexture:asteroidTextures[planetNum]];
    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:[self pathForAsteroidNum:planetNum withSprite:sprite]];
    sprite.physicsBody.friction = 0.0f;
    sprite.physicsBody.restitution = 1.0f;
    sprite.physicsBody.linearDamping = 0.0f;
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.categoryBitMask = asteroidCategory;
    sprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory | planetCategory | planetRingCategory;
    sprite.physicsBody.contactTestBitMask = powerUpSpaceMineExplodingRingCategory;
    sprite.physicsBody.mass = sprite.size.width;
    sprite.name = asteroidCategoryName;
    sprite.physicsBody.allowsRotation = YES;
    sprite.colorBlendFactor = 1.0;
    sprite.userData = [NSMutableDictionary dictionary];
    sprite.hidden = YES;
    sprite.zPosition = 1;
    [self adjustMoon:sprite forPlanet:planet];
    return sprite;
}

-(void)adjustMoon:(BaseSprite*)sprite forPlanet:(BaseSprite*)planet {
    float distance = planet.size.width/2 + sprite.size.width/2;
    float angle = arc4random() % 360;
    sprite.position = CGPointMake(planet.position.x + (cosf(DegreesToRadians(angle)) * distance), planet.position.y + (sinf(DegreesToRadians(angle)) * distance)) ;
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
    SKPhysicsJointPin *centerPin = [SKPhysicsJointPin jointWithBodyA:sprite.physicsBody bodyB: planet.physicsBody anchor:planet.position];
    sprite.userData[orbitJoint] = centerPin;
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

-(CGMutablePathRef)pathForRingWithPlanetNum:(int)planetNum withSprite:(BaseSprite*)sprite {
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
            
            BaseSprite *extraBodySprite = [BaseSprite spriteNodeWithColor:[UIColor clearColor] size:sprite.size];
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
            extraBodySprite.physicsBody.categoryBitMask = planetRingCategory;
            extraBodySprite.physicsBody.collisionBitMask = shipCategory | asteroidCategory | planetCategory | planetRingCategory;
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

-(int)iPhoneRoundedAdjustedNumberForScreenSize:(int)number {
    return roundf(number * ((self.size.width * self.size.height) / 181760)); // based on area of iPhone 5.
}


@end
