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
    NSInteger oldVersion = 0; //[[NSUserDefaults standardUserDefaults] integerForKey:USER_DEFAULT_DB_VERSION];
    switch (oldVersion) {
        case 0:
            [self queryV0];
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:DB_VERSION forKey:USER_DEFAULT_DB_VERSION];
}

- (void)queryV0
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS posts (pid INT, gid INT, data TEXT, PRIMARY KEY (pid))"];
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
        [db executeUpdate:@"REPLACE INTO posts (pid, gid, data) VALUES (?, ?, ?)", @(post.pid), @(post.gid), post.description];
    }];
}

- (void)queryPost:(int)pid completed:(void (^)(SMPost *))completed
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * from posts WHERE pid=?", @(pid)];
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
    /*
     @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        [self.db beginTransaction];
        FMResultSet *set = [self.db executeQuery:@"SELECT * from posts WHERE pid=?", @(pid)];
        SMPost *post = nil;
        if (set.next) {
            NSString *data = [set stringForColumn:@"data"];
            NSDictionary *json = [SMUtils string2json:data];
            if (json) {
                post = [[SMPost alloc] initWithJSON:json];
            }
        }
        [self.db commit];
        dispatch_async(dispatch_get_main_queue(), ^{
            completed(post);
        });
    });
     */
}


@end
