//
//  SMAccountManager.m
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMAccountManager.h"

#define COOKIE_USERID   @"main[UTMPUSERID]"
#define USER_DEF_COOKIE @"cookie"

static SMAccountManager *_instance;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)setCookies:(NSArray *)cookies
{
//    XLog_d(@"%@, %@", self, cookies);
    _cookies = cookies;
    
    // clear login info
    __block NSString *name = nil;
    [_cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSHTTPCookie *cookie = obj;
        if ([cookie.name isEqualToString:COOKIE_USERID]) {
            name = cookie.value;
//            XLog_d(@"get user: %@", name);
            if ([name isEqualToString:@"guest"]) {    // login status
                name = nil;
            }
        }
    }];
    
    // notify account changed.
    if ((name != nil || _name != nil) && ![name isEqualToString:_name]) {
        _name = name;
        [self saveCookie];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCOUT object:nil];
    }
}

- (BOOL)isLogin
{
    return _name != nil;
}

- (void)onAppDidEnterBackground
{
    [self saveCookie];
}

- (void)saveCookie
{
    NSData *cookiedata = [NSKeyedArchiver archivedDataWithRootObject:_cookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookiedata forKey:USER_DEF_COOKIE];
}

- (void)loadCookie
{
    NSData *cookiedata = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEF_COOKIE];
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiedata];
    self.cookies = cookies;
}

@end
