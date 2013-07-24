//
//  SMBaseData.m
//  newsmth
//
//  Created by Maxwin on 13-6-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBaseData.h"

@implementation SMBaseData

+ (SMBaseData *)dataWithJSON:(id)json
{
    Class clz = [SMBaseData class];
    NSString *clzName = [json objectForKey:@"__type"];
    if (clzName != nil) {
        clz = NSClassFromString(clzName);
    }
    return [[clz alloc] initWithJSON:json];
}

+ (SMBaseData *)dataWithJSON:(id)json type:(NSString *)className
{
    Class clz = [SMBaseData class];
    if (className != nil) {
        clz = NSClassFromString(className);
    }
    return [[clz alloc] initWithJSON:json];
}

- (id)initWithJSON:(id)json
{
    self = [super init];
    if (self) {
        [self decode:json];
    }
    return self;
}

- (void)decode:(id)json
{
    
}

- (id)encode
{
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self encode]];
}

@end
