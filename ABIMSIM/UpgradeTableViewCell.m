//
//  UpgradeTableViewCell.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 4/4/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "UpgradeTableViewCell.h"
#import "UIView+Fancy.h"

@implementation UpgradeTableViewCell {
    NSTimer *hideDescriptionTimer;
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)descriptionButtonTapped:(id)sender {
    if (self.product) {
        return;
    }
    if (hideDescriptionTimer) {
        [hideDescriptionTimer invalidate];
        hideDescriptionTimer = nil;
        [self hideDescription];
    } else {
        hideDescriptionTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDescription) userInfo:nil repeats:NO];
        [self showDescription];
    }
}

-(void)showDescription {
    [UIView animateWithDuration:0.15 animations:^{
        self.typeAndCostContainerView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.descriptionLabel.alpha = 1;
        }];
    }];
}

-(void)hideDescription {
    [UIView animateWithDuration:0.15 animations:^{
        self.descriptionLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.typeAndCostContainerView.alpha = 1;
        }];
    }];
}

- (IBAction)upgradeButtonTapped:(id)sender {
    [self.delegate upgradeCellTapped:self];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.upgradeRing0.center = self.upgradeRing1.center = self.upgradeRing2.center = self.upgradeRing3.center = self.upgradeButton.center;
}

#pragma mark - IAP Version

-(void)setupAsIAP {
    if (self.upgradeRing0) {
        return;
    }
    float scale = 0.8;
    self.upgradeRing0 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Upgrades_0"]];
    self.upgradeRing1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Upgrades_1"]];
    self.upgradeRing2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Upgrades_2"]];
    self.upgradeRing3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Upgrades_3"]];

    self.upgradeRing0.frame = CGRectMake(0, 0, self.upgradeRing0.frame.size.width * scale, self.upgradeRing0.frame.size.height * scale);
    self.upgradeRing1.frame = CGRectMake(0, 0, self.upgradeRing1.frame.size.width * scale, self.upgradeRing1.frame.size.height * scale);
    self.upgradeRing2.frame = CGRectMake(0, 0, self.upgradeRing2.frame.size.width * scale, self.upgradeRing2.frame.size.height * scale);
    self.upgradeRing3.frame = CGRectMake(0, 0, self.upgradeRing3.frame.size.width * scale, self.upgradeRing3.frame.size.height * scale);

    self.upgradeRing0.center = self.upgradeRing1.center = self.upgradeRing2.center = self.upgradeRing3.center = self.upgradeButton.center;
    [self.contentView addSubview:self.upgradeRing0];
    [self.contentView addSubview:self.upgradeRing1];
    [self.contentView addSubview:self.upgradeRing2];
    [self.contentView addSubview:self.upgradeRing3];
    
    [self.upgradeButton setImage:[UIImage imageNamed:@"BuyText_0"] forState:UIControlStateNormal];
    [self.upgradeButton setImage:[UIImage imageNamed:@"BuyText_1"] forState:UIControlStateHighlighted];
    [self.upgradeButton setImage:[UIImage imageNamed:@"BuyText_1"] forState:UIControlStateSelected];
    
    [self.upgradeButton removeTarget:self action:@selector(upgradeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.upgradeButton addTarget:self action:@selector(upgradesSelect:) forControlEvents:UIControlEventTouchDown];
    [self.upgradeButton addTarget:self action:@selector(upgradesSelect:) forControlEvents:UIControlEventTouchDragEnter];
    [self.upgradeButton addTarget:self action:@selector(upgradesDeselect:) forControlEvents:UIControlEventTouchDragExit];
    [self.upgradeButton addTarget:self action:@selector(upgradesTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

    self.upgradeTypeLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:25];
}

-(void)animateUpgradesButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithRing1:self.upgradeRing0 ring2:self.upgradeRing1 ring3:self.upgradeRing2 ring4:self.upgradeRing3 andCompletion:completionBlock];
}

-(void)animateUpgradesButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithRing1:self.upgradeRing0 ring2:self.upgradeRing1 ring3:self.upgradeRing2 ring4:self.upgradeRing3 andCompletion:completionBlock];
}

- (IBAction)upgradesSelect:(id)sender {
    [self animateUpgradesButtonSelect:nil];
}

- (IBAction)upgradesDeselect:(id)sender {
    [self animateUpgradesButtonDeselect:nil];
}

- (IBAction)upgradesTouchUpInside:(id)sender {
    [self.delegate upgradeCellTapped:self];

    [self animateUpgradesButtonDeselect:^{
    }];
}

@end
