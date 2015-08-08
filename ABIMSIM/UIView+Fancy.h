//
//  UIButton+Fancy.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/23/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Fancy)
-(void)animateFancySelectWithButton:(UIButton*)button ring1:(UIImageView*)ring1 ring2:(UIImageView*)ring2 ring3:(UIImageView*)ring3 ring4:(UIImageView*)ring4 andCompletion:(void(^)(void))completionBlock;
-(void)animateFancyDeselectWithButton:(UIButton*)button ring1:(UIImageView*)ring1 ring2:(UIImageView*)ring2 ring3:(UIImageView*)ring3 ring4:(UIImageView*)ring4 andCompletion:(void(^)(void))completionBlock;
@end
