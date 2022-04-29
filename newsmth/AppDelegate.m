//
//  AppDelegate.m
//  newsmth
//
//  Created by Maxwin on 13-5-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

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

@interface AppDelegate ()
@property (strong, nonatomic) UINavigationController *nvc;
@property (strong, nonatomic) SMMainpageViewController *mainpageViewController;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) SMMainViewController *mainViewController;
@property (strong, nonatomic) SMIPadSplitViewController *ipadSplitViewController;

@property (strong, nonatomic) SMWebLoaderOperation *keepLoginOp;
@property (strong, nonatomic) SMWebLoaderOperation *loginOp;

@property (strong, nonatomic) void (^completionHandler)(UIBackgroundFetchResult);

@property (strong, nonatomic) SMUpdater *updater;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) UIApplicationShortcutItem *launchedShortcutItem;

@property (strong, nonatomic) XBackground *bg;

@end

@implementation AppDelegate

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
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        
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

    self.bg = [[XBackground alloc] initWithApplication:application];
    [self.bg setupBackgroundTask];
    
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
    
    // ios9 add shortcuts
    [self makeupShortcuts];
    
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
    if (self.launchedShortcutItem) {
        [self handleShortCutItem:self.launchedShortcutItem];
        self.launchedShortcutItem = nil;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self makeupShortcuts];
    [self.bg scheduleBackgroundTask];
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
