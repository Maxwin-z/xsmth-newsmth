//
//  SMWebLoaderOperation.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMWebLoaderOperation.h"
#import "SMHttpRequest.h"
#import "SMWebParser.h"
#import "SMWebLoaderOperationQueue.h"

@interface SMWebLoaderOperation ()<ASIHTTPRequestDelegate, SMWebParserDelegate>
@property (strong, nonatomic) NSString *parser;

@property (strong, nonatomic) ASIHTTPRequest *request;
@property (strong, nonatomic) SMWebParser *webParser;

@end

@implementation SMWebLoaderOperation
- (void)loadUrl:(NSString *)url withParser:(NSString *)parser
{
    _url = url;
    _parser = parser;
    [self enqueue];
}

- (void)loadRequest:(ASIHTTPRequest *)request withParser:(NSString *)parser
{
    _request = request;
    _parser = parser;
    _url = _request.url.absoluteString;
    [self enqueue];
}

+ (void)cancelAllOperations
{
    [[SMWebLoaderOperationQueue sharedInstance] cancelAllOperations];
}

- (void)enqueue
{
    if (_highPriority) {
        [[SMWebLoaderOperationQueue sharedBackupInstance] addOperation:self];
    } else {
        [[SMWebLoaderOperationQueue sharedInstance] addOperation:self];
    }
}

- (void)main
{
    if (self.isCancelled) {
        XLog_v(@"opt %@ is cancelled", _url);
        return;
    }
    if (_url == nil && _request == nil) {
//        XLog_e(@"request url is nil");
        return;
    }
    

    if (_request == nil) {
        NSURL *url = [NSURL URLWithString:_url];
        _request = [[SMHttpRequest alloc] initWithURL:url];
    }
    
    if ([_url hasPrefix:@"http://www.newsmth.net/nForum/"]) {
        [_request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    }
    
    _request.delegate = self;
    
    XLog_d(@"url[%@] start", _url);
    [_request startSynchronous];

    // 15s自动超时
//    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
//    while (!_isDone && !self.isCancelled && [NSDate timeIntervalSinceReferenceDate] - startTime < 11) {
//        @autoreleasepool {
//            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1e-6, true);
//        }
//	}
//    XLog_d(@"url[%@] exit", _url);

}

- (void)setOperationTimeout
{
    _isDone = YES;
    SMMessage *error = [[SMMessage alloc] initWithCode:SMNetworkErrorCodeRequestFail message:@"网络请求超时"];
    [_delegate webLoaderOperationFail:self error:error];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (self.isCancelled) {
        return;
    }

    XLog_d(@"url[%@] response", _url);
    NSString *body;
    NSString *contentType = [request.responseHeaders objectForKey:@"Content-Type"];
    if ([[contentType lowercaseString] rangeOfString:@"charset=utf-8"].location != NSNotFound) {
        body = request.responseString;
    } else {
        // gb2312 -> utf8
//        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//        NSData *rspData = request.responseData;
//        body = [[NSString alloc] initWithData:rspData encoding:enc];
        body = [SMUtils gb2312Data2String:request.responseData];
    }

//    XLog_d(@"%@",body);
    _webParser = [[SMWebParser alloc] init];
    _webParser.delegate = self;
    [_webParser parseHtml:body withJSFile:_parser];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    XLog_d(@"url[%@] fail [%@]", _url, request.error);
    _isDone = YES;
    
    SMMessage *error = [[SMMessage alloc] initWithCode:SMNetworkErrorCodeRequestFail message:@"网络请求超时"];
    [_delegate webLoaderOperationFail:self error:error];
}

#pragma mark - SMWebParserDelegate
- (void)webParser:(SMWebParser *)webParser result:(NSDictionary *)json
{
    _isDone = YES;

    _webParser = nil;
    if (self.isCancelled) {
    XLog_e(@"req cancel [%@]", _url);
        return;
    }
//    XLog_d(@"url[%@] parsed", _url);
//    XLog_d(@"%@", json);
    NSInteger code = [[json objectForKey:@"code"] integerValue];
    if (code == 0) {
        id rspData = [json objectForKey:@"data"];
        if (rspData != nil && ![rspData isKindOfClass:[NSNull class]]) {
            SMBaseData *tmp = [SMBaseData dataWithJSON:[json objectForKey:@"data"]];
            _data = tmp;
        } else {
            _data = nil;
        }
        [_delegate webLoaderOperationFinished:self];
    } else {
        SMMessage *error = [[SMMessage alloc] initWithCode:code message:[json objectForKey:@"message"]];
        [_delegate webLoaderOperationFail:self error:error];
    }
}

#pragma mark - debug
- (void)cancel
{
//    XLog_e(@"req cancel [%@]", _url);
    [super cancel];
    _delegate = nil;
    [_request clearDelegatesAndCancel];
}

- (void)dealloc
{
//    XLog_d(@"url[%@] dealloc", _url);
    [_request clearDelegatesAndCancel];
    _request = nil;
    _webParser = nil;
}

@end
