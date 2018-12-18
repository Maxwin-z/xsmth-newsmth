//
//  SMAccountManager.m
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMAccountManager.h"
#import "SMWebLoaderOperation.h"

#define COOKIE_USERID   @"main[UTMPUSERID]"

static SMAccountManager *_instance;

@interface SMAccountManager ()
@property (strong, nonatomic) NSMutableDictionary *cookieMap;   // name -> index
@property (assign, nonatomic) NSTimeInterval lastAutoLoginTime;
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
        self.lastAutoLoginTime = 0;
    }
    return self;
}

- (void)setNotice:(SMNotice *)notice
{
    if (_notice != notice) {
        _notice = notice;
        [[NSUserDefaults standardUserDefaults] setObject:[_notice encode] forKey:USERDEFAULTS_NOTICE];
        [[NSUserDefaults standardUserDefaults] setObject:[_notice encode] forKey:USERDEFAULTS_NOTICE_FETCH];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NOTICE object:nil];
    });
}

- (void)loadCookie
{
    NSURL *url = [NSURL URLWithString:URL_PROTOCOL @"//m.newsmth.net"];
    NSMutableArray *cookies =[[NSMutableArray alloc] initWithArray:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]];
    XLog_d(@"load cookies: %@", cookies);
    
    NSArray *savedCookies = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_COOKIES];
    XLog_d(@"saved cookies: %@", savedCookies);
    if (savedCookies) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        [savedCookies enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *cookieProps = [[NSMutableDictionary alloc] initWithDictionary:item];
            if (item[NSHTTPCookieExpires]) {
                cookieProps[NSHTTPCookieExpires] = [formatter dateFromString:item[NSHTTPCookieExpires]];
            }
            NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProps];
            [cookies addObject:cookie];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }];
        XLog_d(@"debug cookie: %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]);
    }
    
    if (cookies) {
        [self setCookies:cookies];
    }

}

- (void)setCookies:(NSArray *)cookies
{
    NSString *name = nil;
    XLog_d(@"cookies: %@", cookies);
//    NSMutableDictionary *savedCookies = [NSMutableDictionary new];
    NSMutableArray *savedCookies = [NSMutableArray new];
    int loginStatus = 0;    // 1 login; 2 logout
    for (int i = 0; i != cookies.count; ++i) {
        NSHTTPCookie *cookie = cookies[i];
        
        if ([@[@"main[UTMPKEY]", @"main[UTMPNUM]", COOKIE_USERID] containsObject:cookie.name]) {
//            [savedCookies setObject:(cookie.value ?: @"") forKey:cookie.name];
            NSDateFormatter *formatter = [NSDateFormatter new];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSMutableDictionary *obj = [[NSMutableDictionary alloc] initWithDictionary:@{
                                      NSHTTPCookieValue:cookie.value ?: @"",
                                      NSHTTPCookieName: cookie.name,
                                      NSHTTPCookieDomain: cookie.domain,
                                      NSHTTPCookiePath: cookie.path,
                                      NSHTTPCookieVersion: @(cookie.version),
                                      NSHTTPCookieSecure: @(cookie.secure)
                                      }];
            if (cookie.expiresDate) {
                [obj setObject:[formatter stringFromDate:cookie.expiresDate] forKey:NSHTTPCookieExpires];
            }
            [savedCookies addObject:obj];
        }
        
        if ([cookie.name isEqualToString:COOKIE_USERID]) {
            name = cookie.value;

            BOOL isExpired = cookie.expiresDate != nil && cookie.expiresDate.timeIntervalSince1970 < [[NSDate alloc] init].timeIntervalSince1970;

            if ([name isEqualToString:@"guest"] || isExpired) {    // login status
                if (loginStatus == 0) { // guest & uid 会同时出现在cookie里，判断是否已经有uid
                    name = nil;
                    self.notice = nil;
                    loginStatus = 2;
                }
            } else {
                loginStatus = 1;
            }
            
            // notify account changed.
            XLog_d(@"account: %@ -> %@", _name, name);
            if ((name != nil || _name != nil) && ![name isEqualToString:_name]) {
                _name = name;
                
                if ([SMConfig enableBackgroundFetch]) {
                    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
                    XLog_v(@"enable bg fetch: %@", _name);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCOUT object:nil];
                });
            }
        }
    }
    
    if (loginStatus == 1) {
        XLog_d(@"savedCookies: %@", savedCookies);
        [[NSUserDefaults standardUserDefaults] setObject:savedCookies forKey:USERDEFAULTS_COOKIES];
    }
    if (loginStatus == 2) {
        XLog_d(@"clear savedCookies: %@", savedCookies);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] removeCookiesSinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_COOKIES];
        [self autoLogin];   // 尝试自动登录
    }
    
    // 2018.11.17; fix newsmth.net cookie expired time
//    if (savedCookies[COOKIE_USERID] && [savedCookies[COOKIE_USERID] isEqualToString:@"guest"]) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_COOKIES];
//    } else if([savedCookies count] == 3) {
//        [[NSUserDefaults standardUserDefaults] setObject:savedCookies forKey:USERDEFAULTS_COOKIES];
//    }
//    XLog_d(@"savedCookies: %@", savedCookies);
//
//    if (loginStatus == 1 && savedCookies.count == 3) {
//        [[NSUserDefaults standardUserDefaults] setObject:savedCookies forKey:USERDEFAULTS_COOKIES];
//    } else if (loginStatus == 2) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_COOKIES];
//    }
}

- (BOOL)isLogin
{
    return _name != nil;
}

- (void)autoLogin
{
    if ([NSDate timeIntervalSinceReferenceDate] - self.lastAutoLoginTime < 10) {    // 每10s内重试一次
        XLog_d(@"autologin 重试时间较短，稍后重试");
        return ;
    }
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_USERNAME];
    NSString *passwd =  [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_PASSWORD];
    BOOL autoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_AUTOLOGIN];
    if (autoLogin && user && passwd) {
        self.lastAutoLoginTime = [NSDate timeIntervalSinceReferenceDate];
        XLog_d(@"try autologin");
        SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:URL_PROTOCOL @"//m.newsmth.net/user/login"]];
        NSString *postBody = [NSString stringWithFormat:@"id=%@&passwd=%@&save=on", user, passwd];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
        [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
        
        SMWebLoaderOperation *op = [[SMWebLoaderOperation alloc] init];
        [op loadRequest:request withParser:@"notice,util_notice"];
    }
}

@end
