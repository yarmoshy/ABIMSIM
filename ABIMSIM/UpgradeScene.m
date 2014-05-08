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
        ducketCount.text = [NSString stringWithFormat:@"%d", [ABIMSIMDefaults integerForKey:kUserDuckets]];
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
        survivabilityCostLabel.text = [NSString stringWithFormat:@"%d", [self survivabilityUpgradeCost]];
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
    int upgradeLevel = [ABIMSIMDefaults integerForKey:kSurvivabilityLevel];
    switch (upgradeLevel) {
        case 0:
            upgradeString = @"Unlock Shield";
            break;
            
        default:
            upgradeString = @"Increase Shield Occurance";
            break;
    }
    return upgradeString;
}

-(int)survivabilityUpgradeCost {
    int upgradeLevel = [ABIMSIMDefaults integerForKey:kSurvivabilityLevel];
    int upgradeCost = 20 * (upgradeLevel+1);
    return upgradeCost;
}

-(void)upgradeSurvivability {
    if ([ABIMSIMDefaults integerForKey:kUserDuckets] >= [self survivabilityUpgradeCost]) {
        int upgradeLevel = [ABIMSIMDefaults integerForKey:kSurvivabilityLevel];
        switch (upgradeLevel) {
            case 0:
                [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kShieldOccuranceLevel]+1 forKey:kShieldOccuranceLevel];
                break;
                
            default:
                [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kShieldOccuranceLevel]+1 forKey:kShieldOccuranceLevel];
                break;
        }
        [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] - [self survivabilityUpgradeCost] forKey:kUserDuckets];
        [ABIMSIMDefaults setInteger:upgradeLevel+1 forKey:kSurvivabilityLevel];
        [ABIMSIMDefaults synchronize];
        ((SKLabelNode*)[self childNodeWithName:ducketCountLabelName]).text = [NSString stringWithFormat:@"%d",[ABIMSIMDefaults integerForKey:kUserDuckets]];
        ((SKLabelNode*)[self childNodeWithName:survivabilityNextUpgradeLabelName]).text = [self survivabilityUpgradeAvailableString];
        ((SKLabelNode*)[self childNodeWithName:nextUpgradeDucketCostLabelName]).text = [NSString stringWithFormat:@"%d",[self survivabilityUpgradeCost]];

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
