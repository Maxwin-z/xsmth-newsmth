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

@property (strong, nonatomic) id afterLoginTarget;
@property (assign, nonatomic) SEL afterLoginSelector;
@end

@implementation SMLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
    _textFieldForUsername.text = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_USERNAME];
    _textFieldForPassword.text = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_PASSWORD];
}

- (void)dealloc
{
    [_loginOp cancel];
}

- (void)setAfterLoginTarget:(id)target selector:(SEL)aSelector
{
    _afterLoginTarget = target;
    _afterLoginSelector = aSelector;
}

- (void)dismiss
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)onLoginButtonClick:(id)sender
{
    SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:@"http://m.newsmth.net/user/login"]];
    NSString *postBody = [NSString stringWithFormat:@"id=%@&passwd=%@&save=on", _textFieldForUsername.text, _textFieldForPassword.text];
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
        // save user & password
        [[NSUserDefaults standardUserDefaults] setObject:_textFieldForUsername.text forKey:USERDEFAULTS_USERNAME];
        [[NSUserDefaults standardUserDefaults] setObject:_textFieldForPassword.text forKey:USERDEFAULTS_PASSWORD];
        [self dismiss];
        if (_afterLoginTarget) {
            SuppressPerformSelectorLeakWarning([_afterLoginTarget performSelector:_afterLoginSelector]);
        }
    }
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self toast:error.message];
}


@end
