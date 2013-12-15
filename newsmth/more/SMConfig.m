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

+ (BOOL)enableBackgroundFetchSmartMode
{
    return [SMUtils systemVersion] >= 7 && [SMConfig configForKey:USERDEFAULTS_CONFIG_BACKGROUND_FETCH_SMART_MODE defaults:YES];
}

+ (BOOL)disableShowTopPost
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_HIDE_TOP_POST defaults:YES];
}

+ (BOOL)enableUserClick
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_USER_CLICKABLE defaults:YES];
}

+ (BOOL)enableShowReplyAuthor
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_SHOW_REPLY_AUTHOR defaults:YES];
}

+ (BOOL)enableIOS7SwipeBack
{
    return [SMUtils systemVersion] >= 7 && [SMConfig configForKey:USERDEFAULTS_CONFIG_IOS7_SWIPE_BACK defaults:YES];
}

+ (BOOL)enableShowQMD
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_SHOW_QMD defaults:YES];
}

+ (BOOL)enableDayMode
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_ENABLE_DAY_MODE defaults:YES];
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

+ (UIFont *)listFont
{
    NSString *listFontFamily = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_LIST_FONT_FAMILY];
    NSInteger listFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_LIST_FONT_SIZE];
    if (listFontFamily == nil) {
        listFontFamily = @"Helvetica";
    }
    if (listFontSize == 0) {
        listFontSize = 15;
    }
    return [UIFont fontWithName:listFontFamily size:listFontSize];
}

+ (UIFont *)postFont
{
    NSString *postFontFamily = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_POST_FONT_FAMILY];
    NSInteger postFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_POST_FONT_SIZE];
    if (postFontFamily == nil) {
        postFontFamily = @"Helvetica";
    }
    if (postFontSize == 0) {
        postFontSize = 17;
    }
    return [UIFont fontWithName:postFontFamily size:postFontSize];
}

+ (NSInteger)nextFetchTime
{
    // 非只能模式下，固定时间
    if (![SMConfig enableBackgroundFetchSmartMode]) {
        return UIApplicationBackgroundFetchIntervalMinimum;
    }
    
    static int delays[] = {10, 20, 30, 50, 80, 130, 210, 340, 550, 890};
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_BACKGROUND_FETCH_INDEX];
    int max = sizeof(delays) / sizeof(int);
    if (index < 0) {
        index = 0;
    }
    
    // save next index
    [[NSUserDefaults standardUserDefaults] setInteger:index + 1 forKey:USERDEFAULTS_BACKGROUND_FETCH_INDEX];
    
    return delays[MIN(index, max - 1)];
}

+ (void)resetFetchTime
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:USERDEFAULTS_BACKGROUND_FETCH_INDEX];
}


@end
