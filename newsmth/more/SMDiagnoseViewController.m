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
    SMDiagnoseViewController *dvc = [[SMDiagnoseViewController alloc] initWithNibName:@"SMDiagnoseViewController" bundle:nil];
    dvc.url = url;
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:dvc];
    [vc presentModalViewController:nvc animated:YES];
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
    self.webView.scrollView.contentInset = self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(70, 0, 44, 0);
    
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
