//
//  XPullRefreshTableView.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "XPullRefreshTableView.h"
#import "UIButton+Custom.h"

#define ANIMATION_DURATION  0.1f
#define NAVIGATION_HEIGHT   64.0f
#define REFRESH_TRIGGER_HEIGHT  (60.0f + NAVIGATION_HEIGHT)

@interface XPullRefreshTableView ()<UITableViewDelegate>
@property (weak, nonatomic) id<UITableViewDelegate> originalDelegate;

@property (assign, nonatomic) BOOL isRefreshing;

#pragma refresh header
@property (strong, nonatomic) IBOutlet UIView *viewForRefreshHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForArrow;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorForRefresh;
@property (weak, nonatomic) IBOutlet UILabel *labelForRefreshHint;
@property (weak, nonatomic) IBOutlet UILabel *labelForRefreshDate;

#pragma load more footer
@property (strong, nonatomic) IBOutlet UIView *viewForLoadingMore;
@property (strong, nonatomic) IBOutlet UIView *viewForLoadMoreFail;
@property (weak, nonatomic) IBOutlet UIButton *buttonForRetry;

@end

@implementation XPullRefreshTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    [super setDelegate:self];
    [[NSBundle mainBundle] loadNibNamed:@"XPullRefreshTableViewHeader" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"XPullRefreshTableViewFooter" owner:self options:nil];
    _viewForRefreshHeader.frame = CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    [_buttonForRetry setButtonSMType:SMButtonTypeGray];
    [self addSubview:_viewForRefreshHeader];
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    _originalDelegate = delegate;
}

#pragma mark - methods
- (void)resetRefreshHeader
{
    _imageViewForArrow.hidden = NO;
    _activityIndicatorForRefresh.hidden = YES;
    _imageViewForArrow.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
}

- (void)setLastUpdated:(NSDate *)lastUpdated
{
    _lastUpdated = lastUpdated;
    if (_lastUpdated) {
        _labelForRefreshDate.text = [NSString stringWithFormat:@"上次更新:%@", [SMUtils formatDate:_lastUpdated]];
    }
}

- (IBAction)onRetryButtonClick:(id)sender
{
    if ([_xdelegate respondsToSelector:@selector(tableViewDoRetry:)]) {
        [_xdelegate tableViewDoRetry:self];
    }
}

#pragma mark - public
- (void)beginRefreshing
{
    _isRefreshing = YES;
    
    [_xdelegate tableViewDoRefresh:self];
    _imageViewForArrow.hidden = YES;
    _activityIndicatorForRefresh.hidden = NO;
    if (!self.isDragging) {
        UIEdgeInsets inset = self.contentInset;
        inset.top = REFRESH_TRIGGER_HEIGHT + NAVIGATION_HEIGHT;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.contentInset = inset;
            self.scrollIndicatorInsets = inset;
            self.contentOffset = CGPointMake(0, -self.contentInset.top);
        }];
    }

}

- (void)endRefreshing:(BOOL)success
{
    _isRefreshing = NO;
    
    UIEdgeInsets insets = self.contentInset;
    insets.top = NAVIGATION_HEIGHT;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.contentInset = insets;
        self.scrollIndicatorInsets = insets;
    } completion:^(BOOL finished) {
        [self resetRefreshHeader];
    }];
    if (success) {
        self.lastUpdated = [[NSDate alloc] init];
    }
}

- (void)setLoadMoreShow
{
    self.tableFooterView = _viewForLoadingMore;
}

- (void)setLoadMoreHide
{
    self.tableFooterView = nil;
}

- (void)setLoadMoreFail
{
    self.tableFooterView = _viewForLoadMoreFail;
}

#pragma mark - Method forward
- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [_originalDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _originalDelegate;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_originalDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_originalDelegate scrollViewDidScroll:scrollView];
    }
    if (_isRefreshing) {
        return ;
    }
    XLog_d(@"%f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -REFRESH_TRIGGER_HEIGHT) {
        _labelForRefreshHint.text = @"释放立即刷新";
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            _imageViewForArrow.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        }];
    } else {
        _labelForRefreshHint.text = @"下拉刷新";
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            _imageViewForArrow.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
        }];
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_originalDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_originalDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (_isRefreshing) {
        return ;
    }
    
    if (scrollView.contentOffset.y < -REFRESH_TRIGGER_HEIGHT) {
        _labelForRefreshHint.text = @"正在载入...";
        [self beginRefreshing];
    }
}

@end
