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
    NSDictionary *dict = [self encode];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = nil;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


@end
