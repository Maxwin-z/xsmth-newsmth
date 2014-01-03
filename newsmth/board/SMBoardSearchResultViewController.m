//
//  SMBoardSearchResultViewController.m
//  newsmth
//
//  Created by damu on 12/17/13.
//  Copyright (c) 2013 nju. All rights reserved.
//

#import "SMBoardSearchResultViewController.h"
#import "XPullRefreshTableView.h"
#import "SMBoardCell.h"
#import "SMPostViewController.h"

@interface SMBoardSearchResultViewController ()<SMWebLoaderOperationDelegate, XPullRefreshTableViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) SMWebLoaderOperation *op;
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;
@property (strong, nonatomic) NSArray *posts;
@end

@implementation SMBoardSearchResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.xdelegate = self;
    
    [_tableView beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath) {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)loadData:(BOOL)more
{
    [_op cancel];
    _op = [SMWebLoaderOperation new];
    _op.delegate = self;
    [_op loadUrl:_url withParser:@"bbsbfind"];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SMBoardCell cellHeight:_posts[indexPath.row] withWidth:self.tableView.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"postcell";
    SMBoardCell *cell = (SMBoardCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SMBoardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.post = _posts[indexPath.row];
//    cell.delegate = self;
    
//    if (indexPath.row == _posts.count - 1) {
//        [self loadData:YES];
//        [_tableView setLoadMoreShow];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMPost *post = _posts[indexPath.row];

    SMPostViewController *vc = [[SMPostViewController alloc] init];
    vc.postUrl = [NSString stringWithFormat:@"http://m.newsmth.net/article/%@/single/%d/0", _board.name, post.gid];
    vc.fromBoard = YES;
    
    if ([SMUtils isPad]) {
        [SMIPadSplitViewController instance].detailViewController = vc;
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - XPullRefreshTableView
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData:NO];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [_tableView endRefreshing:YES];

    SMBoard *board = opt.data;
    _posts = board.posts;
    [_tableView reloadData];
    
    self.title = [NSString stringWithFormat:@"共%d条结果", _posts.count];
//    XLog_d(@"%@", board);
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [_tableView endRefreshing:NO];

    [self toast:error.message];
}

@end
