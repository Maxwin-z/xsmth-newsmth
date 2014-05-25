//
//  SMConfig.h
//  newsmth
//
//  Created by Maxwin on 13-10-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMData.h"

@interface SMConfig : NSObject
+ (BOOL)enableBackgroundFetch;
+ (BOOL)enableBackgroundFetchSmartMode;
+ (BOOL)disableShowTopPost;
+ (BOOL)enableUserClick;
+ (BOOL)enableShowReplyAuthor;
+ (BOOL)enableOptimizePostContent;
+ (BOOL)enableIOS7SwipeBack;
+ (BOOL)enableShowQMD;
+ (BOOL)enableDayMode;
+ (BOOL)enableShakeSwitchDayMode;
+ (BOOL)disableTail;
+ (BOOL)disableAd;
+ (BOOL)isPro;
+ (BOOL)enableMobileAutoLoadImage;

+ (void)addBoardToHistory:(SMBoard *)board;
+ (NSArray *)historyBoards;

+ (UIFont *)listFont;
+ (UIFont *)postFont;

+ (NSInteger)nextFetchTime;
+ (void)resetFetchTime;

@end
