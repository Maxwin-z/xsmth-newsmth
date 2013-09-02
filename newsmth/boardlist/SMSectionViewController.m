//
//  SMSectionViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMSectionViewController.h"

static SMSectionViewController *_instance;

@interface SMSectionViewController ()

@end

@implementation SMSectionViewController
+ (SMSectionViewController *)instance
{
    if (_instance == nil) {
        _instance = [[SMSectionViewController alloc] init];
    }
    return _instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title == nil) {
        self.title = @"分区";
    }
    [self.tableView beginRefreshing];
}


@end
