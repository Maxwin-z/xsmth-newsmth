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

- (void)main
{
    if (self.isCancelled) {
        XLog_d(@"opt is cancelled");
        return;
    }
    if (_url == nil) {
        XLog_e(@"request url is nil");
        return;
    }
    XLog_d(@"url[%@] start", _url);

    NSURL *url = [NSURL URLWithString:_url];
    _request = [[SMHttpRequest alloc] initWithURL:url];
    _request.delegate = self;
    [_request startSynchronous];
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (self.isCancelled) {
        return;
    }

    XLog_d(@"url[%@] response", _url);
    // gb2312 -> utf8
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *rspData = request.responseData;
    NSString *body = [[NSString alloc] initWithData:rspData encoding:enc];

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
    _result = json;
    NSInteger code = [[json objectForKey:@"code"] integerValue];
    if (code == 0) {
        [_delegate webLoaderOperationFinished:self];
    } else {
        SMMessage *error = [[SMMessage alloc] initWithCode:code message:[json objectForKey:@"message"]];
        [_delegate webLoaderOperationFail:self error:error];
    }
}

#pragma mark - debug
- (void)dealloc
{
    XLog_d(@"url[%@] dealloc", _url);
}

@end
