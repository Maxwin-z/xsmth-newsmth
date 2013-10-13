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
+ (BOOL)disableShowTopPost;
+ (BOOL)enableUserClick;
+ (BOOL)enableIOS7SwipeBack;
+ (BOOL)enableShowQMD;
+ (void)addBoardToHistory:(SMBoard *)board;
+ (NSArray *)historyBoards;
+ (UIFont *)listFont;
+ (UIFont *)postFont;
@end
