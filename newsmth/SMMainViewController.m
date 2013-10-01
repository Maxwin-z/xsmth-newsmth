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

#define LEFT_SIZE   270.0f
#define ANIMATION_DURATION  0.5f

typedef enum {
    DragDirectionLeft,
    DragDirectionRight
}DragDirection;

static SMMainViewController *_instance;

@interface SMMainViewController ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) SMLeftViewController *leftViewController;
@property (strong, nonatomic) P2PNavigationController *centerViewController;
@property (assign, nonatomic) BOOL isDragging;
@property (strong, nonatomic) UIView *viewForCenterMasker;
@property (assign, nonatomic) CGFloat leftPanX;
@property (assign, nonatomic) DragDirection dragDirection;
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
    }
    return _instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _leftViewController = [[SMLeftViewController alloc] init];
    _leftViewController.view.frame = self.view.bounds;
    _leftViewController.view.hidden = YES;
    [self.view addSubview:_leftViewController.view];
        
    _centerViewController = [[P2PNavigationController alloc] init];
    _centerViewController.view.frame = self.view.bounds;
    [self.view addSubview:_centerViewController.view];

    SMMainpageViewController *mainpageViewController = [[SMMainpageViewController alloc] init];
    [self setRootViewController:mainpageViewController];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onViewPanGesture:)];
    panGesture.delegate = self;
    [_centerViewController.view addGestureRecognizer:panGesture];
}

- (void)onLeftBarButtonClick
{
    // debug
    // http://m.newsmth.net/refer/reply/read?index=204
//    NSString *url = @"http://m.newsmth.net/refer/reply/read?index=204";
//    SMPostViewController *vc = [[SMPostViewController alloc] init];
//    vc.postUrl = url;
//    [self setRootViewController:vc];
    [self setLeftVisiable:YES];
}

- (void)setRootViewController:(UIViewController *)viewController
{
    [_centerViewController popToRootViewControllerAnimated:NO];
    _centerViewController.toolbarHidden = YES;
    _centerViewController.viewControllers = @[viewController];
    viewController.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"]
                                         style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(onLeftBarButtonClick)];
}


- (void)setLeftVisiable:(BOOL)visiable
{
    _leftViewController.view.hidden = NO;
    _leftViewController.view.userInteractionEnabled = NO;

    CGFloat endX = visiable ? LEFT_SIZE : 0;
    CGFloat length = _centerViewController.view.frame.origin.x - endX;
    CGFloat duration = ANIMATION_DURATION * fabsf(length) / LEFT_SIZE;
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
            frame.origin.x = LEFT_SIZE;
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
    if (fabsf(pan.x) > fabsf(pan.y) && self.centerViewController.viewControllers.count <= 1) {
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
