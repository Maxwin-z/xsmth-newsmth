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

@interface SMBoardViewController ()<UITableViewDelegate, UITableViewDataSource, XPullRefreshTableViewDelegate, SMWebLoaderOperationDelegate, SMBoardCellDelegate>
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;

@property (strong, nonatomic) SMWebLoaderOperation *boardOp;
@property (assign, nonatomic) int page;

@property (strong, nonatomic) NSArray *posts;
@end

@implementation SMBoardViewController

- (void)dealloc
{
    [_boardOp cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _board.cnName;
    
    _tableView.xdelegate = self;
    [_tableView beginRefreshing];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(writePost)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath) {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
    NSString *url = [NSString stringWithFormat:@"http://m.newsmth.net/board/%@?p=%d", _board.name, _page];
    
    [_boardOp cancel];
    _boardOp = [[SMWebLoaderOperation alloc] init];
    _boardOp.delegate = self;
    [_boardOp loadUrl:url withParser:@"board"];
    
}

- (void)writePost
{
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
 
    SMPostViewController *vc = [[SMPostViewController alloc] init];
    vc.gid = post.gid;
    vc.board = _board;
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
    [board.posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SMPost *post = obj;
        if (post.isTop && [SMConfig disableShowTopPost]) {
            return ;
        }
        [tmp addObject:post];
    }];
//    [tmp addObjectsFromArray:board.posts];

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

@end
