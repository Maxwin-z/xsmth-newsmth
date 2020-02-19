//
//  SMWebLoaderOperation.h
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMBaseData.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
// #import "ASIHTTPRequest.h"

@class SMWebLoaderOperation;

@protocol SMWebLoaderOperationDelegate <NSObject>
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt;
- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error;
@end

@interface SMWebLoaderOperation : NSOperation
{
    id _data;
    BOOL _isDone;
}
@property (weak, nonatomic) id<SMWebLoaderOperationDelegate> delegate;
@property (strong, nonatomic, readonly) NSString *url;
@property (strong, nonatomic, readonly) id data;
@property (assign, nonatomic) BOOL highPriority;
@property (assign, nonatomic, readonly) BOOL isDone;
@property (strong, nonatomic) void(^onSuccess)(SMBaseData *data);
@property (strong, nonatomic) void(^onFail)(SMMessage *error);

- (void)loadUrl:(NSString *)url withParser:(NSString *)parser;
- (void)loadRequest:(ASIHTTPRequest *)request withParser:(NSString *)parser;

// todo, find why?
+ (void)cancelAllOperations;

// for subclass
- (void)enqueue;

@end
