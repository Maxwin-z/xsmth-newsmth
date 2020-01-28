//
//  SMPostViewControllerV3.m
//  newsmth
//
//  Created by WenDong on 2020/1/28.
//  Copyright © 2020 nju. All rights reserved.
//

#import "SMPostViewControllerV3.h"
#import <WebKit/WebKit.h>

@interface SMPostViewControllerV3 ()
@property (strong, nonatomic) WKWebView *webView;
@end

@implementation SMPostViewControllerV3

- (void)viewDidLoad {
    [super viewDidLoad];
    XLog_d(@"%@", self.post);
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    
//    NSString *urlString = [NSString stringWithFormat:@"http://m.newsmth.net/article/FamilyLife/%@", @(self.post.gid)];
    NSString *urlString = @"http://10.0.0.11:3000/";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:request];
}

@end
