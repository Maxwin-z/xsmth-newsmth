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
#import "SMIPadSplitViewController.h"

#define TOAST_DURTAION  1.0f

@interface SMViewController : P2PViewController

@property (assign, nonatomic) CGFloat keyboardHeight;
@property (assign, nonatomic) UIDeviceOrientation currentOrientation;

- (void)toast:(NSString *)message;

- (void)showLoading:(NSString *)message;
- (void)hideLoading;
- (void)cancelLoading;

- (void)showLogin;
- (void)hideLogin;
- (void)performSelectorAfterLogin:(SEL)aSelector;

- (void)onKeyboardDidShow:(NSNotification *)n;
- (void)onKeyboardDidHide:(NSNotification *)n;

- (void)onThemeChangedNotification:(NSNotification *)n;
- (void)setupTheme;
- (void)onDeviceRotate;

@end
