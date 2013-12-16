//
//  SMLoginViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMLoginViewController.h"
#import "UIButton+Custom.h"

@interface SMLoginViewController ()<SMWebLoaderOperationDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewFromContainer;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForPassword;

@property (weak, nonatomic) IBOutlet UIButton *buttonForCancel;
@property (weak, nonatomic) IBOutlet UIButton *buttonForSubmit;
@property (weak, nonatomic) IBOutlet UILabel *labelForRegHint;


@property (strong, nonatomic) SMWebLoaderOperation *loginOp;

@property (strong, nonatomic) id afterLoginTarget;
@property (assign, nonatomic) SEL afterLoginSelector;
@end

@implementation SMLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录";

    _textFieldForUsername.text = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_USERNAME];
    _textFieldForPassword.text = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_PASSWORD];
    
    // format textfield ui
    [@[_textFieldForUsername, _textFieldForPassword] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITextField *textField = obj;
        
        textField.background = [SMUtils stretchedImage:textField.background];
        
        UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
        textField.leftView = lv;
        textField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView *rv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
        textField.rightView = rv;
        textField.rightViewMode = UITextFieldViewModeAlways;
    }];
    
    [_buttonForCancel setButtonSMType:SMButtonTypeGray];
    [_buttonForSubmit setButtonSMType:SMButtonTypeBlue];
}

- (void)setupTheme
{
    [super setupTheme];
    _labelForRegHint.textColor = [SMTheme colorForSecondary];
    _textFieldForPassword.keyboardAppearance = _textFieldForUsername.keyboardAppearance = [SMConfig enableDayMode] ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark;
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
    NSString *username = [SMUtils encodeurl:_textFieldForUsername.text];
    NSString *password = [SMUtils encodeurl:_textFieldForPassword.text];
    
    NSString *postBody = [NSString stringWithFormat:@"id=%@&passwd=%@&save=on", username, password];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];

    [_loginOp cancel];
    _loginOp = [[SMWebLoaderOperation alloc] init];
    _loginOp.highPriority = YES;
    _loginOp.delegate = self;
    
    [self showLoading:@"正在登录..."];
    
    [_loginOp loadRequest:request withParser:@"login,util_notice"];
}

- (void)cancelLoading
{
    [super cancelLoading];
    [_loginOp cancel];
    _loginOp = nil;
}

- (IBAction)onCancelButtonClick:(id)sender
{
    [self dismiss];
}

- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [self hideLoading];
    if ([[SMAccountManager instance] isLogin]) {
        // save user & password
        [[NSUserDefaults standardUserDefaults] setObject:_textFieldForUsername.text forKey:USERDEFAULTS_USERNAME];
        [[NSUserDefaults standardUserDefaults] setObject:_textFieldForPassword.text forKey:USERDEFAULTS_PASSWORD];

        [SMUtils trackEventWithCategory:@"user" action:@"login" label:_textFieldForUsername.text];

        [self dismissViewControllerAnimated:YES completion:^{
            if (_afterLoginTarget != nil && _afterLoginSelector != NULL) {
                SuppressPerformSelectorLeakWarning([_afterLoginTarget performSelector:_afterLoginSelector]);
            }
        }];
        
    }
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self hideLoading];
    [self toast:error.message];
}

#pragma mark - keyboard
- (void)onKeyboardDidShow:(NSNotification *)n
{
    [super onKeyboardDidShow:n];
    [self fitLoginFrame];
}

- (void)onKeyboardDidHide:(NSNotification *)n
{
    [super onKeyboardDidHide:n];
    [self fitLoginFrame];
}

- (void)fitLoginFrame
{
    [UIView animateWithDuration:0.1f animations:^{
        _viewFromContainer.center = CGPointMake(self.view.frame.size.width / 2.0f, (self.view.frame.size.height - self.keyboardHeight + SM_TOP_INSET) / 2.0f);
    }];
}



@end
