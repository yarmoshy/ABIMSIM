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
    [super awakeFromNib];
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.lineHeightMultiple= 1;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.maximumLineHeight = 20;
    self.upgradeButton.titleLabel.numberOfLines = 0;
    [self.upgradeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"POWER UP" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:20],
                                                                                                                     NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                                     NSParagraphStyleAttributeName: paragraphStyle}] forState:UIControlStateNormal];
    [self.upgradeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"POWER UP" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:20],
                                                                                                              NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.5],
                                                                                                              NSParagraphStyleAttributeName: paragraphStyle}] forState:UIControlStateDisabled];

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

- (IBAction)upgradeSelect:(UIButton *)sender {
    sender.layer.shadowColor = [UIColor whiteColor].CGColor;
    sender.layer.shadowRadius = 2.0f;
    sender.layer.shadowOpacity = 1.0f;
    sender.layer.shadowOffset = CGSizeMake(0, 0);
}

- (IBAction)upgradeDeslect:(UIButton *)sender {
    sender.layer.shadowColor = [UIColor clearColor].CGColor;
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
    self.upgradeRing0 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IAP_0"]];
    self.upgradeRing1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IAP_1"]];
    self.upgradeRing2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IAP_2"]];
    self.upgradeRing3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IAP_3"]];

    self.upgradeRing0.frame = CGRectMake(0, 0, self.upgradeRing0.frame.size.width * scale, self.upgradeRing0.frame.size.height * scale);
    self.upgradeRing1.frame = CGRectMake(0, 0, self.upgradeRing1.frame.size.width * scale, self.upgradeRing1.frame.size.height * scale);
    self.upgradeRing2.frame = CGRectMake(0, 0, self.upgradeRing2.frame.size.width * scale, self.upgradeRing2.frame.size.height * scale);
    self.upgradeRing3.frame = CGRectMake(0, 0, self.upgradeRing3.frame.size.width * scale, self.upgradeRing3.frame.size.height * scale);

    self.upgradeRing0.center = self.upgradeRing1.center = self.upgradeRing2.center = self.upgradeRing3.center = self.upgradeButton.center;
    [self.contentView addSubview:self.upgradeRing0];
    [self.contentView addSubview:self.upgradeRing1];
    [self.contentView addSubview:self.upgradeRing2];
    [self.contentView addSubview:self.upgradeRing3];
    
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.lineHeightMultiple= 1;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.maximumLineHeight = 25;
    self.upgradeButton.titleLabel.numberOfLines = 0;
    [self.upgradeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"BUY!" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:25],
                                                                                                              NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                              NSParagraphStyleAttributeName: paragraphStyle}] forState:UIControlStateNormal];
    [self.upgradeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"BUY!" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:25],
                                                                                                              NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.5],
                                                                                                              NSParagraphStyleAttributeName: paragraphStyle}] forState:UIControlStateDisabled];

    
    [self.upgradeButton removeTarget:self action:@selector(upgradeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.upgradeButton removeTarget:self action:@selector(upgradeSelect:) forControlEvents:UIControlEventTouchDown];
    [self.upgradeButton removeTarget:self action:@selector(upgradeSelect:) forControlEvents:UIControlEventTouchDragEnter];
    [self.upgradeButton removeTarget:self action:@selector(upgradeDeslect:) forControlEvents:UIControlEventTouchDragExit];
    [self.upgradeButton removeTarget:self action:@selector(upgradeDeslect:) forControlEvents:UIControlEventTouchUpInside];

    [self.upgradeButton addTarget:self action:@selector(upgradesSelect:) forControlEvents:UIControlEventTouchDown];
    [self.upgradeButton addTarget:self action:@selector(upgradesSelect:) forControlEvents:UIControlEventTouchDragEnter];
    [self.upgradeButton addTarget:self action:@selector(upgradesDeselect:) forControlEvents:UIControlEventTouchDragExit];
    [self.upgradeButton addTarget:self action:@selector(upgradesTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

    self.upgradeTypeLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:25];
}

-(void)animateUpgradesButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithButton:self.upgradeButton ring1:self.upgradeRing0 ring2:self.upgradeRing1 ring3:self.upgradeRing2 ring4:self.upgradeRing3 andCompletion:completionBlock];
}

-(void)animateUpgradesButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithButton:self.upgradeButton ring1:self.upgradeRing0 ring2:self.upgradeRing1 ring3:self.upgradeRing2 ring4:self.upgradeRing3 andCompletion:completionBlock];
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
