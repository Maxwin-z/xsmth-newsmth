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
- (id)init
{
    self = [super init];
    if (self) {
        self.refer = @"at";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"@我";
}

@end
