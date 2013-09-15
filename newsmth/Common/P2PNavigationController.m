//
//  P2PNavigationController.m
//  P2PNavigationController
//
//  Created by Maxwin on 13-6-22.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "P2PNavigationController.h"
#import "P2PViewController.h"

#import <QuartzCore/QuartzCore.h>

#define ANIMATION_DURATION  0.5f

#define BACK_IMAGE_SCALE  0.96f
#define BACK_MASKER_ALPHA 0.7f

#define ENABLE_P2P  [self enableP2P]



@interface P2PNavigationController ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) UIImageView *backImageView;
@property (strong, nonatomic) UIView *backMaskerView;

@property (assign, nonatomic) CGFloat lastPanX;
@end

@implementation P2PNavigationController

- (BOOL)enableP2P
{
    return [[[UIDevice currentDevice] systemVersion] integerValue] < 7;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (ENABLE_P2P) {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.autoresizingMask = self.view.autoresizingMask;
        
        _backMaskerView = [[UIView alloc] init];
        _backMaskerView.autoresizingMask = self.view.autoresizingMask;
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
        _panGesture.delegate = self;
        [self.view addGestureRecognizer:_panGesture];
        
        // add left shadow
        UIView *shadowView = [[UIView alloc] init];
        CGFloat shadowWidth = -3.0f;
        shadowView.frame = CGRectMake(0, 0, shadowWidth, self.view.frame.size.height);
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        shadowView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"left_shadow"]];
        [self.view addSubview:shadowView];
        
        // add bottom black view
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:backgroundView atIndex:0];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (ENABLE_P2P) {
        _backImageView.frame = self.view.frame;
        _backMaskerView.frame = self.view.frame;
        _backImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        _backMaskerView.backgroundColor = [UIColor clearColor];
        
        UIView *superview = self.view.superview;
        [superview insertSubview:_backImageView belowSubview:self.view];
        [superview insertSubview:_backMaskerView belowSubview:self.view];
        
        _backImageView.hidden = YES;
        _backMaskerView.hidden = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (ENABLE_P2P) {
        _backImageView.frame = self.view.frame;
        _backMaskerView.frame = self.view.frame;
        _backImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        _backMaskerView.backgroundColor = [UIColor clearColor];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (ENABLE_P2P) {
        UIImage *image = [self captureView:self.view];
        [self setBackImage:image];
        P2PViewController *topVc = (P2PViewController *)self.topViewController;
        topVc.captureImage = image;
        
        [super pushViewController:viewController animated:NO];
        
        // animation, self.view is viewController now
        if (self.viewControllers.count > 1) {
            // set initial status
            CGRect frame = self.view.frame;
            frame.origin.x = frame.size.width - 100;
            self.view.frame = frame;
            
            _backImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
            _backMaskerView.backgroundColor = [UIColor clearColor];
            
            _backImageView.hidden = NO;
            _backMaskerView.hidden = NO;
            
            [self panToPop:NO];
        }
    } else {
        return [super pushViewController:viewController animated:YES];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (ENABLE_P2P) {
        P2PViewController *topVc = [self.viewControllers lastObject];
        if ([topVc respondsToSelector:@selector(navigationUnsupportPanToPop)] && [topVc navigationUnsupportPanToPop]) {
            return [super popViewControllerAnimated:YES];
        }
        
        P2PViewController *vc = self.viewControllers[self.viewControllers.count  - 2];
        [self setBackImage:vc.captureImage];
        
        _backImageView.hidden = NO;
        _backMaskerView.hidden = NO;
        
        
        [self panToPop:YES];
        return [self.viewControllers lastObject];
    } else {
        return [super popViewControllerAnimated:YES];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_panGesture == gestureRecognizer) {
        CGPoint pan = [gestureRecognizer translationInView:self.view];
        BOOL begin = fabsf(pan.x) > fabsf(pan.y) && (self.viewControllers.count > 1);
        
        P2PViewController *topVc = [self.viewControllers lastObject];
        if ([topVc respondsToSelector:@selector(navigationUnsupportPanToPop)]) {
            begin &= ![topVc navigationUnsupportPanToPop];
        }
        
        if (begin) {
            _lastPanX = pan.x;
            P2PViewController *vc = self.viewControllers[self.viewControllers.count  - 2];
            [self setBackImage:vc.captureImage];
            
            _backImageView.hidden = NO;
            _backMaskerView.hidden = NO;
        }
        return begin;
    }
    return YES;
}

- (void)onPanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint pan = [gesture translationInView:self.view];
    CGFloat delta = pan.x - _lastPanX;
    _lastPanX = pan.x;
    
    CGRect frame = self.view.frame;
    frame.origin.x += delta;
    frame.origin.x = MAX(frame.origin.x, 0);
    self.view.frame = frame;
    
    CGFloat totalWidth = self.view.bounds.size.width;
    CGFloat currentX = frame.origin.x;
    
    CGFloat scale = 1 - (totalWidth - currentX) * (1 - BACK_IMAGE_SCALE) / totalWidth;
    _backImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    CGFloat alpha = 1 - (totalWidth - currentX) * (1 - BACK_MASKER_ALPHA) / totalWidth;
    _backMaskerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - alpha];
    
    // end gesture
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateCancelled
        || gesture.state == UIGestureRecognizerStateFailed) {
        CGFloat velocity = [gesture velocityInView:self.view].x;
        if (velocity < -500.0f || (fabsf(velocity) < 500 && currentX < totalWidth / 2.0f)) {
            [self panToPop:NO];
        } else {
            [self panToPop:YES];
        }
    }
}

- (void)panToPop:(BOOL)pop
{
    CGFloat totalWidth = self.view.bounds.size.width;
    CGFloat currentX = self.view.frame.origin.x;
    
    CGFloat scale = 1 - (totalWidth - currentX) * (1 - BACK_IMAGE_SCALE) / totalWidth;
    _backImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    CGFloat alpha = 1 - (totalWidth - currentX) * (1 - BACK_MASKER_ALPHA) / totalWidth;
    _backMaskerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - alpha];
    
    CGFloat endX = pop ? totalWidth : 0;
    CGFloat duration = ANIMATION_DURATION * fabs(currentX - endX) / totalWidth;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x = endX;
        self.view.frame = frame;
        
        CGFloat scale = pop ? 1.0f : BACK_IMAGE_SCALE;
        _backImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
        CGFloat alpha = pop ? 1.0f : BACK_MASKER_ALPHA;
        _backMaskerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - alpha];
    } completion:^(BOOL finished) {
        if (pop) {
            CGRect frame = self.view.frame;
            frame.origin.x = 0;
            self.view.frame = frame;
            
            [super popViewControllerAnimated:NO];
            if (self.viewControllers.count <= 1) {
                _backImageView.hidden = YES;
                _backMaskerView.hidden = YES;
            }
        }
    }];
}

- (UIImage *)captureView:(UIView *)view
{
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setBackImage:(UIImage *)image
{
    _backImageView.image = image;
}

@end
