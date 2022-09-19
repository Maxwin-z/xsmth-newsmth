
//
//  SMMainViewController.h
//  newsmth
//
//  Created by Maxwin on 13-6-11.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"

@interface SMMainViewController : SMViewController

//@property (strong, nonatomic) UIImage *topImage;
@property (strong, nonatomic) P2PNavigationController *centerViewController;

+(SMMainViewController *)instance;
- (void)setRootViewController:(UIViewController *)viewController;
- (void)setLeftVisiable:(BOOL)visiable;
- (void)setBadgeVisiable:(BOOL)visiable;

@end
