//
//  SMMainViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-11.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMainViewController.h"
#import "SMLeftViewController.h"
#import "SMMainpageViewController.h"
#import <QuartzCore/CALayer.h>

#import "SMImagePickerViewController.h"
#import "SMPostViewController.h"
#import "SMEULAViewController.h"
#import "SMIPadSplitViewController.h"

#import "XImageViewCache.h"
#import "SMCryptoUtil.h"

//#define LEFT_SIZE   270.0f
#define RIGHTBAR_WIDTH 50.0f
#define ANIMATION_DURATION  0.5f

typedef enum {
    DragDirectionLeft,
    DragDirectionRight
}DragDirection;

static SMMainViewController *_instance;

@interface SMMainViewController ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) SMLeftViewController *leftViewController;
@property (assign, nonatomic) BOOL isDragging;
@property (strong, nonatomic) UIView *viewForCenterMasker;
@property (assign, nonatomic) CGFloat leftPanX;
@property (assign, nonatomic) DragDirection dragDirection;

@property (strong, nonatomic) UIBarButtonItem *menuBarButtonItem;
@property (strong, nonatomic) UIImageView *badgeView;
@end

@implementation SMMainViewController

+ (SMMainViewController *)instance
{
    if (_instance == nil) {
        _instance = [[SMMainViewController alloc] init];
    }
    return _instance;
}

- (id)init
{
    if (_instance == nil) {
        _instance = [super init];
        [self makeupMenuBarButtonItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoticeNofitication) name:NOTIFICATION_NOTICE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAccountNotification) name:NOTIFICATION_ACCOUT object:nil];

    }
    return _instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _leftViewController = [[SMLeftViewController alloc] init];
    _leftViewController.view.frame = self.view.bounds;
    _leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _leftViewController.view.hidden = YES;
    [self.view addSubview:_leftViewController.view];
        
    _centerViewController = [[P2PNavigationController alloc] init];
    _centerViewController.view.frame = self.view.bounds;
    [self.view addSubview:_centerViewController.view];
    [self addChildViewController:_centerViewController];

    SMMainpageViewController *mainpageViewController = [[SMMainpageViewController alloc] init];
    [self setRootViewController:mainpageViewController];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onViewPanGesture:)];
    panGesture.delegate = self;
    [_centerViewController.view addGestureRecognizer:panGesture];
    
    self.view.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showEndUserLicenseAgreements];
    if ([SMConfig enableForceLogin] && ![SMAccountManager instance].isLogin) {
        [self performSelectorAfterLogin:nil];
    }
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return _centerViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return _centerViewController;
}

- (void)makeupMenuBarButtonItem
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"icon_menu"];
    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onLeftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = v.bounds;
    [v addSubview:btn];
    
    _badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge_notice"]];
    _badgeView.frame = CGRectMake(-1, 3, 10, 10);
    [v addSubview:_badgeView];
    _badgeView.hidden = YES;

    _menuBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:v];
}

- (void)onNoticeNofitication
{
    SMNotice *notice = [SMAccountManager instance].notice;
    SMNotice *latestNotice = [[SMNotice alloc] initWithJSON:[[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_NOTICE_LATEST]];
    if (notice.mail > latestNotice.mail || notice.at > latestNotice.at || notice.reply > latestNotice.reply) {
        [SMConfig resetFetchTime];
        [self setBadgeVisiable:YES];
    } else {
        [self setBadgeVisiable:NO];
    }
}

- (void)onAccountNotification
{
    if ([SMConfig enableForceLogin] && ![SMAccountManager instance].isLogin) {
        [self performSelectorAfterLogin:nil];
    }
}

- (void)onLeftBarButtonClick
{
    [self setLeftVisiable:YES];
    // debug
//    [self test];
}

- (void)test
{
    NSDictionary *json = @{@"code": @"100",
                           @"user": @"max",
                           @"product": @"me.maxwin.xsmth.donate1",
                           @"message": @"Hello!",
                           @"addtime": i2s((int)([NSDate timeIntervalSinceReferenceDate]))
                           };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSString *text = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *data = [SMCryptoUtil AES128Encrypt:text];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8081"]];
    [request setRequestMethod:@"POST"];
    [request setPostBody:[data mutableCopy]];
    [request startSynchronous];
    XLog_d(@"%@", request.responseString);
}

- (void)showEndUserLicenseAgreements
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_EULA_ACCEPTED]) {
        SMEULAViewController *vc = [SMEULAViewController new];
        P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:vc];
        
        if ([SMConfig iPadMode]) {
            [[SMIPadSplitViewController instance] presentModalViewController:nvc animated:YES];
        } else {
            [self presentViewController:nvc animated:YES completion:NULL];
        }
    }
}

- (void)setRootViewController:(UIViewController *)viewController
{
    [_centerViewController popToRootViewControllerAnimated:NO];
    _centerViewController.toolbarHidden = YES;
    _centerViewController.viewControllers = @[viewController];
    viewController.navigationItem.leftBarButtonItem = _menuBarButtonItem;
}

- (void)setBadgeVisiable:(BOOL)visiable
{
    _badgeView.hidden = !visiable;
}

- (void)setLeftVisiable:(BOOL)visiable
{
    _leftViewController.view.hidden = NO;
    _leftViewController.view.userInteractionEnabled = NO;

    CGFloat leftWidth = self.view.bounds.size.width - RIGHTBAR_WIDTH;
    CGFloat endX = visiable ? leftWidth : 0;
    CGFloat length = _centerViewController.view.frame.origin.x - endX;
    CGFloat duration = ANIMATION_DURATION * ABS(length) / leftWidth;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = _centerViewController.view.frame;
        frame.origin.x = endX;
        _centerViewController.view.frame = frame;
    } completion:^(BOOL finished) {
        _leftViewController.view.hidden = !visiable;
        _leftViewController.view.userInteractionEnabled = YES;
    }];
    
    if (visiable) {
        if (_viewForCenterMasker == nil) {
            CGRect frame = self.view.bounds;
            frame.origin.x = leftWidth;
            _viewForCenterMasker = [[UIView alloc] initWithFrame:frame];
            [self.view addSubview:_viewForCenterMasker];

            // add gesture
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMaskterTap:)];
            [_viewForCenterMasker addGestureRecognizer:tapGesture];
            
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onViewPanGesture:)];
            panGesture.delegate = self;
            [_viewForCenterMasker addGestureRecognizer:panGesture];
            
        }
        _viewForCenterMasker.hidden = NO;
        
        [_leftViewController loadNotice];
        
        [SMUtils trackEventWithCategory:@"main" action:@"show_left" label:nil];
    } else {
        _viewForCenterMasker.hidden = YES;
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint pan = [gestureRecognizer translationInView:self.view];
    if (ABS(pan.x) > ABS(pan.y) && pan.x > 0 && self.centerViewController.viewControllers.count <= 1) {
        _leftPanX = pan.x;
        _leftViewController.view.hidden = NO;
        return YES;
    }
    return NO;
}

- (void)onViewPanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint pan = [gesture translationInView:self.view];
    CGRect frame = _centerViewController.view.frame;
    CGFloat delta = pan.x - _leftPanX;
    _leftPanX = pan.x;
    
    if (delta != 0) {
        _dragDirection = delta > 0 ? DragDirectionRight : DragDirectionLeft;
    }
    
    frame.origin.x += delta;
    frame.origin.x = MAX(frame.origin.x, 0);
    _centerViewController.view.frame = frame;
    
    // end gesture
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateCancelled
        || gesture.state == UIGestureRecognizerStateFailed) {
        CGFloat velocity = [gesture velocityInView:self.view].x;
        if (_dragDirection == DragDirectionRight && (_centerViewController.view.frame.origin.x > self.view.bounds.size.width / 2.0f || velocity > 500)) {
            [self setLeftVisiable:YES];
        } else {
            [self setLeftVisiable:NO];
        }
    }    
}

- (void)onMaskterTap:(UITapGestureRecognizer *)gesture
{
    [self setLeftVisiable:NO];
}

@end
