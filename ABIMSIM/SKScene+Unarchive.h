//
//  SKScene+Unarchive.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/23/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKScene (Unarchive)
+ (instancetype)unarchiveFromFile:(NSString *)file;
@end
