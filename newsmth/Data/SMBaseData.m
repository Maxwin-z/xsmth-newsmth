//
//  SMBaseData.m
//  newsmth
//
//  Created by Maxwin on 13-6-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBaseData.h"

@implementation SMBaseData
- (id)initWithData:(NSDictionary *)dict
{
    NSString *clzName = [dict objectForKey:@"__type"];
    Class clz = NSClassFromString(clzName);
    if (clz) {
        self = [[clz alloc] init];
        self.dict = dict;
    }
    return self;
}
@end
