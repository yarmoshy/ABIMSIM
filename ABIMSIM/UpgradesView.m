//
//  UpgradesView.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 4/2/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "UpgradesView.h"

#define kTypeCellHeight 40

@implementation UpgradesView {
    long shieldOccurance, shieldDurability, shieldOnStart, mineOccurance, mineBlastSpeed;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

-(void)didMoveToSuperview {
    [self.tableView registerNib:[UINib nibWithNibName:@"UpgradeTableViewCell" bundle:nil] forCellReuseIdentifier:@"UpgradeTableViewCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"xpCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"typeCell"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    shieldOccurance = [ABIMSIMDefaults integerForKey:kShieldOccuranceLevel];
    shieldDurability = [ABIMSIMDefaults integerForKey:kShieldDurabilityLevel];
    shieldOnStart = [ABIMSIMDefaults integerForKey:kShieldOnStart];
    mineOccurance = [ABIMSIMDefaults integerForKey:kMineOccuranceLevel];
    mineBlastSpeed = [ABIMSIMDefaults integerForKey:kMineBlastSpeedLevel];

    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        if (shieldOccurance > 0) {
            return 4;
        } else {
            return 5;
        }
    }
    if (section == 2) {
        if (mineOccurance > 0) {
            return 3;
        } else {
            return 4;
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 50;
    }
    if (indexPath.section > 0 && indexPath.row == 0) {
        return kTypeCellHeight;
    }
    return 122;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0 && indexPath.row == 0) {
        return kTypeCellHeight;
    }
    return 122;
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
        youHaveImageView.center = CGPointMake(tableView.frame.size.width/2, 10 + youHaveImageView.frame.size.height/2);
        [xpCell.contentView addSubview:youHaveImageView];
        
        UILabel *xpLabel = [[UILabel alloc] init];
        xpLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:25];
        xpLabel.textColor = [UIColor colorWithRed:211.f/255.f green:12.f/255.f blue:95.f/255.f alpha:1];
        xpLabel.text = [NSString stringWithFormat:@"%ld XP",(long)[ABIMSIMDefaults integerForKey:kUserDuckets]];
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
        if (indexPath.row == 0) {
            UITableViewCell *typeCell = [tableView dequeueReusableCellWithIdentifier:@"typeCell" forIndexPath:indexPath];
            for (UIView *view in typeCell.contentView.subviews) {
                [view removeFromSuperview];
            }
            typeCell.backgroundColor = typeCell.contentView.backgroundColor = [UIColor clearColor];
            UIImageView *upgradeIconImage;
            if (indexPath.section == 1) {
                upgradeIconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShipShield"]];
            } else {
                upgradeIconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MineIcon"]];
            }
            upgradeIconImage.frame = CGRectMake(15, 5, 30, 30);
            [typeCell.contentView addSubview:upgradeIconImage];
            
            UIImageView *upgradeTypeImage;
            if (indexPath.section == 1) {
                upgradeTypeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShieldsTitle"]];
            } else {
                upgradeTypeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MinesTitle"]];
            }
            upgradeTypeImage.frame = CGRectMake(upgradeIconImage.frame.size.width + upgradeIconImage.frame.origin.x + 5, (kTypeCellHeight - upgradeTypeImage.frame.size.height)/2, upgradeTypeImage.frame.size.width, upgradeTypeImage.frame.size.height);
            [typeCell.contentView addSubview:upgradeTypeImage];
            
            UIImageView *divider;
            if (indexPath.section == 1) {
                divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShieldsDivider"]];
            } else {
                divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MinesDivider"]];
            }
            divider.frame = CGRectMake(upgradeTypeImage.frame.size.width + upgradeTypeImage.frame.origin.x + 15, (kTypeCellHeight - divider.frame.size.height)/2, tableView.frame.size.width - upgradeTypeImage.frame.size.width + upgradeTypeImage.frame.origin.x + 15, divider.frame.size.height);
            [typeCell.contentView addSubview:divider];
            return typeCell;
        } else {
            UpgradeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpgradeTableViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.contentView.alpha = 1;
            if (indexPath.section == 1) {
                if (shieldOccurance > 0) {
                    switch (indexPath.row) {
                        case 1:
                            [self configureStartWithShieldCell:cell];
                            break;
                        case 2:
                            [self configureShieldOccuranceCell:cell];
                            break;
                        case 3:
                            [self configureShieldStrengthCell:cell];
                            break;
                        default:
                            break;
                    }
                } else {
                    switch (indexPath.row) {
                        case 1:
                            [self configureUnlockShieldCell:cell];
                            break;
                        case 2:
                            [self configureStartWithShieldCell:cell];
                            break;
                        case 3:
                            [self configureShieldOccuranceCell:cell];
                            break;
                        case 4:
                            [self configureShieldStrengthCell:cell];
                            break;
                        default:
                            break;
                    }
                    if (indexPath.row > 1) {
                        cell.contentView.alpha = 0.5;
                        cell.upgradeLabel.alpha = 0.5;
                        cell.upgradeButton.enabled = NO;
                    }
                }
            } else if (indexPath.section == 2) {
                if (mineOccurance > 0) {
                    switch (indexPath.row) {
                        case 1:
                            [self configureMineOccuranceCell:cell];
                            break;
                        case 2:
                            [self configureMineBlastSpeedCell:cell];
                            break;
                        default:
                            break;
                    }
                } else {
                    switch (indexPath.row) {
                        case 1:
                            [self configureUnlockMinesCell:cell];
                            break;
                        case 2:
                            [self configureMineOccuranceCell:cell];
                            break;
                        case 3:
                            [self configureMineBlastSpeedCell:cell];
                            break;
                        default:
                            break;
                    }
                    if (indexPath.row > 1) {
                        cell.contentView.alpha = 0.5;
                        cell.upgradeLabel.alpha = 0.5;
                        cell.upgradeButton.enabled = NO;
                    }
                }
            }
            return cell;
        }
    }
}

- (IBAction)backButtonTapped:(id)sender {
    [self.delegate upgradesViewDidSelectBackButton];
}

-(void)configureUnlockShieldCell:(UpgradeTableViewCell*)cell {
    cell.cellType = UpgradeTableViewCellTypeUnlockShield;
    cell.upgradeTypeImageView.image = [UIImage imageNamed:@"UnlockShieldTitle"];
    cell.unlimitedUpgradesHeightConstraint.constant = 0;
    cell.xpRequiredLabel.text = @"10 XP";
    cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Empty"];
    cell.descriptionLabel.text = @"The shield will become available to use and upgrade.";
    if ([ABIMSIMDefaults integerForKey:kUserDuckets] < 10) {
        cell.upgradeLabel.alpha = 0.5;
        cell.upgradeButton.enabled = NO;
    } else {
        cell.upgradeLabel.alpha = 1;
        cell.upgradeButton.enabled = YES;
    }
}

-(void)configureStartWithShieldCell:(UpgradeTableViewCell*)cell {
    cell.cellType = UpgradeTableViewCellTypeStartWithShield;
    cell.upgradeTypeImageView.image = [UIImage imageNamed:@"StartWithShieldTitle"];
    cell.unlimitedUpgradesHeightConstraint.constant = 0;
    cell.xpRequiredLabel.text = @"100 XP";
    cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Empty"];
    cell.descriptionLabel.text = @"Your ship will start with a shield at the beginning of each game.";
    if (shieldOnStart > 0) {
        cell.upgradeLabel.alpha = 0;
        cell.xpRequiredLabel.text = @"";
        cell.upgradeButton.enabled = NO;
        cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
    } else if ([ABIMSIMDefaults integerForKey:kUserDuckets] < 100) {
        cell.upgradeLabel.alpha = 0.5;
        cell.upgradeButton.enabled = NO;
    } else {
        cell.upgradeLabel.alpha = 1;
        cell.upgradeButton.enabled = YES;
    }
}

-(void)configureShieldOccuranceCell:(UpgradeTableViewCell*)cell {
    cell.cellType = UpgradeTableViewCellTypeShieldOccurance;
    cell.upgradeTypeImageView.image = [UIImage imageNamed:@"ShieldOccuranceTitle"];
    cell.unlimitedUpgradesHeightConstraint.constant = 0;
    cell.xpRequiredLabel.text = [NSString stringWithFormat:@"%ld XP",(shieldOccurance+1)*10];
    cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_10Pieces_%ld", shieldOccurance]];
    cell.descriptionLabel.text = @"The higher your upgrade, the more often the shield will become available.";
    if (shieldOccurance == 10) {
        cell.upgradeLabel.alpha = 0;
        cell.upgradeButton.enabled = NO;
        cell.xpRequiredLabel.text = @"";
    } else if ([ABIMSIMDefaults integerForKey:kUserDuckets] < (shieldOccurance+1)*10) {
        cell.upgradeLabel.alpha = 0.5;
        cell.upgradeButton.enabled = NO;
    } else {
        cell.upgradeLabel.alpha = 1;
        cell.upgradeButton.enabled = YES;
    }
}

-(void)configureShieldStrengthCell:(UpgradeTableViewCell*)cell {
    cell.cellType = UpgradeTableViewCellTypeShieldStrength;
    cell.upgradeTypeImageView.image = [UIImage imageNamed:@"ShieldStrengthText"];
    cell.xpRequiredLabel.text = [NSString stringWithFormat:@"%ld XP",(shieldDurability+1)*100];
    cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Empty"];
    cell.unlimitedUpgradesHeightConstraint.constant = 10;
    cell.descriptionLabel.text = @"The higher your upgrade, the more hits it will take to pop your shield.";
    if ([ABIMSIMDefaults integerForKey:kUserDuckets] < (shieldDurability+1)*100) {
        cell.upgradeLabel.alpha = 0.5;
        cell.upgradeButton.enabled = NO;
    } else {
        cell.upgradeLabel.alpha = 1;
        cell.upgradeButton.enabled = YES;
    }
}

-(void)configureUnlockMinesCell:(UpgradeTableViewCell*)cell {
    cell.cellType = UpgradeTableViewCellTypeUnlockMines;
    cell.upgradeTypeImageView.image = [UIImage imageNamed:@"UnlockMinesText"];
    cell.unlimitedUpgradesHeightConstraint.constant = 0;
    cell.xpRequiredLabel.text = @"10 XP";
    cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Empty"];
    cell.descriptionLabel.text = @"The mines will become available to use and upgrade.";
    if ([ABIMSIMDefaults integerForKey:kUserDuckets] < 10) {
        cell.upgradeLabel.alpha = 0.5;
        cell.upgradeButton.enabled = NO;
    } else {
        cell.upgradeLabel.alpha = 1;
        cell.upgradeButton.enabled = YES;
    }
}

-(void)configureMineOccuranceCell:(UpgradeTableViewCell*)cell {
    cell.cellType = UpgradeTableViewCellTypeMineOccurance;
    cell.upgradeTypeImageView.image = [UIImage imageNamed:@"MineOccuranceText"];
    cell.unlimitedUpgradesHeightConstraint.constant = 0;
    cell.xpRequiredLabel.text = [NSString stringWithFormat:@"%ld XP",(mineOccurance+1)*10];
    cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_10Pieces_%ld", mineOccurance]];
    cell.descriptionLabel.text = @"The higher your upgrade, the more often the mines will become available.";
    if (mineOccurance == 10) {
        cell.upgradeLabel.alpha = 0;
        cell.xpRequiredLabel.text = @"";
        cell.upgradeButton.enabled = NO;
    } else if ([ABIMSIMDefaults integerForKey:kUserDuckets] < (mineOccurance+1)*10) {
        cell.upgradeLabel.alpha = 0.5;
        cell.upgradeButton.enabled = NO;
    } else {
        cell.upgradeLabel.alpha = 1;
        cell.upgradeButton.enabled = YES;
    }
}

-(void)configureMineBlastSpeedCell:(UpgradeTableViewCell*)cell {
    cell.cellType = UpgradeTableViewCellTypeMineBlastSpeed;
    cell.upgradeTypeImageView.image = [UIImage imageNamed:@"BlastSpeedText"];
    cell.unlimitedUpgradesHeightConstraint.constant = 0;
    cell.xpRequiredLabel.text = [NSString stringWithFormat:@"%ld XP",(mineBlastSpeed+1)*20];
    cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_5Pieces_%ld", mineBlastSpeed]];
    cell.descriptionLabel.text = @"The high your upgrade, the faster the mine will explode and clear out obstacles.";
    if (mineBlastSpeed == 5) {
        cell.upgradeLabel.alpha = 0;
        cell.xpRequiredLabel.text = @"";
        cell.upgradeButton.enabled = NO;
    } else if ([ABIMSIMDefaults integerForKey:kUserDuckets] < (mineBlastSpeed+1)*20) {
        cell.upgradeLabel.alpha = 0.5;
        cell.upgradeButton.enabled = NO;
    } else {
        cell.upgradeLabel.alpha = 1;
        cell.upgradeButton.enabled = YES;
    }
}

-(void)upgradeCellTapped:(UpgradeTableViewCell*)cell {
    BOOL unlock = NO;
    BOOL delay = NO;
    switch (cell.cellType) {
        case UpgradeTableViewCellTypeMineBlastSpeed: {
            long newValue = mineBlastSpeed+1;
            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_5Pieces_%ld",newValue]];
            [ABIMSIMDefaults setInteger:newValue forKey:kMineBlastSpeedLevel];
        }
            break;
        case UpgradeTableViewCellTypeShieldOccurance: {
            long newValue = shieldOccurance+1;
            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_10Pieces_%ld",newValue]];
            [ABIMSIMDefaults setInteger:newValue forKey:kShieldOccuranceLevel];
        }
            break;
        case UpgradeTableViewCellTypeMineOccurance: {
            long newValue = mineOccurance+1;
            cell.ringImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Ring_10Pieces_%ld",newValue]];
            [ABIMSIMDefaults setInteger:newValue forKey:kMineOccuranceLevel];
        }
            break;
        case UpgradeTableViewCellTypeShieldStrength: {
            delay = YES;
            long newValue = shieldDurability+1;
            cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
            [ABIMSIMDefaults setInteger:newValue forKey:kShieldDurabilityLevel];
        }
            break;
        case UpgradeTableViewCellTypeStartWithShield: {
            long newValue = shieldOnStart+1;
            cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
            [ABIMSIMDefaults setInteger:newValue forKey:kShieldOnStart];
        }
            break;
        case UpgradeTableViewCellTypeUnlockMines: {
            unlock = YES;
            long newValue = mineOccurance+1;
            cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
            [ABIMSIMDefaults setInteger:newValue forKey:kMineOccuranceLevel];
        }
            break;
        case UpgradeTableViewCellTypeUnlockShield: {
            unlock = YES;
            long newValue = shieldOccurance+1;
            cell.ringImageView.image = [UIImage imageNamed:@"SolidRing_Full"];
            [ABIMSIMDefaults setInteger:newValue forKey:kShieldOccuranceLevel];
        }
            break;
        default:
            break;
    }
    int ducketCost = [[cell.xpRequiredLabel.text substringToIndex:[cell.xpRequiredLabel.text rangeOfString:@" XP"].location] intValue];
    [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] - ducketCost forKey:kUserDuckets];
    [ABIMSIMDefaults synchronize];
    if (unlock) {
        [UIView animateWithDuration:0.5 animations:^{
            cell.contentView.alpha = 0;
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            NSArray *indexPathsToDelete, *indexPathsToUpdate;
            if (cell.cellType == UpgradeTableViewCellTypeUnlockMines) {
                indexPathsToDelete = @[[NSIndexPath indexPathForRow:1 inSection:2]];
                indexPathsToUpdate = @[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:2], [NSIndexPath indexPathForRow:2 inSection:2]];
            } else {
                indexPathsToDelete = @[[NSIndexPath indexPathForRow:1 inSection:1]];
                indexPathsToUpdate = @[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1], [NSIndexPath indexPathForRow:3 inSection:1]];
            }
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:indexPathsToUpdate withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            });
        });
    } else {
        if (delay) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else
            [self.tableView reloadData];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
