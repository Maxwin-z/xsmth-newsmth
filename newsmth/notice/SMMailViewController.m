//
//  SMMailViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-28.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMailViewController.h"

@interface SMMailViewController ()

@end

@implementation SMMailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"邮箱"
                                                    image:[UIImage imageNamed:@"tabbar_mail"]
                                                      tag:0];
    self.tabBarItem.badgeValue = @"信";
}

@end
