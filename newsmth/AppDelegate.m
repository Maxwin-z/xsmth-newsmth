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

@interface AppDelegate ()
@property (strong, nonatomic) UINavigationController *nvc;
@property (strong, nonatomic) SMMainpageViewController *mainpageViewController;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) SMMainViewController *mainViewController;
@end

@implementation AppDelegate

- (void)setupGoogleAnalytics
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-41978299-1"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
//    _mainpageViewController = [[SMMainpageViewController alloc] init];
//    _nvc = [[UINavigationController alloc] initWithRootViewController:_mainpageViewController];
//    self.window.rootViewController = _nvc;
//    
//    _viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
//    self.window.rootViewController = _viewController;
    
    _mainViewController = [[SMMainViewController alloc] init];
    self.window.rootViewController = _mainViewController;
    
    [self.window makeKeyAndVisible];
    
    [self setupGoogleAnalytics];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
