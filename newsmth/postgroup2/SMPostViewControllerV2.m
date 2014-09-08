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
#import "PBWebViewController.h"
#import "XImageView.h"
#import "XImageViewCache.h"

//#define DEBUG_HOST @"10.128.100.175"
#define DEBUG_HOST @"192.168.3.161"


@interface SMPostViewControllerV2 () <UIWebViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableDictionary *imageLoaders;

@property (strong, nonatomic) NSMutableArray *posts;
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger totalPage;
@end

@implementation SMPostViewControllerV2

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.posts = [NSMutableArray new];
    self.title = self.post.title;
    self.imageLoaders = [NSMutableDictionary new];
    [self setupWebView];
}

- (void)setupTheme
{
    [super setupTheme];
}

- (void)onThemeChangedNotification:(NSNotification *)n
{
    [super onThemeChangedNotification:n];
    [self sendThemeChangedMessage];
}

- (void)setupWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    
    // remove webview background color
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    if (![SMUtils systemVersion] < 7) {
        UIWebView *webView = self.webView;
        for (UIView *view in [[webView subviews].firstObject subviews]) {
            if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
        }
    }
    
    
    UIScrollView *scrollView = self.webView.scrollView;
    UIEdgeInsets insets = scrollView.contentInset;
    insets.top = SM_TOP_INSET;
    scrollView.contentInset = scrollView.scrollIndicatorInsets = insets;
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;

    // add refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [scrollView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(onRefreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    // debug
//    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/xsmth/"]];
//    NSURL *url = [NSURL URLWithString:@"http://" DEBUG_HOST @"/xsmth/index.html"];
//    NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];

    NSString *documentPath = [SMUtils documentPath];
    NSString *postPagePath = [NSString stringWithFormat:@"%@/post/index.html", documentPath];
    NSURL *url = [NSURL fileURLWithPath:postPagePath];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
//    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://" DEBUG_HOST @"/xsmth/"]];
//    [self.webView loadRequest:req];
    
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

- (void)dealloc
{
    XLog_d(@"%@", self.posts);
    XLog_d(@"%d", self.currentPage);
    XLog_d(@"%d", self.totalPage);
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    
    XLog_d(@"load: %@", url);
    
    if ([url.host isEqualToString:@"_"]) {
        NSDictionary *query = [self parseQuery:url.query];
        [self handleJSAPI:query];
        return NO;
    }
    
    return YES;
    
    
    if ([url.host isEqualToString:@"localhost"] || [url.host isEqualToString:DEBUG_HOST] || [url.absoluteString isEqualToString:@"about:blank"]) {
        return YES;
    }
    
    PBWebViewController *vc = [[PBWebViewController alloc] init];
    vc.URL = url;
    [self.navigationController pushViewController:vc animated:YES];
    return NO;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打开", nil];
    [sheet.rac_buttonClickedSignal subscribeNext:^(id x) {
        NSInteger buttonIndex = [x integerValue];
        XLog_d(@"%d", buttonIndex);
    }];
    [sheet showInView:self.view];
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self sendThemeChangedMessage];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self sendScrollToBottomEvent:scrollView];
}

- (void)sendScrollToBottomEvent:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"window.SMApp.scrollToBottom()"];
    }
}

#pragma mark - Native method for webview

- (void)sendThemeChangedMessage
{
    NSString *js = [NSString stringWithFormat:@"window.onThemeChanged(%@)", [SMUtils json2string:[self makeupThemeCSS]]];
//    [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js afterDelay:0];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

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
    
    if ([method isEqualToString:@"getImageInfo"]) {
        [self apiGetImageInfo:parameters];
    }
    
    if ([method isEqualToString:@"savePostsInfo"]) {
        [self apiSavePostsInfo:parameters];
    }
}

- (void)sendMessage2WebViewWithCallbackID:(NSString *)callbackID value:(id)value
{
    NSString *str = [SMUtils json2string:value];
    NSString *js = [NSString stringWithFormat:@"window.SMApp.callback(%@, %@)", callbackID, str];
    
    [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js];
//    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)apiAjax:(NSDictionary *)parameters
{
    SMHttpRequest *req;
    NSString *url = parameters[@"url"];
    XLog_d(@"load url: %@", url);
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
        XLog_d(@"resp length: %@", @(responseString.length));
        if (responseString == nil) {
//            XLog_d(@"%@", req.responseData);
            XLog_e(@"get response string error. parse from data");
            responseString = [SMUtils gb2312Data2String:req.responseData];
        }
        [self sendMessage2WebViewWithCallbackID:parameters[@"callbackID"] value:@{@"response": responseString ?: @""}];
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

- (void)apiGetImageInfo:(NSDictionary *)parameters
{
    NSString *imageUrl = parameters[@"url"];
    XImageView *imageView = [[XImageView alloc] init];
//    imageView.autoLoad = NO;
    @weakify(self);
    imageView.getSizeBlock = ^(long long size) {
        @strongify(self);
        XLog_d(@"url:%@, %@", imageUrl, @(size));
        [self sendMessage2WebViewWithCallbackID:parameters[@"callbackID"] value:@{@"size": @(size)}];
    };
    
    imageView.didLoadBlock = ^() {
        NSString *path = [[XImageViewCache sharedInstance] pathForUrl:imageUrl];
        XLog_d(@"url: %@ success, %@", imageUrl, path);
        [self sendMessage2WebViewWithCallbackID:parameters[@"callbackID"] value:@{@"success": path}];
    };
    imageView.didFailBlock = ^() {
        [self sendMessage2WebViewWithCallbackID:parameters[@"callbackID"] value:@{@"fail": @""}];
    };
    
    __block CGFloat latestProgress = 0.0f;
    imageView.updateProgressBlock = ^(CGFloat progress) {
        XLog_d(@"progress: %@", @(progress));
        if (progress - latestProgress > 0.08) {
            [self sendMessage2WebViewWithCallbackID:parameters[@"callbackID"] value:@{@"progress": @(progress)}];
            latestProgress = progress;
            XLog_d(@"update progres %@", @(progress));
        }
    };
    
    imageView.url = imageUrl;
    [self.imageLoaders setObject:imageView forKey:imageUrl];
}

- (void)apiSavePostsInfo:(NSDictionary *)parameters
{
    NSArray *posts = parameters[@"posts"];
    [self mergePosts:posts];
    self.currentPage = [parameters[@"currentPage"] integerValue];
    self.totalPage = [parameters[@"totalPage"] integerValue];
}

#pragma mark - method
- (void)mergePosts:(NSArray *)posts
{
    NSInteger lastPid = 0;
    SMPost *post = self.posts.lastObject;
    if (post) {
        lastPid = post.pid;
    }
    @weakify(self);
    [posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        SMPost *post = (SMPost *)[SMPost dataWithJSON:obj];
        if (post.pid > lastPid) {
            [self.posts addObject:post];
        }
    }];
}

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

- (NSDictionary *)makeupThemeCSS
{
    UIFont *font = [SMConfig postFont];
    
    NSString *fontSize = [NSString stringWithFormat:@"%dpx", (int)(font.pointSize * 2)];
    NSString *fontFamily = font.fontName;
    NSString *lineHeight = [NSString stringWithFormat:@"%dpx", (int)(font.lineHeight * 1.2 * 2)];
    NSString *backgroundColor = [self color2hex:[SMTheme colorForBackground]];
    NSString *textColor = [self color2hex:[SMTheme colorForPrimary]];
    NSString *tintColor = [self color2hex:[SMTheme colorForTintColor]];
    NSString *quoteColor = [self color2hex:[SMTheme colorForQuote]];
    
    return @{@"fontSize": fontSize,
             @"fontFamily": fontFamily,
             @"lineHeight": lineHeight,
             @"backgroundColor": backgroundColor,
             @"textColor": textColor,
             @"tintColor": tintColor,
             @"quoteColor": quoteColor
             };
}

- (NSString *)color2hex:(UIColor *)color
{
    CGFloat rf, gf, bf, af;
    [color getRed:&rf green:&gf blue: &bf alpha: &af];
    
    int r = (int)(255.0 * rf);
    int g = (int)(255.0 * gf);
    int b = (int)(255.0 * bf);
    
    return [NSString stringWithFormat:@"#%02x%02x%02x",r,g,b];
}

@end
