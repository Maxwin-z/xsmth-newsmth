//
//  SMIPadSplitViewController.h
//  newsmth
//
//  Created by Maxwin on 13-12-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"

@interface SMIPadSplitViewController : UIViewController

+ (SMIPadSplitViewController *)instance;

@property (strong, nonatomic) UIViewController *masterViewController;
@property (strong, nonatomic) UIViewController *detailViewController;
@end
