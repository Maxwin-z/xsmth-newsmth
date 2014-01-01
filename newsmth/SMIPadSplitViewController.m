//
//  SMIPadSplitViewController.m
//  newsmth
//
//  Created by Maxwin on 13-12-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMIPadSplitViewController.h"
#import "UIView+Utils.h"

@interface SMIPadSplitViewController ()
@property (strong, nonatomic) UIView *masterViewContainer;
@property (strong, nonatomic) UIView *detailViewContainer;
@end

@implementation SMIPadSplitViewController

- (id)init
{
    self = [super init];
    self.masterViewContainer = [UIView new];
    self.detailViewContainer = [UIView new];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat width = self.view.frame.size.width * 320 / 1024;
    
    CGRect masterFrame = self.view.frame;
    masterFrame.size.width = width;
    self.masterViewContainer.frame = masterFrame;
    [self.view addSubview:self.masterViewContainer];
    
    CGRect detailFrame = self.view.frame;
    detailFrame.origin.x = width;
    detailFrame.size.width -= width;
    self.detailViewContainer.frame = detailFrame;
    [self.view addSubview:self.detailViewContainer];
    
    self.masterViewContainer.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.detailViewContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setMasterViewController:(UIViewController *)masterViewController
{
    _masterViewController = masterViewController;
    [self.masterViewContainer removeAllSubviews];
    [self.masterViewContainer addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = self.masterViewContainer.bounds;
    self.masterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setDetailViewContainer:(UIView *)detailViewContainer
{
    _detailViewContainer = detailViewContainer;
    [self.detailViewContainer removeAllSubviews];
    [self.detailViewContainer addSubview:self.detailViewController.view];
    self.detailViewController.view.frame = self.detailViewContainer.bounds;
    self.detailViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

@end
