//
//  XPullRefreshTableView.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "XPullRefreshTableView.h"
#import "EGORefreshTableHeaderView.h"

@interface XPullRefreshTableView ()<UITableViewDelegate, EGORefreshTableHeaderDelegate>
@property (weak, nonatomic) id<UITableViewDelegate> originalDelegate;
@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
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
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:_refreshHeaderView];
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    _refreshHeaderView.state = EGOOPullRefreshNormal;
    _refreshHeaderView.delegate = self;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    _originalDelegate = delegate;
}

#pragma mark - methods
- (void)beginRefreshing
{
    [_xdelegate tableViewDoRefresh:self];
}

- (void)endRefreshing:(BOOL)success
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
    if (success) {
        self.lastUpdated = [[NSDate alloc] init];
    }
}

- (void)setLoadMoreShow
{
    
}

- (void)setLoadMoreHide
{
    
}

- (void)setLoadMoreFail
{
    
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
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self beginRefreshing];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _refreshHeaderView.state == EGOOPullRefreshLoading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return _lastUpdated;
}

@end
