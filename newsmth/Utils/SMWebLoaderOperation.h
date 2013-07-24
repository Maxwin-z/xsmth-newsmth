//
//  SMWebLoaderOperation.h
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMBaseData.h"

@class SMWebLoaderOperation;

@protocol SMWebLoaderOperationDelegate <NSObject>
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt;
- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error;
@end

@interface SMWebLoaderOperation : NSOperation
@property (weak, nonatomic) id<SMWebLoaderOperationDelegate> delegate;
@property (strong, nonatomic, readonly) NSString *url;
@property (strong, nonatomic, readonly) id data;
@property (assign, nonatomic) BOOL highPriority;

- (void)loadUrl:(NSString *)url withParser:(NSString *)parser;
- (void)loadRequest:(SMHttpRequest *)request withParser:(NSString *)parser;
@end
