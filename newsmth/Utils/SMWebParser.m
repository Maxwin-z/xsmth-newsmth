//
//  SMWebParser.m
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMWebParser.h"

@interface SMWebParser ()<UIWebViewDelegate>
@end

@implementation SMWebParser

- (id)init
{
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _webView.backgroundColor = [UIColor redColor];
        [[UIApplication sharedApplication].keyWindow addSubview:_webView];
        _webView.delegate = self;
    }
    return self;
}

- (void)parseHtml:(NSString *)html withJS:(NSString *)js
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:js ofType:@"js"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *parserJS = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *body = [NSString stringWithFormat:@"<html><script>%@</script><body>hello</body></html>", parserJS];
    [_webView loadHTMLString:body baseURL:nil];
//    _webView.window.
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    XLog_d(@"%@", request.URL.absoluteString);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    XLog_d(@"%s", __PRETTY_FUNCTION__);
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_webView stringByEvaluatingJavaScriptFromString:@"$parse()"];
    XLog_d(@"%s", __PRETTY_FUNCTION__);
}

@end
