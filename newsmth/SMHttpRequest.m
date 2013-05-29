//
//  SMHttpRequest.m
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMHttpRequest.h"

@interface SMHttpRequest() <ASIHTTPRequestDelegate>
@property (weak, nonatomic) id<ASIHTTPRequestDelegate> originalDelegate;
@end

@implementation SMHttpRequest
- (void)setDelegate:(id<ASIHTTPRequestDelegate>)delegate_
{
    _originalDelegate = delegate_;

    [super setDelegate:nil];
    [super setDelegate:self];
}

- (void)startSynchronous
{
    [super setDelegate:self];
    [super startSynchronous];
}

- (void)startAsynchronous
{
    [super setDelegate:self];
    [super startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate
- (void)request:(ASIHTTPRequest *)request_ didReceiveResponseHeaders:(NSDictionary *)responseHeaders_
{
//    XLog_d(@"%@", request_.responseCookies);
    // handle response header. update account status
    if ([_originalDelegate respondsToSelector:@selector(request:didReceiveResponseHeaders:)]) {
        [_originalDelegate request:request_ didReceiveResponseHeaders:responseHeaders_];
    }
}

#pragma mark - Method forward
- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [_originalDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _originalDelegate;
}


@end
