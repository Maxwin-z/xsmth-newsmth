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

@property (strong, nonatomic) SMHttpRequest *request;
@property (strong, nonatomic) SMWebParser *webParser;

@end

@implementation SMWebLoaderOperation
- (void)loadUrl:(NSString *)url withParser:(NSString *)parser
{
    _url = url;
    _parser = parser;
    [[SMWebLoaderOperationQueue sharedInstance] addOperation:self];
}

- (void)loadRequest:(SMHttpRequest *)request withParser:(NSString *)parser
{
    _request = request;
    _parser = parser;
    [[SMWebLoaderOperationQueue sharedInstance] addOperation:self];
}

- (void)main
{
    if (self.isCancelled) {
        XLog_d(@"opt is cancelled");
        return;
    }
    if (_url == nil && _request == nil) {
        XLog_e(@"request url is nil");
        return;
    }
    

    if (_request == nil) {
        NSURL *url = [NSURL URLWithString:_url];
        _request = [[SMHttpRequest alloc] initWithURL:url];
    }
    
    _url = _request.url.absoluteString;
    _request.delegate = self;
    
    XLog_d(@"url[%@] start", _url);
    [_request startSynchronous];
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
    if ([contentType rangeOfString:@"charset=utf-8"].location != NSNotFound) {
        body = request.responseString;
    } else {
        // gb2312 -> utf8
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *rspData = request.responseData;
        body = [[NSString alloc] initWithData:rspData encoding:enc];
    }

//    XLog_d(@"%@",body);
    _webParser = [[SMWebParser alloc] init];
    _webParser.delegate = self;
    [_webParser parseHtml:body withJSFile:_parser];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    XLog_d(@"url[%@] fail", _url);
    SMMessage *error = [[SMMessage alloc] initWithCode:SMNetworkErrorCodeRequestFail message:@"网络请求超时"];
    [_delegate webLoaderOperationFail:self error:error];
}

#pragma mark - SMWebParserDelegate
- (void)webParser:(SMWebParser *)webParser result:(NSDictionary *)json
{
    if (self.isCancelled) {
        return;
    }
    XLog_d(@"url[%@] parsed", _url);
    NSInteger code = [[json objectForKey:@"code"] integerValue];
    if (code == 0) {
        SMBaseData *tmp = [[SMBaseData alloc] initWithData:[json objectForKey:@"data"]];
        _data = tmp;
        [_delegate webLoaderOperationFinished:self];
    } else {
        SMMessage *error = [[SMMessage alloc] initWithCode:code message:[json objectForKey:@"message"]];
        [_delegate webLoaderOperationFail:self error:error];
    }
}

#pragma mark - debug
- (void)cancel
{
    XLog_e(@"req cancel");
    [super cancel];
    [_request clearDelegatesAndCancel];
}

- (void)dealloc
{
    XLog_d(@"url[%@] dealloc", _url);
    [_request clearDelegatesAndCancel];
    _request = nil;
    _webParser = nil;
}

@end
