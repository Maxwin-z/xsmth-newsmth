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
#import "SMIPadSplitViewController.h"
#import "SMIpadEmptyViewController.h"
#import "SMAdViewController.h"
#import "SMNoticeViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "SMBoardViewController.h"
#import "SMZanShangUtil.h"
#import "newsmth-Swift.h"

@interface AppDelegate ()<SMWebLoaderOperationDelegate>
@property (strong, nonatomic) UINavigationController *nvc;
@property (strong, nonatomic) SMMainpageViewController *mainpageViewController;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) SMMainViewController *mainViewController;
@property (strong, nonatomic) SMIPadSplitViewController *ipadSplitViewController;
@property (strong, nonatomic) SMAdViewController *adViewController;

@property (strong, nonatomic) SMWebLoaderOperation *keepLoginOp;
@property (strong, nonatomic) SMWebLoaderOperation *loginOp;

@property (strong, nonatomic) void (^completionHandler)(UIBackgroundFetchResult);

@property (strong, nonatomic) SMUpdater *updater;

@property (assign, nonatomic) BOOL isNewLaunching;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) UIApplicationShortcutItem *launchedShortcutItem;
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
//    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-41978299-1"];
}

//- (void)setupTheme
//{
//    if ([self.window respondsToSelector:@selector(setTintColor:)]) {
//        self.window.tintColor = [SMTheme colorForTintColor];
//    }
//    [[UIBarButtonItem appearance] setTintColor:[SMTheme colorForTintColor]];
//    [[UINavigationBar appearance] setTitleTextAttributes:
//     @{
//       UITextAttributeTextColor: [SMTheme colorForPrimary],
//       UITextAttributeTextShadowColor: [UIColor clearColor]
//       }];
//
//    if ([SMUtils systemVersion] < 7) {
//        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"bg_navigationbar"] stretchableImageWithLeftCapWidth:1 topCapHeight:1] forBarMetrics:UIBarMetricsDefault];
////        [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"bg_barbuttonitem"] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//        
//    } else {
//        [[UINavigationBar appearance] setBarTintColor:[SMTheme colorForBarTintColor]];
//    }
//}

- (void)onDeviceShake:(NSNotification *)n
{
//    XLog_d(@"shaked: %@", n.userInfo);
    [[NSUserDefaults standardUserDefaults] setBool:![SMConfig enableDayMode] forKey:USERDEFAULTS_CONFIG_ENABLE_DAY_MODE];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFYCATION_THEME_CHANGED object:nil];
    
    [SMUtils trackEventWithCategory:@"setting" action:@"enableDayMode" label:[SMConfig enableDayMode] ? @"on" : @"off"];
}

- (void)setupShakeMotion
{
    self.motionManager = [CMMotionManager new];
    self.motionManager.deviceMotionUpdateInterval = 1;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        CMAcceleration userAcceleration = motion.userAcceleration;
        double accelerationThreshold = 0.5;
//        XLog_d(@"%lf, %lf, %lf", userAcceleration.x, userAcceleration.y, userAcceleration.z);
        if(fabs(userAcceleration.x) > accelerationThreshold
           /*|| fabs(userAcceleration.y) > accelerationThreshold
           || fabs(userAcceleration.z)> accelerationThreshold */){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFYCATION_SHAKE object:self];
            [SMUtils trackEventWithCategory:@"setting" action:@"shake" label:nil];
               XLog_d(@"%lf", userAcceleration.x);
        }
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    [SMURLProtocol doRegister];
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
//    [self setupTheme];
    // fix iOS11 ScrollView
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    self.isNewLaunching = YES;
    
    [SMAccountManager instance];
    
    _mainViewController = [[SMMainViewController alloc] init];
    
    if ([SMConfig iPadMode]) {
        _ipadSplitViewController = [SMIPadSplitViewController new];
        SMIpadEmptyViewController *detailVc = [SMIpadEmptyViewController new];
        _ipadSplitViewController.masterViewController = _mainViewController;
        _ipadSplitViewController.detailViewController = detailVc;
        self.window.rootViewController = _ipadSplitViewController;
    } else {
        self.window.rootViewController = _mainViewController;
    }
    
    [self.window makeKeyAndVisible];
    [self setupGoogleAnalytics];
//    [self setupShakeMotion];
    
    
    NSString *latestVersion = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_STAT_VERSION];
    if (![[SMUtils appVersionString] isEqualToString:latestVersion]) {
        NSString *label = [NSString stringWithFormat:@"%@%@", [SMUtils isPad] ? @"ipad_" : @"", [SMUtils appVersionString]];
        [SMUtils trackEventWithCategory:@"user" action:@"unique" label:label];
        [[NSUserDefaults standardUserDefaults] setObject:[SMUtils appVersionString] forKey:USERDEFAULTS_STAT_VERSION];

        // 清除历史patch js
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (paths.count > 0) {
            NSString *doc = [paths objectAtIndex:0];
            NSString *filepath = [NSString stringWithFormat:@"%@/parser", doc];
            NSError *error;
            BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
            if (removeSuccess) {
                XLog_d(@"remove [%@] success", filepath);
            } else {
                XLog_d(@"remove [%@] error:[%@]", filepath, error);
            }
        }
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    _updater = [[SMUpdater alloc] init];
    [_updater checkAndUpdate];
    
    XLog_d(@"%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceShake:) name:NOTIFYCATION_SHAKE object:nil];

    [self showAdView];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    
    // ios9 add shortcuts
    [self makeupShortcuts];
    
    // zanshang
    [[SMZanShangUtil sharedInstance] addOpenCount];
    
    // handle shortcuts
    BOOL shouldPerformAdditionalDelegateHandling = true;
    if ([SMUtils systemVersion] >= 9) {
        UIApplicationShortcutItem *item = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
        if (item) {
            shouldPerformAdditionalDelegateHandling = false;
            self.launchedShortcutItem = item;
        }
    }
    
    return shouldPerformAdditionalDelegateHandling;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    completionHandler([self handleShortCutItem:shortcutItem]);
}

- (BOOL)handleShortCutItem:(UIApplicationShortcutItem *)item
{
    if ([item.type isEqualToString:@"me.maxin.newsmth/message"]) {
        [[SMMainViewController instance] setRootViewController:[SMNoticeViewController instance]];
    } else {
        SMBoardViewController *vc = [SMBoardViewController new];
        SMBoard *board = [SMBoard new];
        board.name = item.type;
        board.cnName = (NSString *)item.userInfo[@"cnName"];
        vc.board = board;
        
        [[SMMainViewController instance].centerViewController pushViewController:vc animated:YES];
    }
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (self.isNewLaunching) {
        [self hideAdViewDelay];
    } else {
        [self hideAdView];
    }
    self.isNewLaunching = NO;
    
    if (self.launchedShortcutItem) {
        [self handleShortCutItem:self.launchedShortcutItem];
        self.launchedShortcutItem = nil;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self makeupShortcuts];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self showAdView];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self showAdView];
    
    if ([SMAccountManager instance].isLogin) {
        XLog_d(@"load notice");
        [_keepLoginOp cancel];
        _keepLoginOp = [[SMWebLoaderOperation alloc] init];
        _keepLoginOp.delegate = self;
        _completionHandler = completionHandler;
        [_keepLoginOp loadUrl:URL_PROTOCOL @"//m.mysmth.net/user/query/" withParser:@"notice,util_notice"];
    } else {
        NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_USERNAME];
        NSString *passwd =  [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_PASSWORD];
        if (user && passwd) {
            SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:URL_PROTOCOL @"//m.mysmth.net/user/login"]];
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

//    NSURL *url = [NSURL URLWithString:URL_PROTOCOL @"//m.mysmth.net/user/query/"];
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
    [SMAccountManager instance].notice = newNotice;
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
    
    if (newNotice.mail > lastFetchNotice.mail || newNotice.at > lastFetchNotice.at || newNotice.reply > lastFetchNotice.reply) {
        [SMConfig resetFetchTime];

        if (res.count > 0) {
            NSString *message = [NSString stringWithFormat:@"%@ 新的消息：%@", opt == _loginOp ? @"登录" : @"", [res componentsJoinedByString:@", "]];
            [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
            [self showNotification:message];
            [SMUtils trackEventWithCategory:@"user" action:@"localnotify" label:nil];
        }
//        [self showNotification:@"notice change, reset fetch time"];
    }

    [self scheduleNextBackgroundFetch];
    // save new fetched notice
    [def setObject:[newNotice encode] forKey:USERDEFAULTS_NOTICE_FETCH];

    _completionHandler(UIBackgroundFetchResultNewData);
    _completionHandler = nil;
    
    
    // add notice
    [self makeupShortcuts];
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

#pragma mark - Ad
- (void)showAdView
{
//    if (![SMAdViewController hasAd]) return ;
  /* do nth
    if (self.adViewController == nil) {
        self.adViewController = [SMAdViewController new];
    }
    
    CGFloat angle = 0;
    CGRect frame = self.window.bounds;
    
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    if (o == UIDeviceOrientationUnknown) {
        o = (UIDeviceOrientation) [[UIApplication sharedApplication] statusBarOrientation];
    }
    
    if (o == UIDeviceOrientationLandscapeLeft) {
        angle = M_PI_2;
    }
    if (o == UIDeviceOrientationLandscapeRight){
        angle = -M_PI_2;
    }
    
    self.adViewController.view.transform = CGAffineTransformMakeRotation(angle);
    self.adViewController.view.frame = frame;

    self.adViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.window addSubview:self.adViewController.view];
   */
}

- (void)hideAdView
{
    [self.adViewController.view removeFromSuperview];
}

- (void)hideAdViewDelay
{
    [self performSelector:@selector(hideAdView) withObject:nil afterDelay:2];
}


- (void)makeupShortcuts
{
    if ([SMUtils systemVersion] >= 9
        && _mainViewController.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable
        ) {
        NSMutableArray *items = [NSMutableArray new];
        
        SMNotice *notice = [SMAccountManager instance].notice;
        if (notice.reply > 0 || notice.mail > 0 || notice.at > 0) {
            NSMutableArray *comps = [[NSMutableArray alloc] init];
            if (notice.at > 0) {
                [comps addObject:[NSString stringWithFormat:@"At:%d", notice.at]];
            }
            if (notice.reply > 0) {
                [comps addObject:[NSString stringWithFormat:@"Re:%d", notice.reply]];
            }
            if (notice.mail > 0) {
                [comps addObject:@"信"];
            }
            
            NSString *hint = [comps componentsJoinedByString:@", "];
            NSString *text = [NSString stringWithFormat:@"消息(%@)", hint.length > 0 ? hint : @"0"];
            
            UIMutableApplicationShortcutItem *item = [[UIMutableApplicationShortcutItem alloc] initWithType:@"me.maxin.newsmth/message" localizedTitle:text localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"icon_ring"] userInfo:nil];
            [items addObject:item];
        }
        
        [[SMConfig getOfflineBoards] enumerateObjectsUsingBlock:^(NSDictionary *board, NSUInteger idx, BOOL * _Nonnull stop) {
            UIMutableApplicationShortcutItem *item = [[UIMutableApplicationShortcutItem alloc] initWithType:board[@"name"] localizedTitle:board[@"cnName"] localizedSubtitle:board[@"name"] icon:nil userInfo:board];
            [items addObject:item];
        }];
        
        UIApplication *app = [UIApplication sharedApplication];
        app.shortcutItems = items;
    }
}

@end
