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
    NSArray *sortedProducts;
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
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointZero animated:YES];
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
    NSSortDescriptor *lowestPriceToHighest = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES];
    sortedProducts = [[[MKStoreKit sharedKit] availableProducts] sortedArrayUsingDescriptors:[NSArray arrayWithObject:lowestPriceToHighest]];

    return sortedProducts.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 152;
    }
    return 120;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 152;
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
    SKProduct *product = [sortedProducts objectAtIndex:indexPath.row];
    cell.product = product;
    cell.upgradeTypeLabel.text = product.localizedTitle;
    cell.unlimitedUpgradesHeightConstraint.constant = 0;
    
    [_priceFormatter setLocale:product.priceLocale];
    cell.xpRequiredLabel.text = [_priceFormatter stringFromNumber:product.price];
    
    cell.ringImageView.image = nil;
    cell.descriptionLabel.text = @"NO ONE WILL EVER SEE THIS MWUHAHAHAHAHHA!!!";
    cell.upgradeButton.alpha = 1;
    cell.upgradeButton.enabled = YES;
    [cell setupAsIAP];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    cell.upgradeRing0.center = cell.upgradeRing1.center = cell.upgradeRing2.center = cell.upgradeRing3.center = cell.upgradeButton.center;
}

-(void)upgradeCellTapped:(UpgradeTableViewCell*)cell {
    [self showLoader];
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:cell.product.productIdentifier];
}


@end
