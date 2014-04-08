//
//  SMDBManager.m
//  newsmth
//
//  Created by Maxwin on 14-3-8.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMDBManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#define DB_VERSION 1
#define USER_DEFAULT_DB_VERSION @"db_version"

@interface SMDBManager ()
@property (strong, nonatomic) FMDatabaseQueue *dbQueue;
@end

@implementation SMDBManager

+ (instancetype)instance
{
    static SMDBManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SMDBManager alloc] init];
    });
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"xsmth.db"];
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSInteger oldVersion = [[NSUserDefaults standardUserDefaults] integerForKey:USER_DEFAULT_DB_VERSION];
    switch (oldVersion) {
        case 0:
            [self queryV0];
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:DB_VERSION forKey:USER_DEFAULT_DB_VERSION];
    
    // clean old post read count
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        int now = (int)[[NSDate date] timeIntervalSince1970];
        int saveTime = 50 * 24 * 3600;  // save post read flag for 50 days
        [db executeUpdate:@"DELETE FROM post_read_flag WHERE readtime < ?", @(now - saveTime)];
    }];
}

- (void)queryV0
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS posts (pid INT, gid INT, board TEXT, site INT, data TEXT, PRIMARY KEY (pid, board, site))"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS post_read_flag (pid INT, board TEXT, site INT, readcount INT, type INT, readtime INT, PRIMARY KEY (pid, type, board, site))"];
    }];
}

- (void)dealloc
{
//    [self.db beginTransaction];
    [self.dbQueue close];
}

#pragma mark - posts
- (void)insertPost:(SMPost *)post
{
//    [self.db beginTransaction];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"REPLACE INTO posts (pid, gid, board, site, data) VALUES (?, ?, ?, ?, ?)", @(post.pid), @(post.gid), post.board.name, @(1), post.description];
    }];
}

- (void)queryPost:(int)pid board:(NSString *)boardName completed:(void (^)(SMPost *post))completed
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * from posts WHERE pid=? AND board=? AND site=?", @(pid), boardName, @(1)];
        SMPost *post = nil;
        if (set.next) {
            NSString *data = [set stringForColumn:@"data"];
            NSDictionary *json = [SMUtils string2json:data];
            if (json) {
                post = [[SMPost alloc] initWithJSON:json];
            }
        }
        [set close];
        dispatch_async(dispatch_get_main_queue(), ^{
            completed(post);
        });
    }];
}

- (void)deletePostsWithGid:(int)gid board:(NSString *)boardName
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM posts WHERE gid=? and board=?", @(gid), boardName];
    }];
}

#pragma mark - post read count
- (void)insertPostReadCount:(SMPost *)post type:(NSInteger)type
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        [db executeUpdate:@"REPLACE INTO post_read_flag (pid, readcount, type, readtime, board, site) VALUES (?, ?, ?, ?, ?, ?)", @(post.pid), @(post.readCount), @(type), @((int)timestamp), post.board.name, @(1)];
    }];
}

- (void)queryReadCount:(NSArray *)posts type:(NSInteger)type completed:(void (^)(NSArray *resultPosts))completed
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSMutableDictionary *postsMap = [[NSMutableDictionary alloc] init];
        NSMutableArray *pids = [[NSMutableArray alloc] initWithCapacity:posts.count];
        __block NSString *boardName = @"";
        [posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SMPost *post = obj;
            [pids addObject:[NSString stringWithFormat:@"%d", post.pid]];
            [postsMap setObject:post forKey:@(post.pid)];
            boardName = post.board.name;
        }];
        NSString *pidsString = [pids componentsJoinedByString:@","];
        NSString *query = [NSString stringWithFormat:@"SELECT * from post_read_flag WHERE type=? and pid in (%@) and board=? and site=?", pidsString];
        FMResultSet *set = [db executeQuery:query, @(type), boardName, @1];
        while (set.next) {
            int pid = [set intForColumn:@"pid"];
            int readCount = [set intForColumn:@"readcount"];
            SMPost *post = postsMap[@(pid)];
            post.readCount = readCount;
        }
        [set close];
        dispatch_async(dispatch_get_main_queue(), ^{
            completed(posts);
        });
    }];
}



@end
