//
//  BlackHole.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/31/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "BlackHole.h"

@implementation BlackHole

static NSMutableArray *blackHoleTextures;

+(instancetype)blackHole {
    if (!blackHoleTextures) {
        blackHoleTextures = [NSMutableArray array];
        for (int i = 0; i < 8; i++) {
            NSString *textureName = [NSString stringWithFormat:@"blackHole%d", i];
//            NSLog(@"%@",textureName);
            [blackHoleTextures addObject:[SKTexture textureWithImageNamed:textureName]];
        }
        [SKTexture preloadTextures:blackHoleTextures withCompletionHandler:^{
            ;
        }];
    }
    return [[BlackHole alloc] initWithTextures:blackHoleTextures];
}

-(id)initWithTextures:(NSArray*)blackHoleTextures {
    NSMutableArray *blackholeSprites = [NSMutableArray arrayWithCapacity:blackHoleTextures.count];
    for (int i = 0; i < blackHoleTextures.count; i++) {
        SKSpriteNode *blackHoleSprite = [SKSpriteNode spriteNodeWithTexture:blackHoleTextures[i]];
        [blackholeSprites addObject:blackHoleSprite];
    }
    if (self = [super initWithColor:[UIColor clearColor] size:((SKSpriteNode*)blackholeSprites.lastObject).size]) {
        for (SKSpriteNode *sprite in blackholeSprites) {
            [self addChild:sprite];
            double index = (double)[blackholeSprites indexOfObject:sprite];
            if (index == 0) {
                continue;
            }
            sprite.userData = [NSMutableDictionary dictionary];
            SKAction *rotateAction = [SKAction rotateByAngle:360 duration:index*10];
            sprite.userData[blackHoleAnimation] = [SKAction repeatActionForever:rotateAction];
        }
        self.name = blackHoleCategoryName;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:40];
        self.physicsBody.mass = 1000000000;
        self.physicsBody.categoryBitMask = blackHoleCategory;
        self.physicsBody.contactTestBitMask = shipCategory | asteroidCategory | asteroidInShieldCategory | planetCategory | asteroidShieldCategory;
        self.physicsBody.collisionBitMask = blackHoleCategory;
        
        self.userData = [NSMutableDictionary dictionary];
        
        SKAction *blackHoleAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            for (SKSpriteNode *sprite in node.children) {
                [sprite runAction:sprite.userData[blackHoleAnimation]];
            }
        }];
        
        SKAction *moveRight = [SKAction moveByX:[UIScreen mainScreen].bounds.size.width+self.size.width y:0 duration:5];
        SKAction *moveLeft = [SKAction moveByX:-([UIScreen mainScreen].bounds.size.width+self.size.width) y:0 duration:5];
        SKAction *wait = [SKAction waitForDuration:2];
        SKAction *both;
        if (arc4random() % 2 == 0) {
            self.position = CGPointMake(-self.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            both = [SKAction sequence:@[wait,moveRight,wait,moveLeft]];
        } else {
            self.position = CGPointMake([UIScreen mainScreen].bounds.size.width + self.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            both = [SKAction sequence:@[wait,moveLeft,wait,moveRight]];
        }
        SKAction *repeateMovementAnimation = [SKAction repeatActionForever:both];
        
        SKAction *animation = [SKAction group:@[blackHoleAction, repeateMovementAnimation]];
        self.userData[blackHoleAnimation] = animation;
        
        self.zPosition = -1;
    }
    return self;
}

@end
