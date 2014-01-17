//
//  SMEULAViewController.m
//  newsmth
//
//  Created by Maxwin on 14-1-17.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMEULAViewController.h"

@interface SMEULAViewController ()

@end

@implementation SMEULAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"最终用户许可协议";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    
    webView.scrollView.contentInset = webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(SM_TOP_INSET, 0, 0, 0);
    webView.backgroundColor = [UIColor whiteColor];
    
    NSString *url = @"http://maxwin.me/xsmth/eula.html";
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    if (!self.hideAgreeButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"同意" style:UIBarButtonItemStylePlain target:self action:@selector(onRightBarButtonItemClick)];
    }
}

- (void)onRightBarButtonItemClick
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_EULA_ACCEPTED];
    [self dismissModalViewControllerAnimated:YES];
}

@end
