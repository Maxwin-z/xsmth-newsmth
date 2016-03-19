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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

@end
