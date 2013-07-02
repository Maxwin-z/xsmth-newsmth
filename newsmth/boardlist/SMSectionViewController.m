//
//  SMSectionViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMSectionViewController.h"

@interface SMSectionViewController ()

@end

@implementation SMSectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title == nil) {
        self.title = @"分区";
    }
    [self.tableView beginRefreshing];
}


@end
