//
//  UpgradeTableViewCell.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 4/4/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UpgradeTableViewCell;
typedef enum {
    UpgradeTableViewCellTypeUnlockShield,
    UpgradeTableViewCellTypeStartWithShield,
    UpgradeTableViewCellTypeShieldOccurance,
    UpgradeTableViewCellTypeShieldStrength,
    UpgradeTableViewCellTypeUnlockMines,
    UpgradeTableViewCellTypeMineOccurance,
    UpgradeTableViewCellTypeMineBlastSpeed,
    UpgradeTableViewCellTypeUnlockArmory,
    UpgradeTableViewCellTypeHolsterCapacity,
    UpgradeTableViewCellTypeHolsterNuke
} UpgradeTableViewCellType;

@protocol UpgradeTableViewCellDelegate <NSObject>
-(void)upgradeCellTapped:(UpgradeTableViewCell*)cell;

@end

@interface UpgradeTableViewCell : UITableViewCell
@property (weak, nonatomic) id<UpgradeTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeTypeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unlimitedUpgradesHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *xpRequiredLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ringImageView;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UIView *typeAndCostContainerView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (assign, nonatomic) UpgradeTableViewCellType cellType;
- (IBAction)descriptionButtonTapped:(id)sender;
- (IBAction)upgradeButtonTapped:(id)sender;

@end
