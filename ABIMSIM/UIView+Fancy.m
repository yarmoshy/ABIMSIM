//
//  UIButton+Fancy.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/23/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "UIView+Fancy.h"

@implementation UIView (Fancy)

-(void)animateFancySelectWithRing1:(UIImageView*)ring1 ring2:(UIImageView*)ring2 ring3:(UIImageView*)ring3 ring4:(UIImageView*)ring4 andCompletion:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [ring4 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [ring3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [ring2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [ring1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateFancyDeselectWithRing1:(UIImageView*)ring1 ring2:(UIImageView*)ring2 ring3:(UIImageView*)ring3 ring4:(UIImageView*)ring4 andCompletion:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [ring1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [ring1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [ring2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [ring2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [ring3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [ring3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [ring4 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [ring4 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

@end
