//
//  SMViewController.h
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//
//  add common methods

#import <UIKit/UIKit.h>
#import "SMWebLoaderOperation.h"
#import "SMAccountManager.h"

#define TOAST_DURTAION  1.0f

@interface SMViewController : P2PViewController
- (void)toast:(NSString *)message;
- (void)performSelectorAfterLogin:(SEL)aSelector;
@end
