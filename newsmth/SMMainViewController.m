//
//  SMMainViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-11.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMainViewController.h"
#import "SMLeftViewController.h"
#import "SMNavigationController.h"
#import "SMMainpageViewController.h"
#import <QuartzCore/CALayer.h>

#define LEFT_SIZE   270.0f
#define ANIMATION_DURATION  0.5f
#define TOPIMAGE_SCALE  0.96f
#define TOPMASKER_ALPHA 0.7f

typedef enum {
    DragDirectionLeft,
    DragDirectionRight
}DragDirection;

static SMMainViewController *_instance;

@interface SMMainViewController ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) SMLeftViewController *leftViewController;
@property (strong, nonatomic) SMNavigationController *centerViewController;
@property (strong, nonatomic) UIImageView *imageViewForTopImage;
@property (strong, nonatomic) UIView *viewForTopMasker;
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
    _leftViewController = [[SMLeftViewController alloc] init];
    _leftViewController.view.frame = self.view.bounds;
    [self.view addSubview:_leftViewController.view];
    
    _imageViewForTopImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageViewForTopImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_imageViewForTopImage];
    
    _viewForTopMasker = [[UIView alloc] initWithFrame:self.view.bounds];
    _viewForTopMasker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_viewForTopMasker];
    
    SMMainpageViewController *mainpageViewController = [[SMMainpageViewController alloc] init];
    _centerViewController = [[SMNavigationController alloc] initWithRootViewController:mainpageViewController];
    _centerViewController.view.frame = self.view.bounds;
    [self.view addSubview:_centerViewController.view];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onViewPanGesture:)];
    panGesture.delegate = self;
    [_centerViewController.view addGestureRecognizer:panGesture];
}

- (void)setRootViewController:(UIViewController *)viewController
{
    [_centerViewController popToRootViewControllerAnimated:NO];
    _centerViewController.viewControllers = @[viewController];
}

- (void)showPushAnimation
{
    _imageViewForTopImage.hidden = NO;
    _viewForTopMasker.hidden = NO;
    _leftViewController.view.hidden = YES;
    
    CGRect frame = _centerViewController.view.frame;
    frame.origin.x = self.view.bounds.size.width;
    _centerViewController.view.frame = frame;
    [self panToPop:NO];
}

- (void)popCenterViewController
{
    [self panToPop:YES];
}

- (void)setLeftVisiable:(BOOL)visiable
{
    CGFloat endX = visiable ? LEFT_SIZE : 0;
    CGFloat length = _centerViewController.view.frame.origin.x - endX;
    CGFloat duration = ANIMATION_DURATION * fabsf(length) / LEFT_SIZE;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = _centerViewController.view.frame;
        frame.origin.x = endX;
        _centerViewController.view.frame = frame;
    }];
    
    if (visiable) {
        if (_viewForCenterMasker == nil) {
            CGRect frame = self.view.bounds;
            frame.origin.x = LEFT_SIZE;
            _viewForCenterMasker = [[UIView alloc] initWithFrame:frame];
            [self.view addSubview:_viewForCenterMasker];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMaskterTap:)];
            [_viewForCenterMasker addGestureRecognizer:tapGesture];
        }
        _viewForCenterMasker.hidden = NO;
    } else {
        _viewForCenterMasker.hidden = YES;
    }
}

- (void)panToPop:(BOOL)pop
{
    CGFloat endX = pop ? self.view.bounds.size.width : 0;
    CGFloat length = _centerViewController.view.frame.origin.x - endX;
    CGFloat duration = ANIMATION_DURATION * fabs(length) / self.view.bounds.size.width;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = _centerViewController.view.frame;
        frame.origin.x = endX;
        _centerViewController.view.frame = frame;
        
        CGFloat scale = pop ? 1.0f : TOPIMAGE_SCALE;
        _imageViewForTopImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
        CGFloat alpha = pop ? 1.0f : TOPMASKER_ALPHA;
        _viewForTopMasker.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - alpha];
    } completion:^(BOOL finished) {
        if (pop) {
            [_centerViewController _realPop];
            CGRect frame = _centerViewController.view.frame;
            frame.origin.x = 0;
            _centerViewController.view.frame = frame;
        }
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint pan = [gestureRecognizer translationInView:self.view];
    if (fabsf(pan.x) > fabsf(pan.y)) {
        _leftPanX = pan.x;
        _isDragging = YES;
        
        if (_centerViewController.viewControllers.count > 1) {
            _imageViewForTopImage.hidden = NO;
            _viewForTopMasker.hidden = NO;
            _leftViewController.view.hidden = YES;
        } else {
            _imageViewForTopImage.hidden = YES;
            _viewForTopMasker.hidden = YES;
            _leftViewController.view.hidden = NO;
        }
        
        return YES;
    }
    return NO;
}

- (void)onViewPanGesture:(UIPanGestureRecognizer *)gesture
{
    if (_centerViewController.viewControllers.count > 1) {
        [self panToPopGesture:gesture];
    } else {
        [self panMainViewGesture:gesture];
    }
}

- (void)panToPopGesture:(UIPanGestureRecognizer *)gesture
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
    
    CGFloat scale = 1 - (self.view.frame.size.width - frame.origin.x) * (1 - TOPIMAGE_SCALE) / self.view.frame.size.width;
    _imageViewForTopImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    CGFloat alpha = 1 - (self.view.frame.size.width - frame.origin.x) * (1 - TOPMASKER_ALPHA) / self.view.frame.size.width;
    _viewForTopMasker.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - alpha];
    
    // end gesture
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateCancelled
        || gesture.state == UIGestureRecognizerStateFailed) {
        CGFloat velocity = [gesture velocityInView:self.view].x;
        if (_dragDirection == DragDirectionRight && (_centerViewController.view.frame.origin.x > self.view.bounds.size.width / 2.0f || velocity > 500)) {
            [self panToPop:YES];
        } else {
            [self panToPop:NO];
        }
    }
}

- (void)panMainViewGesture:(UIPanGestureRecognizer *)gesture
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

#pragma mark - 
- (void)setTopImage:(UIImage *)topImage
{
    _topImage = topImage;
    if (_centerViewController.viewControllers.count > 0) {
        _imageViewForTopImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        _imageViewForTopImage.image = topImage;
    } else {    // only root vc
        _imageViewForTopImage.image = nil;
    }
}

@end
