//
//  SMFavorListViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMFavorListViewController.h"
#import "SMLoginViewController.h"

static SMFavorListViewController *_instance;

@interface SMFavorListViewController ()

@end

@implementation SMFavorListViewController

+ (SMFavorListViewController *)instance
{
    if (_instance == nil) {
        _instance = [[SMFavorListViewController alloc] init];
    }
    return _instance;
}

- (IBAction)onLoginButtonClick:(id)sender
{
    SMLoginViewController *loginVc = [[SMLoginViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:loginVc];
    [self.navigationController presentModalViewController:nvc animated:YES];
}

@end
