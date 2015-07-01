//
//  IAPView.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 6/8/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "IAPView.h"
#import "MKStoreKit.h"

@implementation IAPView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IAPPurchaseComplete) name:kStoreKitPurchaseFinished object:nil];
        
    }
    return self;
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
    self.alpha = 0;
}

- (IBAction)xp750Tapped:(id)sender {
    [self showLoader];
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"750XP"];
}

- (IBAction)xp1500Tapped:(id)sender {
    [self showLoader];
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"1500XP"];
}

- (IBAction)xp4000Tapped:(id)sender {
    [self showLoader];
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"4000XP"];
}

- (IBAction)xp10000Tapped:(id)sender {
    [self showLoader];
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"10000XP"];
}

- (IBAction)xp25000Tapped:(id)sender {
    [self showLoader];
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"25000XP"];
}


@end
