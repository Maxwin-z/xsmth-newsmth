//
//  SMMessage.m
//  newsmth
//
//  Created by Maxwin on 13-5-30.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMessage.h"

@implementation SMMessage
- (id)initWithCode:(NSInteger)code message:(NSString *)message
{
    self = [super init];
    if (self) {
        _code = code;
        _message = message;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"code[%@], message[%@]", @(_code), _message];
}

@end
