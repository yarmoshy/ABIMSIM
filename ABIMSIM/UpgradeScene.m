//
//  UpgradeScene.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 5/7/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//
#import "GameScene.h"
#import "UpgradeScene.h"

static NSString* survivabilityButtonName = @"survivabilityButtonName";
static NSString* survivabilityNextUpgradeLabelName = @"survivabilityNextUpgradeLabelName";
static NSString* ducketCountLabelName = @"ducketLabelName";
static NSString* nextUpgradeDucketCostLabelName = @"nextUpgradeDucketCostLabelName";

@implementation UpgradeScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        SKLabelNode *ducketLabel = [SKLabelNode labelNodeWithFontNamed:@"Voltaire"];
        ducketLabel.text = @"Available Space Duckets";
        ducketLabel.fontSize = 16;
        ducketLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*3/4);
        ducketLabel.zPosition = 100;
        [self addChild:ducketLabel];
        
        SKLabelNode *ducketCount = [SKLabelNode labelNodeWithFontNamed:@"Voltaire"];
        ducketCount.text = [NSString stringWithFormat:@"%ld", (long)[ABIMSIMDefaults integerForKey:kUserDuckets]];
        ducketCount.fontSize = 26;
        ducketCount.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*3/4 - 30);
        ducketCount.zPosition = 100;
        ducketCount.name = ducketCountLabelName;

        [self addChild:ducketCount];

        SKLabelNode *survivabilityUpgradeLabel = [SKLabelNode labelNodeWithFontNamed:@"Voltaire"];
        survivabilityUpgradeLabel.text = @"Next Survivability Upgrade";
        survivabilityUpgradeLabel.fontSize = 16;
        survivabilityUpgradeLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*3/4 - 60);
        survivabilityUpgradeLabel.zPosition = 100;
        [self addChild:survivabilityUpgradeLabel];

        SKLabelNode *survivabilityLabel = [SKLabelNode labelNodeWithFontNamed:@"Voltaire"];
        survivabilityLabel.text = [self survivabilityUpgradeAvailableString];
        survivabilityLabel.fontSize = 26;
        survivabilityLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*3/4 - 90);
        survivabilityLabel.zPosition = 100;
        survivabilityLabel.name = survivabilityNextUpgradeLabelName;
        [self addChild:survivabilityLabel];
        
        SKLabelNode *survivabilityCostLabel = [SKLabelNode labelNodeWithFontNamed:@"Voltaire"];
        survivabilityCostLabel.text = [NSString stringWithFormat:@"%ld", (long)[self survivabilityUpgradeCost]];
        survivabilityCostLabel.fontSize = 26;
        survivabilityCostLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*3/4 - 130);
        survivabilityCostLabel.zPosition = 100;
        [self addChild:survivabilityCostLabel];
        survivabilityCostLabel.name = nextUpgradeDucketCostLabelName;
        
        SKSpriteNode *survivabilityButton = [SKSpriteNode spriteNodeWithImageNamed:@"BlankButton"];
        survivabilityButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height*3/4 - 120);
        survivabilityButton.zPosition = 100;
        survivabilityButton.name = survivabilityButtonName;
        [self addChild:survivabilityButton];

    }
    return self;
}


-(NSString*)survivabilityUpgradeAvailableString {
    NSString *upgradeString = @"";
    NSInteger upgradeLevel = [ABIMSIMDefaults integerForKey:kSurvivabilityLevel];
    switch (upgradeLevel) {
        case 0:
            upgradeString = @"Unlock Shield";
            break;
        case 1:
        case 2:
        case 4:
        case 5:
        case 7:
        case 8:
        case 10:
        case 11:
        case 13:
            upgradeString = @"Increase Shield Occurance";
            break;
        case 6:
        case 14:
        case 18:
            upgradeString = @"Boost Shield Fire Resistance";
            break;
        case 9:
            upgradeString = @"Start With Shield";
            break;
        case 3:
        case 12:
            upgradeString = @"Increase Shield Strength";
            break;
        default:
            upgradeString = @"Increase Hull Strength";
            break;
    }
    return upgradeString;
}

-(NSInteger)survivabilityUpgradeCost {
    NSInteger upgradeLevel = [ABIMSIMDefaults integerForKey:kSurvivabilityLevel];
    NSInteger upgradeCost = 10 * (upgradeLevel+1);
    return upgradeCost;
}

-(void)upgradeSurvivability {
    if ([ABIMSIMDefaults integerForKey:kUserDuckets] >= [self survivabilityUpgradeCost]) {
        NSInteger upgradeLevel = [ABIMSIMDefaults integerForKey:kSurvivabilityLevel];
        switch (upgradeLevel) {
            case 0:
            case 1:
            case 2:
            case 4:
            case 5:
            case 7:
            case 8:
            case 10:
            case 11:
            case 13:
                [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kShieldOccuranceLevel]+1 forKey:kShieldOccuranceLevel];
                break;
            case 6:
            case 14:
            case 18:
                [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kShieldFireDurabilityLevel]+1 forKey:kShieldFireDurabilityLevel];
                break;
            case 9:
                [ABIMSIMDefaults setBool:YES forKey:kShieldOnStart];
                break;
            case 3:
            case 12:
                [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kShieldDurabilityLevel]+1 forKey:kShieldDurabilityLevel];
                break;
            default:
                [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kHullDurabilityLevel]+1 forKey:kHullDurabilityLevel];
                break;
        }
        [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] - [self survivabilityUpgradeCost] forKey:kUserDuckets];
        [ABIMSIMDefaults setInteger:upgradeLevel+1 forKey:kSurvivabilityLevel];
        [ABIMSIMDefaults synchronize];
        ((SKLabelNode*)[self childNodeWithName:ducketCountLabelName]).text = [NSString stringWithFormat:@"%ld",(long)[ABIMSIMDefaults integerForKey:kUserDuckets]];
        ((SKLabelNode*)[self childNodeWithName:survivabilityNextUpgradeLabelName]).text = [self survivabilityUpgradeAvailableString];
        ((SKLabelNode*)[self childNodeWithName:nextUpgradeDucketCostLabelName]).text = [NSString stringWithFormat:@"%ld",(long)[self survivabilityUpgradeCost]];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    if ([node.name isEqualToString:survivabilityButtonName]) {
        [self upgradeSurvivability];
    } else {
        [self.view presentScene:[GameScene sceneWithSize:self.size] transition:[SKTransition pushWithDirection:SKTransitionDirectionRight duration:1]];
    }
}


@end
