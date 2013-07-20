//
//  SMAccountManager.h
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//
//  维护account的cookie信息，登录状态
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_ACCOUT @"notification_account"

@interface SMAccountManager : NSObject

//@property (strong, nonatomic) NSArray *cookies;
@property (assign, nonatomic, readonly) BOOL isLogin;
@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic) NSInteger noticeCount;

+ (SMAccountManager *)instance;
- (void)setCookies:(NSArray *)cookies;
@end
