//
//  SMContent.h
//  SessionM
//
//  Copyright (c) 2016 SessionM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMContent : NSObject

@property(nonatomic, strong, readonly) NSString *contentID;
@property(nonatomic, strong, readonly) NSString *externalID;
@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, strong, readonly) NSString *type;
@property(nonatomic, strong, readonly) NSString *state;
@property(nonatomic, strong, readonly) NSString *descriptionText;
@property(nonatomic, strong, readonly) NSString *imageURL;
@property(nonatomic, strong, readonly) NSString *createdTime;
@property(nonatomic, strong, readonly) NSString *updatedTime;
@property(nonatomic, strong, readonly) NSString *expireTime;
@property(nonatomic, strong, readonly) NSDictionary *metadata;
@property(nonatomic, readonly) int weight;

@end
