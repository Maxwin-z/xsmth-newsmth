//
//  AppDelegate.m
//  newsmth
//
//  Created by Maxwin on 13-5-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "GAI.h"
#import "AppDelegate.h"
#import "SMAccountManager.h"

#import "ViewController.h"
#import "SMMainViewController.h"
#import "SMMainpageViewController.h"
#import "SMUtils.h"
#import "SMUpdater.h"

@interface AppDelegate ()<SMWebLoaderOperationDelegate>
@property (strong, nonatomic) UINavigationController *nvc;
@property (strong, nonatomic) SMMainpageViewController *mainpageViewController;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) SMMainViewController *mainViewController;

@property (strong, nonatomic) SMWebLoaderOperation *keepLoginOp;
@property (strong, nonatomic) SMWebLoaderOperation *loginOp;

@property (strong, nonatomic) void (^completionHandler)(UIBackgroundFetchResult);

@property (strong, nonatomic) SMUpdater *updater;
@end

@implementation AppDelegate

- (void)showNotification:(NSString *)notice
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *oldNotifications = [app scheduledLocalNotifications];
    
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    
    // Create a new notification.
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (alarm)
    {
        alarm.fireDate = [NSDate date];
        //        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        alarm.soundName = UILocalNotificationDefaultSoundName;
        alarm.alertBody = notice;
        
        [app scheduleLocalNotification:alarm];
    }
}


- (void)setupGoogleAnalytics
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-41978299-1"];
}

- (void)setupTheme
{
    if ([self.window respondsToSelector:@selector(setTintColor:)]) {
        self.window.tintColor = [SMTheme colorForTintColor];
    }
    [[UIBarButtonItem appearance] setTintColor:[SMTheme colorForTintColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{
       UITextAttributeTextColor: [SMTheme colorForPrimary],
       UITextAttributeTextShadowColor: [UIColor clearColor]
       }];

    if ([SMUtils systemVersion] < 7) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"bg_navigationbar"] stretchableImageWithLeftCapWidth:1 topCapHeight:1] forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"bg_barbuttonitem"] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
    } else {
        [[UINavigationBar appearance] setBarTintColor:[SMTheme colorForBarTintColor]];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [self setupTheme];

    _mainViewController = [[SMMainViewController alloc] init];
    self.window.rootViewController = _mainViewController;
    
    [self.window makeKeyAndVisible];
    
    [self setupGoogleAnalytics];
    
    NSString *latestVersion = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_STAT_VERSION];
    if (![[SMUtils appVersionString] isEqualToString:latestVersion]) {
        [SMUtils trackEventWithCategory:@"user" action:@"unique" label:[SMUtils appVersionString]];
        [[NSUserDefaults standardUserDefaults] setObject:[SMUtils appVersionString] forKey:USERDEFAULTS_STAT_VERSION];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    _updater = [[SMUpdater alloc] init];
    [_updater checkAndUpdate];
    
    XLog_d(@"%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));

    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
//    [self showNotification:@"start bg fetch"];
    if ([SMAccountManager instance].isLogin) {
        XLog_d(@"load notice");
        [_keepLoginOp cancel];
        _keepLoginOp = [[SMWebLoaderOperation alloc] init];
        _keepLoginOp.delegate = self;
        _completionHandler = completionHandler;
        [_keepLoginOp loadUrl:@"http://m.newsmth.net/user/query/" withParser:@"notice,util_notice"];
    } else {
        NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_USERNAME];
        NSString *passwd =  [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_PASSWORD];
        if (user && passwd) {
            SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:@"http://m.newsmth.net/user/login"]];
            NSString *postBody = [NSString stringWithFormat:@"id=%@&passwd=%@&save=on", user, passwd];
            [request setRequestMethod:@"POST"];
            [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
            [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
            
            [_loginOp cancel];
            _loginOp = [[SMWebLoaderOperation alloc] init];
            _loginOp.delegate = self;
            _completionHandler = completionHandler;
            [_loginOp loadRequest:request withParser:@"notice,util_notice"];
        } else {
//            [self showNotification:@"no account, stop bg fetch"];
            [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }

//    NSURL *url = [NSURL URLWithString:@"http://m.newsmth.net/user/query/"];
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        XLog_d(@"%@", content);
//        [self showNotification:@"got it"];
//        completionHandler(UIBackgroundFetchResultNewData);
//    }];
//    [task resume];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    XLog_d(@"");
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    XLog_d(@"%@", opt.data);
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    SMNotice *oldNotice = [[SMNotice alloc] initWithJSON:[def objectForKey:USERDEFAULTS_NOTICE]];
    SMNotice *lastFetchNotice = [[SMNotice alloc] initWithJSON:[def objectForKey:USERDEFAULTS_NOTICE_FETCH]];
    
    SMNotice *newNotice = opt.data;
    NSMutableArray *res = [[NSMutableArray alloc] init];
    int badge = 0;
    if (newNotice.mail > oldNotice.mail) {
        [res addObject:@"邮件"];
        badge += newNotice.mail - oldNotice.mail;
    }
    if (newNotice.reply > oldNotice.reply) {
        [res addObject:[NSString stringWithFormat:@"%d条回复", newNotice.reply - oldNotice.reply]];
        badge += newNotice.reply - oldNotice.reply;
    }
    if (newNotice.at > oldNotice.at) {
        [res addObject:[NSString stringWithFormat:@"%d条@", newNotice.at - oldNotice.at]];
        badge += newNotice.at - oldNotice.at;
    }
    if (res.count > 0) {
        NSString *message = [NSString stringWithFormat:@"%@ 新的消息：%@", opt == _loginOp ? @"登录" : @"", [res componentsJoinedByString:@", "]];
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        [self showNotification:message];
    }
    
    if (newNotice.mail > lastFetchNotice.mail || newNotice.at > lastFetchNotice.at || newNotice.reply > lastFetchNotice.reply) {
        [SMConfig resetFetchTime];
//        [self showNotification:@"notice change, reset fetch time"];
    }

    [self scheduleNextBackgroundFetch];
    // save new fetched notice
    [def setObject:[newNotice encode] forKey:USERDEFAULTS_NOTICE_FETCH];

    _completionHandler(UIBackgroundFetchResultNewData);
    _completionHandler = nil;
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    XLog_d(@"%@", error);
//    [self showNotification:[NSString stringWithFormat:@"%@", error]];
    _completionHandler(UIBackgroundFetchResultFailed);
    _completionHandler = nil;
    [self scheduleNextBackgroundFetch];
}

- (void)scheduleNextBackgroundFetch
{
    NSInteger mins = [SMConfig nextFetchTime];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:mins * 60];
//    NSString *msg = [NSString stringWithFormat:@"fetch after %dmin", mins];
//    [self showNotification:msg];
}

@end
