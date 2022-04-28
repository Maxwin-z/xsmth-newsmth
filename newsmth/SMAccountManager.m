//
//  SMAccountManager.m
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMAccountManager.h"
#import "SMWebLoaderOperation.h"
#import <WebKit/WebKit.h>
#import <MMKV/MMKV.h>

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
    NSURL *url = [NSURL URLWithString:URL_PROTOCOL @"//m.mysmth.net"];
    NSMutableArray *cookies =[[NSMutableArray alloc] initWithArray:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]];
//    XLog_d(@"load cookies: %@", cookies);
    
    NSArray *savedCookies = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_COOKIES];
//    XLog_d(@"saved cookies: %@", savedCookies);
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
//        XLog_d(@"debug cookie: %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]);
    }
    
    if (cookies) {
        [self setCookies:cookies];
    }

}

- (void)refreshStatus
{
    NSURL *url = [NSURL URLWithString:URL_PROTOCOL @"//m.mysmth.net"];
    NSArray *cookies =[[NSMutableArray alloc] initWithArray:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url]];
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
//            XLog_d(@"cookie: %@", cookie);
            name = cookie.value;

            BOOL isExpired = cookie.expiresDate != nil && cookie.expiresDate.timeIntervalSince1970 < [[NSDate alloc] init].timeIntervalSince1970;

            if ([name isEqualToString:@"guest"] || isExpired) {    // login status
                name = nil;
                self.notice = nil;
                NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeCookies]];
                NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
                [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
                }];
                [self autoLogin];
            }
            
            // notify account changed.
            XLog_d(@"account: %@ -> %@", _name, name);
            if ([_name isEqualToString:@"Maxwin"] && name == nil) {
                NSLog(@"logout");
            }
            if ((name != nil || _name != nil) && ![name isEqualToString:_name]) {
                _name = name;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCOUT object:nil];
                });
            }
        }
    }
}

- (BOOL)isLogin
{
    return _name != nil;
}

- (void)autoLogin
{
    return;
    if ([NSDate timeIntervalSinceReferenceDate] - self.lastAutoLoginTime < 10) {    // 每10s内重试一次
        XLog_d(@"autologin 重试时间较短，稍后重试");
        return ;
    }
    NSString *user = nil;
    NSString *passwd = nil;
    NSString *data = [[MMKV defaultMMKV] getStringForKey:@"_xsmth_userinfo"];
    if (data != nil) {
        NSDictionary *json = [SMUtils string2json:data];
        if (json != nil) {
            NSDictionary *value = json[@"value"];
            if (value != nil) {
                user = value[@"id"];
                passwd = value[@"passwd"];
            }
        }
    }
//    BOOL autoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_AUTOLOGIN];
    if (user && passwd) {
        self.lastAutoLoginTime = [NSDate timeIntervalSinceReferenceDate];
        XLog_d(@"try autologin");
        SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:URL_PROTOCOL @"//m.mysmth.net/user/login"]];
        NSString *postBody = [NSString stringWithFormat:@"id=%@&passwd=%@&save=on", user, passwd];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
        [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
        
        SMWebLoaderOperation *op = [[SMWebLoaderOperation alloc] init];
        [op loadRequest:request withParser:@"notice,util_notice"];
    }
}

@end
