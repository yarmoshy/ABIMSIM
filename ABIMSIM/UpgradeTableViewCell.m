//
//  UpgradeTableViewCell.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 4/4/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "UpgradeTableViewCell.h"

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

@end
