//
//  SMIpadEmptyViewController.m
//  newsmth
//
//  Created by Maxwin on 14-1-5.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMIpadEmptyViewController.h"

@interface SMIpadEmptyViewController ()

@end

@implementation SMIpadEmptyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"xsmth@maxwin";

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_bg"]];
    imageView.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f);
    [self.view addSubview:imageView];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}


@end
