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
    [self _baseClassCommonInit];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self _baseClassCommonInit];
    return self;
}

- (void)_baseClassCommonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChangedNotification:) name:NOTIFYCATION_THEME_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = NSStringFromClass([self class]);
    
    self.currentOrientation = [UIDevice currentDevice].orientation;

    self.overrideUserInterfaceStyle = [SMConfig enableDayMode] ? UIUserInterfaceStyleLight : UIUserInterfaceStyleDark;
    [self setupTheme];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
//    self.contentInsetAdjustmentBehavior = NO;
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

    // fixme
    CGFloat angle = 0;
    CGRect frame = window.bounds;

    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    if (o == UIDeviceOrientationUnknown) {
        o = (UIDeviceOrientation) [[UIApplication sharedApplication] statusBarOrientation];
    }

    if (o == UIDeviceOrientationLandscapeLeft) {
        angle = M_PI_2;
        frame.origin.x = _keyboardHeight;
        frame.size.width -= _keyboardHeight;
    }
    if (o == UIDeviceOrientationLandscapeRight){
        angle = -M_PI_2;
        frame.size.width -= _keyboardHeight;
    }
    if (o == UIDeviceOrientationPortrait) {
        frame.size.height -= _keyboardHeight;
    }

    _viewForPopover.transform = CGAffineTransformMakeRotation(angle);
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
    
    CGFloat angle = 0;
    CGRect frame = window.bounds;
    
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    if (o == UIDeviceOrientationUnknown) {
        o = (UIDeviceOrientation) [[UIApplication sharedApplication] statusBarOrientation];
    }
    
    if (o == UIDeviceOrientationLandscapeLeft) {
        angle = M_PI_2;
        frame.origin.x = _keyboardHeight;
        frame.size.width -= _keyboardHeight;
    }
    if (o == UIDeviceOrientationLandscapeRight){
        angle = -M_PI_2;
        frame.size.width -= _keyboardHeight;
    }
    if (o == UIDeviceOrientationPortrait) {
        frame.size.height -= _keyboardHeight;
    }
    
    _viewForLoadingPopover.transform = CGAffineTransformMakeRotation(angle);
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
    if ([SMAccountManager instance].isLogin) {
        [self performSelector:aSelector withObject:nil afterDelay:0];
    } else {
        SMLoginViewController *loginVc = [[SMLoginViewController alloc] init];
        [loginVc setAfterLoginTarget:self selector:aSelector];
        P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:loginVc];
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

- (void)afterLoginSuccess:(void(^)())success fail:(void(^)())fail
{
    if ([SMAccountManager instance].isLogin) {
        success();
    } else {
        SMLoginViewController *loginVc = [SMLoginViewController new];
        [loginVc loginWithSuccess:success fail:fail];
        P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:loginVc];
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nvc animated:YES completion:nil];
    }
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
    if ([SMUtils isPad] && [SMUtils systemVersion] < 8) {
        _keyboardHeight = [SMUtils isPortrait] ? kbSize.height : kbSize.width;
    } else {
        _keyboardHeight = kbSize.height;
    }
}

- (void)onKeyboardDidHide:(NSNotification *)n
{
    _keyboardHeight = 0.0f;
}

- (void)onThemeChangedNotification:(NSNotification *)n
{
    [self setupTheme];
}

- (void)onDeviceOrientationNotification:(NSNotification *)n
{
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
//    XLog_d(@"%@ - %@", @(self.currentOrientation), @(o));
    if ([SMUtils isPad]
        && o != UIDeviceOrientationUnknown
        && o != UIDeviceOrientationPortraitUpsideDown
        && o != UIDeviceOrientationFaceUp
        && o != UIDeviceOrientationFaceDown
        && o != self.currentOrientation) {
        self.currentOrientation = o;
        [self onDeviceRotate];
    }
}

- (void)onDeviceRotate
{
    
}

- (void)setupTheme
{
    self.view.backgroundColor = [SMTheme colorForBackground];
    _labelForLoginHint.textColor = _labelForLoadingMessage.textColor = _labelForPoperoverMessage.textColor = [SMTheme colorForPrimary];
    
    // fixme. tableview
    if ([self respondsToSelector:@selector(tableView)]) {
        UITableView *tableView = [self performSelector:@selector(tableView)];
        if ([tableView isKindOfClass:[UITableView class]]) {
            tableView.backgroundColor = [SMTheme colorForBackground];
            tableView.backgroundView = nil;
            [tableView reloadData];
        }
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIWindow *keyWindow = nil;
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow) {
            keyWindow = w;
            break;
        }
    }
    if (keyWindow) {
        keyWindow.tintColor = [SMTheme colorForTintColor];
        keyWindow.overrideUserInterfaceStyle = [SMConfig enableDayMode] ? UIUserInterfaceStyleLight : UIUserInterfaceStyleDark;
    }

    self.navigationController.navigationBar.barTintColor = [SMTheme colorForBarTintColor];
    [UINavigationBar appearance].barTintColor = [SMTheme colorForBarTintColor];

    [self.navigationController.navigationBar setTintColor:[SMTheme colorForTintColor]];
    [UINavigationBar appearance].tintColor = [SMTheme colorForTintColor];

    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = UIColor.clearColor;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{
         NSForegroundColorAttributeName: [SMTheme colorForPrimary],
         NSShadowAttributeName: shadow
     }];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

// ios9 3d touch


//- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
//{
//    UIViewController *vc = [UIViewController new];
//    vc.view.backgroundColor = [UIColor redColor];
//    return vc;
//}
//
//- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
//{
//    [self showViewController:viewControllerToCommit sender:self];
//}
@end
