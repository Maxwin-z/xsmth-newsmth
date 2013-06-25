//
//  SMBaseData.m
//  newsmth
//
//  Created by Maxwin on 13-6-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBaseData.h"

@implementation SMBaseData
- (id)init
{
    self = [super init];
    if (self) {
        self.dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithData:(NSDictionary *)dict
{
    NSString *clzName = nil;
    if ([dict isKindOfClass:[NSDictionary class]]) {
        clzName = [dict objectForKey:@"__type"];
    }
    Class clz = clzName != nil ? NSClassFromString(clzName) : nil;
    if (clz) {
        self = [[clz alloc] init];
    } else {
        self = [super init];
    }
    self.dict = dict;
    return self;
}
@end
