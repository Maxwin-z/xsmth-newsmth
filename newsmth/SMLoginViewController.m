//
//  SMLoginViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMLoginViewController.h"

@interface SMLoginViewController ()<SMWebLoaderOperationDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFieldForUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForPassword;

@property (strong, nonatomic) SMWebLoaderOperation *loginOp;
@end

@implementation SMLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
}

- (void)dismiss
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)onLoginButtonClick:(id)sender
{
    SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:@"http://m.newsmth.net/user/login"]];
    NSString *postBody = [NSString stringWithFormat:@"id=%@&passwd=%@", _textFieldForUsername.text, _textFieldForPassword.text];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];

    _loginOp = [[SMWebLoaderOperation alloc] init];
    _loginOp.delegate = self;
    [_loginOp loadRequest:request withParser:@"login"];
}

- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    if ([[SMAccountManager instance] isLogin]) {
        [self dismiss];
    }
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self toast:error.message];
}


@end
