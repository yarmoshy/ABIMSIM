//
//  IAPView.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 6/8/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "IAPView.h"
#import "MKStoreKit.h"
#import "UpgradeTableViewCell.h"
#import "MKStoreKit.h"
#import <StoreKit/StoreKit.h>

@implementation IAPView {
    NSNumberFormatter *formatter, *_priceFormatter;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        formatter  = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IAPPurchaseComplete) name:kStoreKitPurchaseFinished object:nil];
        
    }
    return self;
}

-(void)didMoveToSuperview {
    [self.tableView registerNib:[UINib nibWithNibName:@"UpgradeTableViewCell" bundle:nil] forCellReuseIdentifier:@"UpgradeTableViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"xpCell"];
}


-(void)IAPPurchaseComplete {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeLoader];
    });
}

-(void)showLoader {
    [UIView animateWithDuration:0.5 animations:^{
        self.loaderView.alpha = 0.5;
    }];
}

-(void)removeLoader {
    [UIView animateWithDuration:0.5 animations:^{
        self.loaderView.alpha = 0;
    }];
}

- (IBAction)backButtonTapped:(id)sender {
//    self.alpha = 0;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return [[MKStoreKit sharedKit] availableProducts].count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 136;
    }
    return 120;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 136;
    }
    return 120;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *xpCell = [tableView dequeueReusableCellWithIdentifier:@"xpCell" forIndexPath:indexPath];
        for (UIView *view in xpCell.contentView.subviews) {
            [view removeFromSuperview];
        }
        xpCell.backgroundColor = xpCell.contentView.backgroundColor = [UIColor clearColor];
        
        UIImageView *youHaveImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"YouHaveTitle"]];
        youHaveImageView.center = CGPointMake(tableView.frame.size.width/2, 97 + youHaveImageView.frame.size.height/2);
        [xpCell.contentView addSubview:youHaveImageView];
        
        UILabel *xpLabel = [[UILabel alloc] init];
        xpLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:25];
        xpLabel.textColor = [UIColor colorWithRed:211.f/255.f green:12.f/255.f blue:95.f/255.f alpha:1];
        xpLabel.text = [NSString stringWithFormat:@"%@ XP",[formatter stringFromNumber:[NSNumber numberWithInteger:[ABIMSIMDefaults integerForKey:kUserDuckets]]]];
        [xpLabel sizeToFit];
        xpLabel.center = CGPointMake(youHaveImageView.center.x, youHaveImageView.center.y + youHaveImageView.frame.size.height/2 + xpLabel.frame.size.height/2);
        [xpCell.contentView addSubview:xpLabel];
        
        UIImageView *leftBracket = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LeftXPBracket"]];
        leftBracket.center = CGPointMake(xpLabel.frame.origin.x - leftBracket.frame.size.width, (youHaveImageView.frame.origin.y + xpLabel.frame.origin.y + xpLabel.frame.size.height)/2 - 4);
        [xpCell.contentView addSubview:leftBracket];
        
        UIImageView *rightBracket = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightXPBracket"]];
        rightBracket.center = CGPointMake(xpLabel.frame.origin.x + xpLabel.frame.size.width + rightBracket.frame.size.width, (youHaveImageView.frame.origin.y + xpLabel.frame.origin.y + xpLabel.frame.size.height)/2 - 4);
        [xpCell.contentView addSubview:rightBracket];
        
        return xpCell;
    } else {
        UpgradeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpgradeTableViewCell" forIndexPath:indexPath];
        cell.backgroundColor = cell.contentView.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        cell.contentView.alpha = 1;
        cell.upgradeButton.alpha = 1;
        cell.upgradeTypeLabel.alpha = 1;
        cell.xpRequiredLabel.alpha = 1;
        [self configureCell:cell forIndexPath:indexPath];
        return cell;
    }
}

#define disabledAlpha 0.3f

-(void)configureCell:(UpgradeTableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath {
    switch (indexPath.row) {
        case 0:
            cell.cellType = UpgradeTableViewCellTypeIAPZero;
            break;
        case 1:
            cell.cellType = UpgradeTableViewCellTypeIAPOne;
            break;
        case 2:
            cell.cellType = UpgradeTableViewCellTypeIAPTwo;
            break;
        case 3:
            cell.cellType = UpgradeTableViewCellTypeIAPThree;
            break;
        case 4:
            cell.cellType = UpgradeTableViewCellTypeIAPFour;
            break;
        default:
            break;
    }
    SKProduct *product = [[[MKStoreKit sharedKit] availableProducts] objectAtIndex:indexPath.row];
    
    cell.upgradeTypeLabel.text = product.localizedTitle;
    cell.unlimitedUpgradesHeightConstraint.constant = 0;
    
    [_priceFormatter setLocale:product.priceLocale];
    cell.xpRequiredLabel.text = [_priceFormatter stringFromNumber:product.price];
    
    cell.ringImageView.image = nil;
    cell.descriptionLabel.text = @"TO-DO: FILL ME OUT BITCH";
    if (200 == 5) {
        cell.upgradeButton.alpha = 0;
        cell.xpRequiredLabel.text = @"FULLY UPGRADED";
        cell.upgradeButton.enabled = NO;
    } else if ([ABIMSIMDefaults integerForKey:kUserDuckets] < (200+1)*20) {
        cell.upgradeButton.alpha = 1;
        cell.upgradeButton.enabled = NO;
    } else {
        cell.upgradeButton.alpha = 1;
        cell.upgradeButton.enabled = YES;
    }
}




-(void)upgradeCellTapped:(UpgradeTableViewCell*)cell {
//    if (animating) {
//        return;
//    }
//    BOOL unlock = NO;
//    BOOL delay = NO;
//    switch (cell.cellType) {
//        case UpgradeTableViewCellTypeHolsterNuke: {
//            long newValue = holsterNukes+1;
//            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_10Pieces_%ld",newValue]];
//            [ABIMSIMDefaults setInteger:newValue forKey:kHolsterNukes];
//        }
//            break;
//        case UpgradeTableViewCellTypeHolsterCapacity: {
//            long newValue = holsterCapacity+1;
//            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_5Pieces_%ld",newValue]];
//            [ABIMSIMDefaults setInteger:newValue forKey:kHolsterCapacity];
//            [ABIMSIMDefaults setInteger:newValue forKey:kHolsterNukes];
//        }
//            break;
//        case UpgradeTableViewCellTypeMineBlastSpeed: {
//            long newValue = mineBlastSpeed+1;
//            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_5Pieces_%ld",newValue]];
//            [ABIMSIMDefaults setInteger:newValue forKey:kMineBlastSpeedLevel];
//        }
//            break;
//        case UpgradeTableViewCellTypeShieldOccurance: {
//            long newValue = shieldOccurance+1;
//            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_10Pieces_%ld",newValue]];
//            [ABIMSIMDefaults setInteger:newValue forKey:kShieldOccuranceLevel];
//        }
//            break;
//        case UpgradeTableViewCellTypeMineOccurance: {
//            long newValue = mineOccurance+1;
//            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_10Pieces_%ld",newValue]];
//            [ABIMSIMDefaults setInteger:newValue forKey:kMineOccuranceLevel];
//        }
//            break;
//        case UpgradeTableViewCellTypeShieldStrength: {
//            long newValue = shieldDurability+1;
//            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_10Pieces_%ld",newValue]];
//            [ABIMSIMDefaults setInteger:newValue forKey:kShieldDurabilityLevel];
//        }
//            break;
//        case UpgradeTableViewCellTypeStartWithShield: {
//            long newValue = shieldOnStart+1;
//            cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
//            [ABIMSIMDefaults setInteger:newValue forKey:kShieldOnStart];
//        }
//            break;
//        case UpgradeTableViewCellTypeUnlockMines: {
//            unlock = YES;
//            long newValue = mineOccurance+1;
//            cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
//            [ABIMSIMDefaults setInteger:newValue forKey:kMineOccuranceLevel];
//        }
//            break;
//        case UpgradeTableViewCellTypeUnlockShield: {
//            unlock = YES;
//            long newValue = shieldOccurance+1;
//            cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
//            [ABIMSIMDefaults setInteger:newValue forKey:kShieldOccuranceLevel];
//        }
//            break;
//        case UpgradeTableViewCellTypeUnlockArmory: {
//            unlock = YES;
//            long newValue = holsterCapacity+1;
//            cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
//            [ABIMSIMDefaults setInteger:newValue forKey:kHolsterCapacity];
//            [ABIMSIMDefaults setInteger:newValue forKey:kHolsterNukes];
//        }
//            break;
//        default:
//            break;
//    }
//    int ducketCost = [[[cell.xpRequiredLabel.text substringToIndex:[cell.xpRequiredLabel.text rangeOfString:@" XP"].location] stringByReplacingOccurrencesOfString:@"," withString:@""] intValue];
//    [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] - ducketCost forKey:kUserDuckets];
//    [ABIMSIMDefaults synchronize];
//    [[AudioController sharedController] upgrade];
//    if (unlock) {
//        animating = YES;
//        [UIView animateWithDuration:0.5 animations:^{
//            cell.contentView.alpha = 0;
//        }];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView beginUpdates];
//            NSArray *indexPathsToDelete;
//            if (cell.cellType == UpgradeTableViewCellTypeUnlockMines) {
//                indexPathsToDelete = @[[NSIndexPath indexPathForRow:1 inSection:2]];
//            } else if (cell.cellType == UpgradeTableViewCellTypeUnlockShield) {
//                indexPathsToDelete = @[[NSIndexPath indexPathForRow:1 inSection:1]];
//            } else if (cell.cellType == UpgradeTableViewCellTypeUnlockArmory) {
//                indexPathsToDelete = @[[NSIndexPath indexPathForRow:1 inSection:3]];
//            }
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//            [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
//            [self.tableView endUpdates];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.tableView beginUpdates];
//                [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
//                [self.tableView endUpdates];
//                animating = NO;
//            });
//        });
//    } else {
//        if (delay) {
//            animating = YES;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//                animating = NO;
//            });
//        } else
//            [self.tableView reloadData];
//    }
}


@end
