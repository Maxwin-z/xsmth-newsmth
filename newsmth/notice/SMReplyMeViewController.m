//
//  SMReplyMeViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-28.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMReplyMeViewController.h"

@interface SMReplyMeViewController ()

@end

@implementation SMReplyMeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"回复我"
                                                    image:[UIImage imageNamed:@"tabbar_reply"]
                                                      tag:0];
    self.tabBarItem.badgeValue = @"99+";
}


@end
