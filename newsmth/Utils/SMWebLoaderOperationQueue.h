//
//  SMWebLoaderOperationQueue.h
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMWebLoaderOperationQueue : NSOperationQueue
+ (SMWebLoaderOperationQueue *)sharedInstance;
+ (SMWebLoaderOperationQueue *)sharedBackupInstance;
@end
