//
//  SMDBManager.h
//  newsmth
//
//  Created by Maxwin on 14-3-8.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMDBManager : NSObject
+ (instancetype)instance;

- (void)insertPost:(SMPost *)post;
- (void)queryPost:(int)pid completed:(void (^)(SMPost *))completed;

@end
