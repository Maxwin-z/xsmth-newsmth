//
//  P2PViewController.h
//  P2PNavigationController
//
//  Created by Maxwin on 13-6-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2PNavigationController.h"

//@protocol P2PNavigationControllerDelegate;

@interface P2PViewController : UIViewController<P2PNavigationControllerDelegate>
@property (strong, nonatomic) UIImage *captureImage;
@end
