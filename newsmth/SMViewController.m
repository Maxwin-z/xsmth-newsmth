//
//  SMViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import "SMLoginViewController.h"
#import "UIButton+Custom.h"

@interface SMViewController ()
@property (assign, nonatomic) SEL selectorAfterLogin;

@property (strong, nonatomic) IBOutlet UIView *viewForPopover;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForPopoverBg;
@property (weak, nonatomic) IBOutlet UILabel *labelForPoperoverMessage;

@property (strong, nonatomic) IBOutlet UIView *viewForLoadingPopover;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForLoadingLeftBg;
@property (weak, nonatomic) IBOutlet UILabel *labelForLoadingMessage;

@property (strong, nonatomic) IBOutlet UIView *viewForLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonForLogin;
@property (weak, nonatomic) IBOutlet UILabel *labelForLoginHint;

@end

@implementation SMViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.trackedViewName = NSStringFromClass([self class]);
    
    self.view.backgroundColor = [SMTheme colorForBackground];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        self.navigationController.navigationBar.translucent = YES;
        self.wantsFullScreenLayout = YES;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _labelForLoginHint.textColor = [SMTheme colorForPrimary];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toast:(NSString *)message
{
    UIView *window = [UIApplication sharedApplication].keyWindow;
    if (_viewForPopover == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SMViewControllerPopover" owner:self options:nil];
        _imageViewForPopoverBg.image = [_imageViewForPopoverBg.image stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    }
    CGRect frame = window.bounds;
    frame.size.height -= _keyboardHeight;
    _viewForPopover.frame = frame;
    [window addSubview:_viewForPopover];
    
    _labelForPoperoverMessage.text = message;
    [self performSelector:@selector(hideToast) withObject:nil afterDelay:TOAST_DURTAION];
}

- (void)hideToast
{
    [_viewForPopover removeFromSuperview];
}

- (void)showLoading:(NSString *)message
{
    UIView *window = [UIApplication sharedApplication].keyWindow;
    if (_viewForLoadingPopover == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SMViewControllerPopover" owner:self options:nil];
        _imageViewForLoadingLeftBg.image = [_imageViewForLoadingLeftBg.image stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    }
    
    _labelForLoadingMessage.text = message;
    
    CGRect frame = window.bounds;
    frame.size.height -= _keyboardHeight;
    _viewForLoadingPopover.frame = frame;
    [window addSubview:_viewForLoadingPopover];

}

- (void)hideLoading
{
    [_viewForLoadingPopover removeFromSuperview];
}

- (void)cancelLoading
{
    // do sth
}

- (IBAction)onCancelLoadingButtonClick:(id)sender
{
    [self hideLoading];
    [self cancelLoading];
}

- (void)showLogin
{
    if (_viewForLogin == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SMViewControllerNeedLogin" owner:self options:nil];
        [_buttonForLogin setButtonSMType:SMButtonTypeGray];
    }
    _viewForLogin.frame = self.view.bounds;
    [self.view addSubview:_viewForLogin];
}

- (void)hideLogin
{
    [_viewForLogin removeFromSuperview];
}

- (void)performSelectorAfterLogin:(SEL)aSelector
{
    SMLoginViewController *loginVc = [[SMLoginViewController alloc] init];
    [loginVc setAfterLoginTarget:self selector:aSelector];
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:loginVc];
    [self presentModalViewController:nvc animated:YES];
}

- (IBAction)onLoginButtonClick:(id)sender
{
    [self performSelectorAfterLogin:NULL];
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onKeyboardDidShow:(NSNotification *)n
{
    NSDictionary* info = [n userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _keyboardHeight = kbSize.height;
}

- (void)onKeyboardDidHide:(NSNotification *)n
{
    _keyboardHeight = 0.0f;
}

@end
