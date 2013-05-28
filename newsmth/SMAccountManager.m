//
//  SMAccountManager.m
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMAccountManager.h"

#define COOKIE_USERID   @"main[UTMPUSERID]"

@implementation SMAccountManager
+ (SMAccountManager *)sharedInstance
{
    static SMAccountManager *instance;
    if (instance == nil) {
        instance = [[SMAccountManager alloc] init];
    }
    return instance;
}

- (void)setCookies:(NSArray *)cookies
{
    _cookies = cookies;
    
    // clear login info
    _name = nil;
    [_cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSHTTPCookie *cookie = obj;
        if ([cookie.name isEqualToString:COOKIE_USERID]) {
            _name = cookie.value;
            if ([_name isEqualToString:@"guest"]) {    // login status
                _name = nil;
            }
        }
    }];
}

- (BOOL)isLogin
{
    return _name != nil;
}

@end
