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
+ (void)setSite2:(BOOL)is2;
+ (BOOL)is2;
+ (BOOL)enableBackgroundFetch;
+ (BOOL)enableBackgroundFetchSmartMode;
+ (BOOL)disableShowTopPost;
+ (BOOL)enableUserClick;
+ (BOOL)enableShowReplyAuthor;
+ (BOOL)enableOptimizePostContent;
+ (BOOL)enableIOS7SwipeBack;
+ (BOOL)enableShowQMD;
+ (BOOL)enableDayMode;
+ (BOOL)disableTail;
+ (BOOL)disableAd;
+ (BOOL)isPro;

+ (void)addBoardToHistory:(SMBoard *)board;
+ (NSArray *)historyBoards;

+ (UIFont *)listFont;
+ (UIFont *)postFont;

+ (NSInteger)nextFetchTime;
+ (void)resetFetchTime;

@end
