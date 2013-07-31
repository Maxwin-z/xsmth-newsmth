//
//  SMAtMeViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-28.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMAtMeViewController.h"

@interface SMAtMeViewController ()

@end

@implementation SMAtMeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"@我"
                                                    image:[UIImage imageNamed:@"tabbar_at"]
                                                      tag:0];
    self.tabBarItem.badgeValue = @"1";
}

@end
