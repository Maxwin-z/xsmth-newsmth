//
//  SMWebLoaderOperationQueue.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMWebLoaderOperationQueue.h"

static SMWebLoaderOperationQueue *instance = nil;

@implementation SMWebLoaderOperationQueue

+ (SMWebLoaderOperationQueue *)sharedInstance
{
    if (instance == nil) {
        instance = [[SMWebLoaderOperationQueue alloc] init];
    }
    return instance;
}

- (id)init
{
    if (instance != nil) {
        return instance;
    }
    return self = [super init];
}
@end
