//
//  SMPostViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-23.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostViewController.h"
#import "XPullRefreshTableView.h"

@interface SMPostViewController ()<UITableViewDataSource, UITableViewDelegate, SMWebLoaderOperationDelegate, XPullRefreshTableViewDelegate>
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;

@property (strong, nonatomic) SMWebLoaderOperation *pageOp; // 分页加载数据用op
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSArray *postItems;   // post列表

@property (assign, nonatomic) NSInteger bid;    // board id
@property (assign, nonatomic) NSInteger tpage;  // total page
@property (assign, nonatomic) NSInteger pno;    // current page

@property (strong, nonatomic) NSMutableDictionary *postHeightMap;   // cache post webview height;

@property (strong, nonatomic) SMPost *replyPost;    // 准备回复的主题
@property (strong, nonatomic) NSString *postTitle;

@end

@implementation SMPostViewController

- (id)init
{
    self = [super initWithNibName:@"SMPostViewController" bundle:nil];
    if (self) {
        _pno = 1;
        _postHeightMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.xdelegate = self;
    [self.tableView beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)loadData:(BOOL)more
{
    if (!more) {
        _pno = 1;
    }
    NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbstcon.php?board=%@&gid=%d&start=%d&pno=%d", _board.name, _gid, _gid, _pno];
    _pageOp = [[SMWebLoaderOperation alloc] init];
    _pageOp.delegate = self;
    _isLoading = YES;
    [_pageOp loadUrl:url withParser:@"bbstcon"];
}

- (void)setPostItems:(NSArray *)postItems
{
    _postItems = postItems;
    [self.tableView reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _postItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SMPostItem *item = _postItems[section];
    SMWebLoaderOperation *postOp = item.op;
    item.post = postOp.data;
    
    // 1. header    2. content  3... attach
    return 2 + item.post.attaches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMPostItem *item = _postItems[indexPath.section];
    SMPost *post = item.post;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.row == 0) {   // header
        cell.textLabel.text = [NSString stringWithFormat:@"#%d %@", indexPath.section, post.author];
    } else if (indexPath.row == 1) {    // content
        if (!item.op.isFinished) {
            cell.textLabel.text = @"Loading";
        } else if (item.post == nil) {
            cell.textLabel.text = @"Fail";
        } else {
            cell.textLabel.text = post.content;
        }
    }
    
    if (_pno != _tpage && !_isLoading && indexPath.section == _postItems.count - 1) {    // last post, load next
        [self loadData:YES];
    }
    
    return cell;
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    if (opt == _pageOp) {
        _isLoading = NO;
        
        // add post to postOps
        SMPostGroup *postGroup = opt.data;
        _tpage = postGroup.tpage;
        XLog_d(@"%d, %d", _pno, _tpage);
        if (_pno != _tpage) {
            [_tableView setLoadMoreShow];
        } else {
            [_tableView setLoadMoreHide];
        }
        
        NSMutableArray *tmp;
        if (_pno == 1) {    // first page
            [self.tableView endRefreshing:YES];
            tmp = [[NSMutableArray alloc] initWithCapacity:0];
            _bid = postGroup.bid;
            
            _postTitle = postGroup.title;
//            [self makeupTableViewHeader:postGroup.title];
        } else {
            tmp = [_postItems mutableCopy];
        }
        [postGroup.posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SMPost *post = obj;
            NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbscon.php?bid=%d&id=%d", _bid, post.pid];
            
            SMWebLoaderOperation *op = [[SMWebLoaderOperation alloc] init];
            op.delegate = self;
            [op loadUrl:url withParser:@"bbscon"];
            
            SMPostItem *item = [[SMPostItem alloc] init];
            item.op = op;
            item.post = post;
            [tmp addObject:item];
        }];
        XLog_d(@"%d", tmp.count);
        self.postItems = tmp;
        
        // next page
        ++_pno;
    } else {
        XLog_d(@"%@", opt.url);
        [self.tableView reloadData];
//        [self makeupCellDatas];
    }

}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    XLog_d(@"%@ %@", opt.url, error);
    if (opt == _pageOp) {
        _isLoading = NO;
        if (_pno == 1) {
            [self.tableView endRefreshing:NO];
        } else {
            [self.tableView setLoadMoreFail];
        }
        [self toast:error.message];
    } else {
//        [self makeupCellDatas];
    }
}

#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData:NO];
    [SMUtils trackEventWithCategory:@"postgroup" action:@"refresh" label:_board.name];
}

- (void)tableViewDoRetry:(XPullRefreshTableView *)tableView
{
    [self loadData:YES];
    [SMUtils trackEventWithCategory:@"postgroup" action:@"retry" label:_board.name];
}


@end

///////////////////////////////////////////////////////////////
@implementation SMPostItem
@end

