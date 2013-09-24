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

- (void)setNotice:(SMNotice *)notice
{
    if (_notice != notice) {
        _notice = notice;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NOTICE object:nil];
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

            BOOL isExpired = cookie.expiresDate != nil && cookie.expiresDate.timeIntervalSince1970 < [[NSDate alloc] init].timeIntervalSince1970;

            if ([name isEqualToString:@"guest"] || isExpired) {    // login status
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
