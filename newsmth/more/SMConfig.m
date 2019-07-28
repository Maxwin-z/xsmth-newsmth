//
//  SMConfig.m
//  newsmth
//
//  Created by Maxwin on 13-10-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMConfig.h"
#import "UIDeviceHardware.h"



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
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_HIDE_TOP_POST defaults:NO];
}

+ (BOOL)enableUserClick
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_USER_CLICKABLE defaults:NO];
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
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_SHOW_QMD defaults:NO];
}

+ (BOOL)enableOptimizePostContent
{
    return NO;
    /*
    NSString *platform = [UIDeviceHardware platform];
    BOOL optimize = NO;
    // < iphone 5
    if ([platform hasPrefix:@"iPhone"] && [platform compare:@"iPhone5"] == NSOrderedAscending) {
        optimize = YES;
    }
    // < ipod 5
    if (!optimize && [platform hasPrefix:@"iPod"] && [platform compare:@"iPod5"] == NSOrderedAscending) {
        optimize = YES;
    }
    // ipad 1 & ipad2
    if (!optimize && [platform hasPrefix:@"iPad"] && [platform compare:@"iPad2,5"] == NSOrderedAscending) {
        optimize = YES;
    }
    
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_OPTIMIZE_POST_CONTENT defaults:optimize];
     */
}

+ (BOOL)enableDayMode
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_ENABLE_DAY_MODE defaults:YES];
}

+ (BOOL)enableShakeSwitchDayMode
{
    return [SMConfig configForKey:USERDEFUALTS_CONFIG_ENABLE_SHAKE_SWITCH_DAY_MODE defaults:YES];
}

+ (BOOL)disableTail
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_ENABLE_DISABLE_TAIL defaults:NO];
}

+ (BOOL)disableAd
{
    return [SMConfig isPro] && [SMConfig configForKey:USERDEFAULTS_CONFIG_ENABLE_DISABLE_AD defaults:NO];
}

+ (BOOL)isPro
{
    return [SMConfig configForKey:USERDEFAULTS_PRO defaults:NO];
}

+ (BOOL)enableMobileAutoLoadImage
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_ENABLE_MOBILE_AUTO_LOAD_IMAGE defaults:NO];
}

+ (BOOL)enableTapPaing
{
    return [SMConfig configForKey:USERDEFAULTS_CONFIG_ENABLE_TAP_PAGING defaults:YES];
}

+ (BOOL)iPadMode
{
    return [SMUtils isPad] && [SMConfig configForKey:USERDEFAULTS_CONFIG_ENABLE_PAD_MODE defaults:NO];
}

+ (NSInteger)adRatio
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_UPDATE_ADRATIO];
    if (obj) {
        return [obj integerValue];
    }
    return 30;  // default 30%
}

+ (NSInteger)adPostion
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_UPDATE_ADPOSTION];
    if (obj) {
        return MAX(3, [obj integerValue]);
    }
    return 4;  // default 4 posts
}

+ (NSArray *)historyBoards
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_BOARD_HISTORY];
}

+ (void)addBoardToHistory:(SMBoard *)board
{
    NSDictionary *dict = @{@"name": board.name, @"cnName": board.cnName ?: @""};
    NSMutableArray *boards = [[SMConfig historyBoards] mutableCopy];
    if (boards == nil) {
        boards = [[NSMutableArray alloc] init];
    }
    [boards insertObject:dict atIndex:0];
    const int maxHistory = 20;
    for (int i = (int)boards.count - 1; i > 0; --i) {
        NSDictionary *b = boards[i];
        if (i > maxHistory || [b[@"name"] isEqualToString:board.name]) {    // 最多保存maxHistory个最近浏览版面
            [boards removeObjectAtIndex:i];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:boards forKey:USERDEFAULTS_BOARD_HISTORY];
}

+ (void)addOfflineBoard:(SMBoard *)board
{
    NSDictionary *dict = @{@"name": board.name, @"cnName": board.cnName};
    NSMutableArray *boards = [NSMutableArray new];
    [[SMConfig getOfflineBoards] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj[@"name"] isEqualToString:board.name]) {
            [boards addObject:obj];
        }
    }];
    [boards insertObject:dict atIndex:0];
    [SMConfig setOfflineBoards:boards];
}

+ (void)setOfflineBoards:(NSArray *)boards
{
    [[NSUserDefaults standardUserDefaults] setObject:boards forKey:USERDEFAULTS_BOARD_OFFLINE];
}

+ (NSArray *)getOfflineBoards
{
    NSArray *boards = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_BOARD_OFFLINE];
    if (boards == nil) {
        boards = @[];
    }
    return boards;
}


+ (UIFont *)listFont
{
    NSString *listFontFamily = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_LIST_FONT_FAMILY];
    NSInteger listFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_LIST_FONT_SIZE];
    if (listFontFamily == nil) {
        listFontFamily = @"FZLanTingHei-L-GBK";
    }
    if (listFontSize == 0) {
        listFontSize = 20;
    }
    return [UIFont fontWithName:listFontFamily size:listFontSize] ?: [UIFont systemFontOfSize:listFontSize];
}

+ (UIFont *)postFont
{
    NSString *postFontFamily = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_POST_FONT_FAMILY];
    NSInteger postFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_POST_FONT_SIZE];
    if (postFontFamily == nil) {
        postFontFamily = @"FZLanTingHei-L-GBK";
    }
    if (postFontSize == 0) {
        postFontSize = 26;
    }
    return [UIFont fontWithName:postFontFamily size:postFontSize] ?: [UIFont systemFontOfSize:postFontSize];
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


#pragma mark - block list
+ (NSString *)blocklistPath
{
    return [[SMUtils documentPath] stringByAppendingString:@"/blocklist.json"];
}

+ (NSMutableDictionary *)blocklist
{
    static dispatch_once_t onceToken;
    static NSMutableDictionary *_blocklist;

    dispatch_once(&onceToken, ^{
        _blocklist = [NSMutableDictionary new];
        NSString *path = [SMConfig blocklistPath];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *json = [SMUtils string2json:content ?: @"{}"];
        if (json != nil) {
            [_blocklist addEntriesFromDictionary:json];
        }
        
    });
    
    return _blocklist;
}

+ (void)saveBlocklist
{
    NSDictionary *json = [SMConfig blocklist];
    NSString *content = [SMUtils json2string:json];
    [content writeToFile:[SMConfig blocklistPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (BOOL)isBlockedKey:(NSString *)key {
    id val = [[SMConfig blocklist] objectForKey:key];
    return val ? [val boolValue] : NO;
}

+ (void)addBlockedKey:(NSString *)key {
    [[SMConfig blocklist] setObject:@(YES) forKey:key];
    [SMConfig saveBlocklist];
}

+ (void)removeBlockedKey:(NSString *)key {
    [[SMConfig blocklist] removeObjectForKey:key];
    [SMConfig saveBlocklist];
}

+ (NSString *)pid2key:(int)pid
{
    return [NSString stringWithFormat:@"_%d", pid];
}

+ (BOOL)isBlocked:(int)pid
{
    return [SMConfig isBlockedKey:[SMConfig pid2key:pid]];
}

+ (void)addBlock:(int)pid
{
    [SMConfig addBlockedKey:[SMConfig pid2key:pid]];
}

+ (NSString *)author2key:(NSString *)author
{
    return [NSString stringWithFormat:@"@%@", author];
}

+ (BOOL)isBlockedAuthor:(NSString *)author {
    return [SMConfig isBlockedKey:[SMConfig author2key:author]];
}

+ (void)addBlockedAuthor:(NSString *)author {
    [SMConfig addBlockedKey:[SMConfig author2key:author]];
}

+ (void)removeBlockedAuthor:(NSString *)author {
    [SMConfig removeBlockedKey:[SMConfig author2key:author]];
}

+ (NSArray *)getBlockedAuthors {
    NSMutableArray *array = [[NSMutableArray alloc] init];

    for (NSString *key in [SMConfig blocklist]) {
        if ([key hasPrefix:@"@"] && [SMConfig isBlockedKey:key]) {
            [array addObject:[key substringFromIndex:1]];
        }
    }

    return [array sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

@end
