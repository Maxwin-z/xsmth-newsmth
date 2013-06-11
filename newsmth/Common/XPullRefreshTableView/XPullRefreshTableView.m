//
//  XPullRefreshTableView.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "XPullRefreshTableView.h"

#define ANIMATION_DURATION  0.1f
#define REFRESH_TRIGGER_HEIGHT  60.0f

@interface XPullRefreshTableView ()<UITableViewDelegate>
@property (weak, nonatomic) id<UITableViewDelegate> originalDelegate;

#pragma refresh header
@property (strong, nonatomic) IBOutlet UIView *viewForRefreshHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForArrow;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorForRefresh;
@property (weak, nonatomic) IBOutlet UILabel *labelForRefreshHint;
@property (weak, nonatomic) IBOutlet UILabel *labelForRefreshDate;

#pragma load more footer
@property (strong, nonatomic) IBOutlet UIView *viewForLoadingMore;
@property (strong, nonatomic) IBOutlet UIView *viewForLoadMoreFail;

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

#pragma mark - public
- (void)beginRefreshing
{
    [_xdelegate tableViewDoRefresh:self];
    _imageViewForArrow.hidden = YES;
    _activityIndicatorForRefresh.hidden = NO;
    if (!self.isDragging) {
        UIEdgeInsets inset = self.contentInset;
        inset.top = REFRESH_TRIGGER_HEIGHT;
        self.contentInset = inset;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            self.contentOffset = CGPointMake(0, -self.contentInset.top);
        }];
    }

}

- (void)endRefreshing:(BOOL)success
{
    UIEdgeInsets insets = self.contentInset;
    insets.top = 0;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.contentInset = insets;
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
    if (scrollView.contentOffset.y < -REFRESH_TRIGGER_HEIGHT) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            _imageViewForArrow.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        }];
    } else {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            _imageViewForArrow.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
        }];
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -REFRESH_TRIGGER_HEIGHT) {
        [self beginRefreshing];
    }
}

@end
