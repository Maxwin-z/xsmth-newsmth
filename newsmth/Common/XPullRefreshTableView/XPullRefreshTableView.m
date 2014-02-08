//
//  XPullRefreshTableView.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "XPullRefreshTableView.h"
#import "UIButton+Custom.h"
#import "XTimeLabel.h"

#define ANIMATION_DURATION  0.1f
#define NAVIGATION_HEIGHT   64.0f
#define REFRESH_TRIGGER_HEIGHT  (60.0f + NAVIGATION_HEIGHT)

@interface XPullRefreshTableView ()<UITableViewDelegate>
@property (weak, nonatomic) id<UITableViewDelegate> originalDelegate;

@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL isLoadingMore;

#pragma refresh header
@property (strong, nonatomic) IBOutlet UIView *viewForRefreshHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForArrow;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorForRefresh;
@property (weak, nonatomic) IBOutlet UILabel *labelForRefreshHint;
@property (weak, nonatomic) IBOutlet XTimeLabel *labelForRefreshDate;

#pragma load more footer
@property (strong, nonatomic) IBOutlet UIView *viewForLoadingMore;
@property (strong, nonatomic) IBOutlet UIView *viewForLoadMoreFail;
@property (strong, nonatomic) IBOutlet UIView *viewForLoadPull;
@property (strong, nonatomic) IBOutlet UIView *viewForLoadMoreNormal;
@property (weak, nonatomic) IBOutlet UILabel *labelForPullHint;
@property (weak, nonatomic) IBOutlet UIButton *buttonForRetry;
@property (weak, nonatomic) IBOutlet XTimeLabel *labelForLoadMoreHint;
@property (weak, nonatomic) IBOutlet UILabel *labelForLoadingMoreLoading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorForLoadMore;

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
    [super setDelegate:self];
    [[NSBundle mainBundle] loadNibNamed:@"XPullRefreshTableViewHeader" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"XPullRefreshTableViewFooter" owner:self options:nil];
    _viewForRefreshHeader.frame = CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    _viewForRefreshHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_buttonForRetry setButtonSMType:SMButtonTypeGray];
    [self addSubview:_viewForRefreshHeader];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTheme) name:NOTIFYCATION_THEME_CHANGED object:nil];
    
    [self setupTheme];
}

- (void)setupTheme
{
    _labelForLoadMoreHint.textColor = _labelForPullHint.textColor = _labelForRefreshDate.textColor = _labelForRefreshHint.textColor = _labelForLoadingMoreLoading.textColor = [SMTheme colorForSecondary];
    _activityIndicatorForRefresh.activityIndicatorViewStyle = _activityIndicatorForLoadMore.activityIndicatorViewStyle = [SMConfig enableDayMode] ? UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhite;
    if ([_activityIndicatorForRefresh respondsToSelector:@selector(setTintColor:)]) {
        _activityIndicatorForRefresh.tintColor = [SMTheme colorForTintColor];
    }
    if ([_imageViewForArrow.image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        _imageViewForArrow.image = [_imageViewForArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    if ([_imageViewForArrow respondsToSelector:@selector(setTintColor:)]) {
        [_imageViewForArrow setTintColor:[SMTheme colorForTintColor]];
    }
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
    _viewForRefreshHeader.hidden = YES;
}

- (void)setLastUpdated:(NSDate *)lastUpdated
{
    _lastUpdated = lastUpdated;
    if (_lastUpdated) {
        _labelForRefreshDate.beginTime = lastUpdated;
        _labelForRefreshDate.formatter = @"上次更新:%@";
//        _labelForRefreshDate.text = [NSString stringWithFormat:@"上次更新:%@", [SMUtils formatDate:_lastUpdated]];
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
    _viewForRefreshHeader.hidden = NO;
    if (!self.isDragging) {
        UIEdgeInsets inset = self.contentInset;
        inset.top = REFRESH_TRIGGER_HEIGHT; // + NAVIGATION_HEIGHT;
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

- (void)beginLoadMore
{
    [self setLoadPullHide];
    [self setLoadMoreShow];
    if ([_xdelegate respondsToSelector:@selector(tableViewDoLoadMore:)]) {
        [_xdelegate tableViewDoLoadMore:self];
        _isLoadingMore = YES;
    }
}

- (void)setLoadMoreShow
{
    [self setLoadPullHide];
    self.tableFooterView = _viewForLoadingMore;
    _isLoadingMore = NO;
}

- (void)setLoadMoreHide
{
    self.tableFooterView = _viewForLoadMoreNormal;
    _labelForLoadMoreHint.formatter = @"更新时间：%@";
    _labelForLoadMoreHint.beginTime = [[NSDate alloc] init];
    _isLoadingMore = NO;
    [self setLoadPullShow];
}

- (void)setLoadMoreFail
{
    [self setLoadPullHide];
    self.tableFooterView = _viewForLoadMoreFail;
    _isLoadingMore = NO;
}

- (void)setLoadPullShow
{
    if (_enablePullLoad) {
        CGRect frame = _viewForLoadPull.frame;
        frame.origin.y = self.bounds.size.height - SM_TOP_INSET;
        if (self.contentSize.height > self.bounds.size.height) {
            frame.origin.y = self.contentSize.height;
        }
        
        _viewForLoadPull.frame = frame;
        _viewForLoadPull.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_viewForLoadPull];
    }
}

- (void)setLoadPullHide
{
    if (_enablePullLoad) {
        [_viewForLoadPull removeFromSuperview];
    }
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
    if (_isRefreshing || _isLoadingMore) {
        return ;
    }
//    XLog_d(@"%f", scrollView.contentOffset.y);
    _viewForRefreshHeader.hidden = scrollView.contentOffset.y > -NAVIGATION_HEIGHT - 1;
    
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

    if (!_enablePullLoad) {
        return ;
    }
    
    CGFloat bottom = scrollView.contentOffset.y + scrollView.bounds.size.height;
    CGFloat height = scrollView.contentSize.height;
    if (scrollView.bounds.size.height > height) {   // 不满屏
        height = scrollView.bounds.size.height;
        bottom += SM_TOP_INSET;
    }
    
//    XLog_d(@"%f, %f", bottom, height);
    [self setLoadPullShow];
    
    if (bottom > height) {
        _labelForPullHint.text = @"上拉载入更多";
    }
    
    if (bottom > height + _viewForLoadPull.frame.size.height) {
        _labelForPullHint.text = @"释放立即加载";
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_originalDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_originalDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (_isRefreshing || _isLoadingMore) {
        return ;
    }
    
    if (scrollView.contentOffset.y < -REFRESH_TRIGGER_HEIGHT) {
        _labelForRefreshHint.text = @"正在载入...";
        [self beginRefreshing];
    } else {
        [self resetRefreshHeader];
    }
    
    if (!_enablePullLoad) {
        return ;
    }
    
    CGFloat bottom = scrollView.contentOffset.y + scrollView.bounds.size.height;
    CGFloat height = scrollView.contentSize.height;
    if (scrollView.bounds.size.height > height) {   // 不满屏
        height = scrollView.bounds.size.height;
        bottom += SM_TOP_INSET;
    }
    
    if (bottom > height + _viewForLoadPull.frame.size.height) {
        // trgger load more
        [self beginLoadMore];
    }
}

@end
