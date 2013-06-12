//
//  SMNavigationController.m
//  newsmth
//
//  Created by Maxwin on 13-6-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMNavigationController.h"
#import "SMMainViewController.h"
#import <QuartzCore/CALayer.h>

@interface SMNavigationController ()

@end

@implementation SMNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIView *currentView = self.view;
    CGSize size = currentView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [currentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *topImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [SMMainViewController instance].topImage = topImage;
    [[SMMainViewController instance] showPushAnimation];

    [super pushViewController:viewController animated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = [self.viewControllers lastObject];
    [[SMMainViewController instance] popCenterViewController];
    return vc;
}

- (void)_realPop
{
    [super popViewControllerAnimated:NO];
}

@end
