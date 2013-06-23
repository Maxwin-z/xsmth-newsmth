//
//  SMAccountManager.m
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMAccountManager.h"

#define COOKIE_USERID   @"main[UTMPUSERID]"

static SMAccountManager *_instance;

@interface SMAccountManager ()
@property (strong, nonatomic) NSMutableDictionary *cookieMap;   // name -> index
@end

@implementation SMAccountManager
+ (SMAccountManager *)instance
{
    if (_instance == nil) {
        _instance = [[SMAccountManager alloc] init];
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadCookie];
    }
    return self;
}

- (void)loadCookie
{
    NSURL *url = [NSURL URLWithString:@"http://m.newsmth.net"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    if (cookies) {
        [self setCookies:cookies];
    }

}

- (void)setCookies:(NSArray *)cookies
{
    NSString *name = nil;
    for (int i = 0; i != cookies.count; ++i) {
        NSHTTPCookie *cookie = cookies[i];
        if ([cookie.name isEqualToString:COOKIE_USERID]) {
            name = cookie.value;
//          XLog_d(@"get user: %@", name);
            if ([name isEqualToString:@"guest"]) {    // login status
                name = nil;
            }
            
            // notify account changed.
            if ((name != nil || _name != nil) && ![name isEqualToString:_name]) {
                _name = name;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCOUT object:nil];
            }
        }
    }
}

- (BOOL)isLogin
{
    return _name != nil;
}

@end
