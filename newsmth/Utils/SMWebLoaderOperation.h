//
//  SMWebLoaderOperation.h
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMWebLoaderOperation;

@protocol SMWebLoaderOperationDelegate <NSObject>
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt;
@end

@interface SMWebLoaderOperation : NSOperation
@property (weak, nonatomic) id<SMWebLoaderOperationDelegate> delegate;
@property (strong, nonatomic, readonly) NSString *url;
@property (strong, nonatomic, readonly) NSDictionary *result;

- (void)loadUrl:(NSString *)url withParser:(NSString *)parser;
@end
