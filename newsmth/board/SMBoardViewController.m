//
//  SMBoardViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-13.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBoardViewController.h"
#import "XPullRefreshTableView.h"
#import "SMBoardCell.h"
#import "SMPostViewController.h"
#import "SMWritePostViewController.h"
#import "SMUserViewController.h"
#import "SMBoardViewTypeSelectorView.h"
#import "SMBoardSearchViewController.h"

@interface SMBoardViewController ()<UITableViewDelegate, UITableViewDataSource, XPullRefreshTableViewDelegate, SMWebLoaderOperationDelegate, SMBoardCellDelegate, SMBoardViewTypeSelectorViewDelegate>
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;

@property (strong, nonatomic) UIButton *buttonForTitleView;

@property (strong, nonatomic) SMWebLoaderOperation *boardOp;
@property (assign, nonatomic) int page;
@property (assign, nonatomic) int currentPage;  // 从www加载文章列表时，页码有后台数据决定

@property (strong, nonatomic) NSArray *posts;
@property (assign, nonatomic) BOOL showTop; // 用户主动触发显示置顶

@property (strong, nonatomic) SMBoardViewTypeSelectorView *viewTypeSelector;
@property (strong, nonatomic) UIView *viewForMasker;
@property (assign, nonatomic) BOOL isViewTypeSelectorVisiable;

@end

@implementation SMBoardViewController

- (void)dealloc
{
    [_boardOp cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.title = _board.cnName;
    [self makeupViewTypeSelector];
    [self makeupTitleView];
    
    _tableView.xdelegate = self;
    [_tableView beginRefreshing];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(writePost)];
    
    [SMConfig addBoardToHistory:_board];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath) {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)setupTheme
{
    [super setupTheme];
    [_buttonForTitleView setTitleColor:[SMTheme colorForPrimary] forState:UIControlStateNormal];
}

- (void)makeupViewTypeSelector
{
    _viewTypeSelector = [SMBoardViewTypeSelectorView new];
    _viewTypeSelector.delegate = self;
    CGRect frame = _viewTypeSelector.frame;
    frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = - frame.size.height;
    _viewTypeSelector.frame = frame;
    [self.view addSubview:_viewTypeSelector];
    
    // load saved view type
    SMBoardViewType viewType = SMBoardViewTypeTztSortByReply;
    NSString *defKey = [NSString stringWithFormat:@"user_def_view_type_%@", _board.name];
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:defKey];
    if (obj) {
        viewType = [obj integerValue];
    }

    _isViewTypeSelectorVisiable = NO;

    _viewTypeSelector.viewType = viewType;
    [_viewTypeSelector addTarget:self action:@selector(onViewTypeSelectorValueChanged) forControlEvents:UIControlEventValueChanged];
    
    // add masker
    _viewForMasker = [[UIView alloc] initWithFrame:self.view.bounds];
    _viewForMasker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _viewForMasker.backgroundColor = SMRGBA(0, 0, 0, 0.2);
    [self.view insertSubview:_viewForMasker belowSubview:_viewTypeSelector];
    _viewForMasker.hidden = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewForMaskerTap)];
    [_viewForMasker addGestureRecognizer:tapGesture];
}

- (void)makeupTitleView
{
    UIButton *button = [UIButton buttonWithType:[SMUtils systemVersion] >= 7 ? UIButtonTypeSystem : UIButtonTypeCustom];
    [button addTarget:self action:@selector(onTitleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:_board.cnName forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    button.titleLabel.lineBreakMode = NSLineBreakByClipping;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    if ([button.titleLabel respondsToSelector:@selector(setMinimumScaleFactor:)]) {
        button.titleLabel.minimumScaleFactor = 0.6f;
    } else {
        button.titleLabel.minimumFontSize = 12.0f;
    }

    [button setImage:[UIImage imageNamed:@"icon_top"] forState:UIControlStateNormal];
    [button sizeToFit];

    self.navigationItem.titleView = button;
    _buttonForTitleView = button;
    // relayout after title render.
    [self performSelector:@selector(layoutTitleView) withObject:nil afterDelay:0];
}

- (void)layoutTitleView
{
    UIButton *button = _buttonForTitleView;
    CGSize titleSize = button.titleLabel.frame.size;
    CGSize imageSize = button.imageView.bounds.size;
    CGFloat padding = 3.0f;
    
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -imageSize.width, 0, imageSize.width)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, titleSize.width + padding, 0, -titleSize.width - padding)];
}

- (void)showViewTypeSelector
{
    _isViewTypeSelectorVisiable = YES;
    CGRect frame = _viewTypeSelector.frame;
    frame.origin.y = 64;
    _viewForMasker.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _viewTypeSelector.frame = frame;
    }];
}

- (void)hideViewTypeSelector
{
    if (_isViewTypeSelectorVisiable) {
        _viewForMasker.hidden = YES;
        
        CGRect frame = _viewTypeSelector.frame;
        frame.origin.y = -frame.size.height;
        [UIView animateWithDuration:0.2 animations:^{
            _viewTypeSelector.frame = frame;
        }];
    }
    _isViewTypeSelectorVisiable = NO;
}

- (void)onViewTypeSelectorValueChanged
{
    _showTop = NO;
    [_tableView beginRefreshing];
    [self hideViewTypeSelector];
}

- (void)onTitleButtonClick
{
    if (_isViewTypeSelectorVisiable) {
        [self hideViewTypeSelector];
    } else {
        [self showViewTypeSelector];
    }
}

- (void)onViewForMaskerTap
{
    [self hideViewTypeSelector];
}

- (void)setPosts:(NSArray *)posts
{
    _posts = posts;
    [self.tableView reloadData];
}

- (void)loadData:(BOOL)more
{
    if (!more) {
        _page = 1;
        [SMUtils trackEventWithCategory:@"board" action:@"refresh" label:_board.name];
    } else {
        ++_page;
        [SMUtils trackEventWithCategory:@"board" action:@"loadmore" label:[NSString stringWithFormat:@"%@:%d", _board.name, _page]];
    }
    NSString *url;
    if (_viewTypeSelector.viewType == SMBoardViewTypeTztSortByReply) {
        url = [NSString stringWithFormat:@"http://m.newsmth.net/board/%@?p=%d", _board.name, _page];
    } else if (_viewTypeSelector.viewType == SMBoardViewTypeNormal) {
        url = [NSString stringWithFormat:@"http://m.newsmth.net/board/%@/0?p=%d", _board.name, _page];
    } else {
        url = [NSString stringWithFormat:@"http://www.newsmth.net/bbsdoc.php?board=%@&ftype=6", _board.name];
        if (more) {
            url = [NSString stringWithFormat:@"%@&page=%d", url, _currentPage - 1];
        }
    }
    
    [_boardOp cancel];
    _boardOp = [[SMWebLoaderOperation alloc] init];
    _boardOp.delegate = self;
    [_boardOp loadUrl:url withParser:@"board,util_notice"];
    
}

- (void)writePost
{
    [self hideViewTypeSelector];
    
    if (![SMAccountManager instance].isLogin) {
        [self performSelectorAfterLogin:@selector(writePost)];
        return ;
    }
    SMWritePostViewController *writeViewController = [[SMWritePostViewController alloc] init];
    SMPost *newPost = [[SMPost alloc] init];
    newPost.board = _board;
    newPost.pid = 0;
    writeViewController.post = newPost;
    writeViewController.title = [NSString stringWithFormat:@"发表-%@", _board.cnName];
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:writeViewController];
    [self.navigationController presentModalViewController:nvc animated:YES];
    
    [SMUtils trackEventWithCategory:@"board" action:@"write" label:_board.name];
}

#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData:NO];
}

- (void)tableViewDoRetry:(XPullRefreshTableView *)tableView
{
    [self.tableView setLoadMoreShow];
    [self loadData:YES];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMPost *post = _posts[indexPath.row];
    if (post.isTop && [SMConfig disableShowTopPost] && !_showTop) {
        return 10;
    }
    
    return [SMBoardCell cellHeight:_posts[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"postcell";
    SMBoardCell *cell = (SMBoardCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SMBoardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.post = _posts[indexPath.row];
    cell.delegate = self;
    
    if (indexPath.row == _posts.count - 1) {
        [self loadData:YES];
        [_tableView setLoadMoreShow];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMPost *post = _posts[indexPath.row];
    
    // 点击置顶帖，展开显示
    if (post.isTop && [SMConfig disableShowTopPost] && !_showTop) {
        _showTop = YES;
        [self.tableView reloadData];
        [SMUtils trackEventWithCategory:@"board" action:@"expand_top" label:_board.name];
        return ;
    }
 
    SMPostViewController *vc = [[SMPostViewController alloc] init];
    if (_viewTypeSelector.viewType == SMBoardViewTypeTztSortByReply
        || _viewTypeSelector.viewType == SMBoardViewTypeTztSortByPost) {
        vc.gid = post.gid;
        vc.board = _board;
    } else {
        vc.postUrl = [NSString stringWithFormat:@"http://m.newsmth.net/article/%@/single/%d/0", _board.name, post.gid];
    }
    vc.fromBoard = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    [SMUtils trackEventWithCategory:@"board" action:@"view_post" label:_board.name];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [_tableView endRefreshing:YES];
    NSMutableArray *tmp;
    if (_page == 1) {
        tmp = [[NSMutableArray alloc] init];
    } else {
        tmp = [_posts mutableCopy];
    }
    
    SMBoard *board = opt.data;
    if (board.hasNotice) {
        [SMAccountManager instance].notice = board.notice;
    }
    [board.posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SMPost *post = obj;
//        if (post.isTop && [SMConfig disableShowTopPost]) {
//            return ;
//        }
        [tmp addObject:post];
    }];

    _currentPage = board.currentPage;
    
    self.posts = tmp;
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self toast:error.message];
    if (_page == 1) {
        [_tableView endRefreshing:NO];
    } else {
        [self.tableView setLoadMoreFail];
    }
}

#pragma mark - SMBoardCellDelegate
- (void)boardCellOnUserClick:(NSString *)username
{
    SMUserViewController *vc = [[SMUserViewController alloc] init];
    vc.username = username;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SMBoardViewTypeSelectorViewDelegate
- (void)boardViewTypeSelectorOnFavorButtonClick:(SMBoardViewTypeSelectorView *)v
{
    
}

- (void)boardViewTypeSelectorOnSearchButtonClick:(SMBoardViewTypeSelectorView *)v
{
    SMBoardSearchViewController *svc = [[SMBoardSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:svc animated:YES];
}

@end
