//
//  SKNode+Removed.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 5/4/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//
#import <objc/runtime.h>
#import "SKNode+Removed.h"

static void * RemovePropertyKey = &RemovePropertyKey;

@implementation SKNode (Removed)

- (NSNumber*)remove {
    return objc_getAssociatedObject(self, RemovePropertyKey);
}

- (void)setRemove:(NSNumber*)remove {
    objc_setAssociatedObject(self, RemovePropertyKey, remove, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
