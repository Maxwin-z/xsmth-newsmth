//
//  XWebViewController.m
//  newsmth
//
//  Created by Maxwin on 16/3/1.
//  Copyright © 2016年 nju. All rights reserved.
//

#import "XWebViewController.h"

@interface XWebViewController ()

@end

@implementation XWebViewController

- (BOOL)prefersStatusBarHidden
{
    return NO; // [self useNewHideShow] ? NO : self.hideTop;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

@end
