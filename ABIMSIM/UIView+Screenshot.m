//
//  UIView+Screenshot.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/23/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

- (UIImage *)imageFromScreenShot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        if (self.bounds.size.height != 0 && self.bounds.size.width != 0) {
            [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
        } else {
            NSLog(@"BOUNDS ARE ZERO %@", self);
        }
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
