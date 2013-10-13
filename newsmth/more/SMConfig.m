//
//  SMConfig.m
//  newsmth
//
//  Created by Maxwin on 13-10-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMConfig.h"

@implementation SMConfig

+ (BOOL)configForKey:(NSString *)key defaults:(BOOL)defaults
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return obj == nil ? defaults : [obj boolValue];
}

+ (BOOL)enableBackgroundFetch
{
    return [SMUtils systemVersion] >= 7 && [SMConfig configForKey:USERDEFAULTS_CONFIG_BACKGROUND_FETCH defaults:YES];
}

+ (BOOL)disableShowTopPost
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_HIDE_TOP_POST defaults:YES];
}

+ (BOOL)enableUserClick
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_USER_CLICKABLE defaults:YES];
}

+ (BOOL)enableIOS7SwipeBack
{
    return [SMUtils systemVersion] >= 7 && [SMConfig configForKey:USERDEFAULTS_CONFIG_IOS7_SWIPE_BACK defaults:YES];
}

+ (BOOL)enableShowQMD
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_SHOW_QMD defaults:YES];
}

+ (NSArray *)historyBoards
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_BOARD_HISTORY];
}

+ (void)addBoardToHistory:(SMBoard *)board
{
    NSDictionary *dict = @{@"name": board.name, @"cnName": board.cnName};
    NSMutableArray *boards = [[SMConfig historyBoards] mutableCopy];
    if (boards == nil) {
        boards = [[NSMutableArray alloc] init];
    }
    [boards insertObject:dict atIndex:0];
    for (int i = boards.count - 1; i > 0; --i) {
        NSDictionary *b = boards[i];
        if (i > 10 || [b[@"name"] isEqualToString:board.name]) {    // 最多保存10个最近浏览版面
            [boards removeObjectAtIndex:i];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:boards forKey:USERDEFAULTS_BOARD_HISTORY];
}

+ (UIFont *)postFont
{
    NSString *postFontFamily = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_POST_FONT_FAMILY];
    NSInteger postFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_POST_FONT_SIZE];
    if (postFontFamily == nil) {
        postFontFamily = @"Georgia";
    }
    if (postFontSize == 0) {
        postFontSize = 17;
    }
    return [UIFont fontWithName:postFontFamily size:postFontSize];
}

@end
