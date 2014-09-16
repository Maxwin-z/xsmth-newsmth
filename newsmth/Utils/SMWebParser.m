//
//  SMWebParser.m
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMWebParser.h"

@interface SMWebParser ()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString *html;
@end

@implementation SMWebParser

- (id)init
{
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _webView.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    _webView.delegate = nil;
    _webView = nil;
//    XLog_v(@"%s", __PRETTY_FUNCTION__);
}

- (void)parseHtml:(NSString *)html withJSFile:(NSString *)jsFile
{
    _html = html;
    
    NSMutableArray *files = [[jsFile componentsSeparatedByString:@","] mutableCopy];
    [files addObject:@"utils"];
    NSMutableString *js = [[NSMutableString alloc] init];
    [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *file = obj;
        file = [file stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        NSString *content = [self loadJS:file];
        if (content) {
            [js appendString:content];
        }
    }];
    
    NSString *body = [NSString stringWithFormat:@"<html><script>%@</script><body>hello</body></html>", js];
    [_webView loadHTMLString:body baseURL:nil];
}

- (NSString *)loadJS:(NSString *)filename
{
    NSData *data = [SMUtils readDataFromDocumentFolder:[NSString stringWithFormat:@"parser/%@.js", filename]];
    
    if (data == nil) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"js"];
        if (!filePath) return @"";
        data = [NSData dataWithContentsOfFile:filePath];
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)escape:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    html = [html stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return html;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    XLog_d(@"%@", request.URL.absoluteString);
    NSString *url = request.URL.absoluteString;
    if ([url hasPrefix:SM_DATA_SCHEMA]) {
        NSString *result = [url substringFromIndex:SM_DATA_SCHEMA.length];
        result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error != nil) {
            XLog_d(@"result: %@", result);
            XLog_e(@"parse result error:%@", error);
        }
//        XLog_d(@"%@", json);
        if ([_delegate respondsToSelector:@selector(webParser:result:)]) {
            [_delegate webParser:self result:json];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *js = [NSString stringWithFormat:@"try{$parse(\"%@\")}catch(e){window.location.href='newsmth://_?'+encodeURIComponent(JSON.stringify({code:-2,message:e.toString()}))}", [self escape:_html]];
//    XLog_d(@"execute: %@", js);
    [_webView stringByEvaluatingJavaScriptFromString:js];
}



@end
