//
//  SMPostViewControllerV2.m
//  newsmth
//
//  Created by Maxwin on 14-8-30.
//  Copyright (c) 2014年 nju. All rights reserved.
//

/**
 * use xsmth://_?[parameters] to proxy native method
 *
 */

#import "SMPostViewControllerV2.h"

@interface SMPostViewControllerV2 () <UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation SMPostViewControllerV2

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupWebView];
}

- (void)setupWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    if (![SMUtils systemVersion] < 7) {
        UIWebView *webView = self.webView;
        for (UIView *view in [[webView subviews].firstObject subviews]) {
            if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
        }
    }
    
    
    // add refresh control
    UIScrollView *scrollView = self.webView.scrollView;
    UIEdgeInsets insets = scrollView.contentInset;
    insets.top = SM_TOP_INSET;
    scrollView.contentInset = scrollView.scrollIndicatorInsets = insets;
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [scrollView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(onRefreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/xsmth/"]];
    [self.webView loadRequest:req];
    
    self.webView.delegate = self;
}

- (void)onRefreshControlValueChanged:(UIRefreshControl *)refreshControl
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.reload()"];
    [self performSelector:@selector(endRefresh) withObject:nil afterDelay:1];
}


- (void)beginRefresh
{
    [self.refreshControl beginRefreshing];
}

- (void)endRefresh
{
    [self.refreshControl endRefreshing];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if ([url.host isEqualToString:@"_"]) {
        NSDictionary *query = [self parseQuery:url.query];
        [self handleJSAPI:query];
        return NO;
    }
    return YES;
}

#pragma mark - Native method for webview

- (void)handleJSAPI:(NSDictionary *)query
{
    NSString *method = query[@"method"];
    NSDictionary *parameters = [SMUtils string2json:query[@"parameters"]];
    
    if ([method isEqualToString:@"ajax"]) {
        [self apiAjax:parameters];
    }
    
    if ([method isEqualToString:@"getPostInfo"]) {
        [self apiGetPostInfo:parameters];
    }
    
    if ([method isEqualToString:@"scrollTo"]) {
        [self apiScrollTo:parameters];
    }
}

- (void)sendMessage2WebViewWithCallbackID:(NSString *)callbackID value:(id)value
{
    NSString *str = [SMUtils json2string:value];
    NSString *js = [NSString stringWithFormat:@"window.SMApp.callback(%@, %@)", callbackID, str];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)apiAjax:(NSDictionary *)parameters
{
    SMHttpRequest *req;
    NSString *url = parameters[@"url"];
    req = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    if ([url hasPrefix:@"http://www.newsmth.net/nForum/"]) {
        [req addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    }
    
    @weakify(req);
    @weakify(self);
    [req setCompletionBlock:^{
        @strongify(req);
        @strongify(self);
        NSString *responseString = req.responseString;
        XLog_d(@"resp: %@", responseString);
        [self sendMessage2WebViewWithCallbackID:parameters[@"callbackID"] value:@{@"response": responseString}];
    }];
    
    [req setFailedBlock:^{
        @strongify(req);
        @strongify(self);
        XLog_e(@"req error: %@", req.error);
        [self sendMessage2WebViewWithCallbackID:parameters[@"callbackID"] value:@{@"error": req.error.userInfo}];
    }];
    
    [req startAsynchronous];
}

- (void)apiGetPostInfo:(NSDictionary *)parameters
{
    [self sendMessage2WebViewWithCallbackID:parameters[@"callbackID"] value:self.post.encode];
}

- (void)apiScrollTo:(NSDictionary *)parameters
{
    UIScrollView *scrollView = self.webView.scrollView;
    CGFloat pos = [parameters[@"pos"] floatValue] / 2.0f;
    pos = MAX(pos, 0);
    pos = MIN(pos, scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.top);
    pos -= scrollView.contentInset.top;
    [scrollView setContentOffset:CGPointMake(0, pos) animated:YES];
}

#pragma mark - method
- (NSDictionary *)parseQuery:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
		
		if ([elements count] <= 1) {
			continue;
		}
		
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    
    return dict;
}
@end
