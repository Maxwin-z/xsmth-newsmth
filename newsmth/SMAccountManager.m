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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        _cookieMap = [[NSMutableDictionary alloc] init];
        _cookies = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setCookies:(NSArray *)cookies
{
    NSString *name = nil;
    for (int i = 0; i != cookies.count; ++i) {
        NSHTTPCookie *cookie = cookies[i];
        NSNumber *index = [_cookieMap objectForKey:cookie.name];
        if (index == nil) { // new
            [_cookies addObject:cookie];
            [_cookieMap setObject:@(i) forKey:cookie.name];
        } else {    // update
            [_cookies replaceObjectAtIndex:[index intValue] withObject:cookie];
        }
        if ([cookie.name isEqualToString:COOKIE_USERID]) {
            name = cookie.value;
//          XLog_d(@"get user: %@", name);
            if ([name isEqualToString:@"guest"]) {    // login status
                name = nil;
            }
            
            // notify account changed.
            if ((name != nil || _name != nil) && ![name isEqualToString:_name]) {
                _name = name;
                [self saveCookie];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCOUT object:nil];
            }
        }
    }
    
}

- (NSArray *)cookies
{
    return _cookies;
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
