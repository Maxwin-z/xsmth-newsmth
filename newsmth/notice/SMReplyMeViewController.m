//
//  SMReplyMeViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-28.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMReplyMeViewController.h"
#import "XPullRefreshTableView.h"
#import "SMMainpageCell.h"

@interface SMReplyMeViewController ()<XPullRefreshTableViewDelegate, UITableViewDelegate, UITableViewDataSource, SMWebLoaderOperationDelegate>
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger tpage;

@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) SMWebLoaderOperation *op;
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;
@end

@implementation SMReplyMeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"回复我";
    
    _tableView.xdelegate = self;
    [self loadData:NO];
}

- (void)loadData:(BOOL)more
{
    if (!more) {
        _page = 1;
    } else {
        ++_page;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/nForum/refer/reply?ajax&p=%d", _page];
    
    [_op cancel];
    _op = [[SMWebLoaderOperation alloc] init];
    _op.delegate = self;
    [_op loadUrl:url withParser:@"refer_me"];
}

- (void)setPosts:(NSArray *)posts
{
    _posts = posts;
    [_tableView reloadData];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SMMainpageCell cellHeight:_posts[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMMainpageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[SMMainpageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.post = _posts[indexPath.row];
    
    if (indexPath.row == _posts.count - 1 && _page < _tpage) {
        [self loadData:YES];
    }

    return cell;
}


#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
//    XLog_d(@"%@", opt.data);
    [_tableView endRefreshing:YES];
    
    SMPostGroup *postGroup = opt.data;
    
    // format title
    [postGroup.posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SMPost *post = obj;
        post.title = [NSString stringWithFormat:@"[%@]%@", post.board.name, post.title];
        post.board.cnName = [SMUtils formatDate:[NSDate dateWithTimeIntervalSince1970:post.date / 1000]];
    }];
    
    NSMutableArray *tmp;
    if (_page == 1) {
        _tpage = postGroup.tpage;
        tmp = [[NSMutableArray alloc] init];
    } else {
        tmp = [_posts mutableCopy];
    }
    
    [tmp addObjectsFromArray:postGroup.posts];
    self.posts = tmp;
    
    if (_page < _tpage) {
        [_tableView setLoadMoreShow];
    } else {
        [_tableView setLoadMoreHide];
    }
    
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self toast:error.message];
    if (_page == 1) {
        [_tableView endRefreshing:NO];
    } else {
        [_tableView setLoadMoreFail];
    }
}


#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData:NO];
}

- (void)tableViewDoRetry:(XPullRefreshTableView *)tableView
{
    [self loadData:YES];
    [_tableView reloadData];
}

@end
