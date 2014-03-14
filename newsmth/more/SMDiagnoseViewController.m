//
//  SMDiagnoseViewController.m
//  newsmth
//
//  Created by Maxwin on 14-3-14.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMDiagnoseViewController.h"

@interface SMDiagnoseViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation SMDiagnoseViewController

+ (void)diagnose:(NSString *)url rootViewController:(UIViewController *)vc
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"似乎有些问题" message:@"xsmth以抓取水木网页的方式工作，当前页面似乎不太正常，是否打开诊断页面确认下？" delegate:self cancelButtonTitle:@"不用了" otherButtonTitles:@"确认下", nil];
    @weakify(alertView);
    [alertView.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
        @strongify(alertView);
        if (buttonIndex.integerValue != alertView.cancelButtonIndex) {
            SMDiagnoseViewController *dvc = [[SMDiagnoseViewController alloc] initWithNibName:@"SMDiagnoseViewController" bundle:nil];
            dvc.url = url;
            P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:dvc];
            [vc presentModalViewController:nvc animated:YES];
        }
    }];
    [alertView show];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"功能诊断";
    self.webView.scrollView.contentInset = self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(100, 0, 44, 0);
    
    [self loadUrl];
}

- (void)setUrl:(NSString *)url
{
    _url = url;
    [self loadUrl];
}

- (void)loadUrl
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    self.textField.text = self.url;
}

- (IBAction)onLeftBarButtonClick:(id)sender
{
    [SMUtils trackEventWithCategory:@"diagnose" action:@"smth_down" label:self.url];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onRightBarButtonClick:(id)sender
{
    [SMUtils trackEventWithCategory:@"diagnose" action:@"smth_ok" label:self.url];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *url = textField.text;
    if (url.length > 0) {
        self.url = url;
    }
    return YES;
}

@end
