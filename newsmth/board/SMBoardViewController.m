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
#import "SMPostGroupViewController.h"
#import "SMWritePostViewController.h"

@interface SMBoardViewController ()<UITableViewDelegate, UITableViewDataSource, XPullRefreshTableViewDelegate, SMWebLoaderOperationDelegate>
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
    } else {
        ++_page;
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
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:writeViewController];
    [self.navigationController presentModalViewController:nvc animated:YES];
}

#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData:NO];
}

- (void)tableViewDoRetry:(XPullRefreshTableView *)tableView
{
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
    
    if (indexPath.row == _posts.count - 1) {
        [self loadData:YES];
        [_tableView setLoadMoreShow];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMPost *post = _posts[indexPath.row];
 
    SMPostGroupViewController *vc = [[SMPostGroupViewController alloc] init];
    vc.gid = post.gid;
    vc.board = _board;
    vc.fromBoard = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
    [tmp addObjectsFromArray:board.posts];

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

@end
