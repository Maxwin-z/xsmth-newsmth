//
//  SMWebLoaderOperationQueue.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMWebLoaderOperationQueue.h"

static SMWebLoaderOperationQueue *instance = nil;
static SMWebLoaderOperationQueue *backupInstance = nil;

@implementation SMWebLoaderOperationQueue

+ (SMWebLoaderOperationQueue *)sharedInstance
{
    if (instance == nil) {
        instance = [[SMWebLoaderOperationQueue alloc] init];
    }
    return instance;
}

+ (SMWebLoaderOperationQueue *)sharedBackupInstance
{
    if (backupInstance == nil) {
        backupInstance = [[SMWebLoaderOperationQueue alloc] init];
    }
    return backupInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.maxConcurrentOperationCount = 2;
    }
    return self;
}
@end
