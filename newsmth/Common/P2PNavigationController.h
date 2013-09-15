//
//  P2PNavigationController.h
//  P2PNavigationController
//
//  Created by Maxwin on 13-6-22.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol P2PNavigationControllerDelegate <NSObject>
@optional
- (BOOL)navigationUnsupportPanToPop;
@end

@interface P2PNavigationController : UINavigationController

@end
