//
//  SMIPadSplitViewController.m
//  newsmth
//
//  Created by Maxwin on 13-12-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMIPadSplitViewController.h"
#import "UIView+Utils.h"

static SMIPadSplitViewController *_instance;

@interface SMIPadSplitViewController ()
@property (strong, nonatomic) UIView *masterViewContainer;
@property (strong, nonatomic) UIView *detailViewContainer;
@property (strong, nonatomic) P2PNavigationController *detailNavigationController;
@end

@implementation SMIPadSplitViewController

+ (SMIPadSplitViewController *)instance
{
    if (_instance == nil) {
        _instance = [SMIPadSplitViewController new];
    }
    return _instance;
}

- (id)init
{
    if (_instance == nil) {
        _instance = self = [super init];
        self.masterViewContainer = [UIView new];
        self.detailViewContainer = [UIView new];
    }
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

- (void)setDetailViewController:(UIViewController *)detailViewController
{
    _detailViewController = detailViewController;
    [self.detailViewContainer removeAllSubviews];
    self.detailNavigationController = [[P2PNavigationController alloc] initWithRootViewController:_detailViewController];
    [self.detailViewContainer addSubview:self.detailNavigationController.view];
    CGRect frame = self.detailViewContainer.bounds;
    // fixme. for ios5,6
    if ([SMUtils systemVersion] < 7) {
        CGFloat statusBarHeight = 20;
        frame.origin.y = -statusBarHeight;
        frame.size.height += statusBarHeight;
    }
    self.detailNavigationController.view.frame = frame;
    
    self.detailNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
