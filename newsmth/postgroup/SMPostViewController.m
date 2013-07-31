//
//  SMPostViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-23.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostViewController.h"
#import "XPullRefreshTableView.h"
#import "SMPostGroupHeaderCell.h"
#import "SMPostFailCell.h"
#import "SMPostGroupContentCell.h"
#import "SMPostGroupAttachCell.h"
#import "PBWebViewController.h"
#import "SMWritePostViewController.h"
#import "SMUserViewController.h"
#import "SMBoardViewController.h"

#define STRING_EXPAND_HERE  @"从此处展开"
#define STRING_EXPAND_ALL  @"同主题展开"

@interface SMPostViewController ()<UITableViewDataSource, UITableViewDelegate, SMWebLoaderOperationDelegate, XPullRefreshTableViewDelegate, XImageViewDelegate, SMPostGroupHeaderCellDelegate, SMPostGroupContentCellDelegate, SMPostFailCellDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *tableViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;

@property (strong, nonatomic) SMWebLoaderOperation *singlePostOp;   // Re, At, Search...
@property (strong, nonatomic) SMPost *singlePost;

@property (strong, nonatomic) SMWebLoaderOperation *pageOp; // 分页加载数据用op
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSArray *postItems;   // post列表

@property (assign, nonatomic) NSInteger bid;    // board id
@property (assign, nonatomic) NSInteger tpage;  // total page
@property (assign, nonatomic) NSInteger pno;    // current page
@property (assign, nonatomic) BOOL isSinglePost;

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

- (void)dealloc
{
    // cancel all requests
    [_pageOp cancel];
    [_singlePostOp cancel];
    [_postItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SMPostItem *item = obj;
        [item.op cancel];
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_board == nil && _postUrl != nil) {
        _isSinglePost = YES;
    }
    
    self.tableView.xdelegate = self;
    [self.tableView beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath != nil) {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if (!_fromBoard || _isSinglePost) {
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                      target:self
                                                      action:@selector(onRightBarButtonClick)];
    }
}

- (void)onRightBarButtonClick
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    if (_isSinglePost) {
        [actionSheet addButtonWithTitle:STRING_EXPAND_HERE];
        [actionSheet addButtonWithTitle:STRING_EXPAND_ALL];
    }
    if (!_fromBoard) {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"进入[%@]版", _board.cnName]];
    }
    [actionSheet addButtonWithTitle:@"取消"];
    actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 1;
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
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
    if (_isSinglePost) {    // at me.
        _pno = _tpage = 1;
        [_singlePostOp cancel];
        _singlePostOp = [[SMWebLoaderOperation alloc] init];
        _singlePostOp.delegate = self;
        [_singlePostOp loadUrl:_postUrl withParser:@"bbscon"];
    } else {
        if (!more) {
            _pno = 1;
        }
        [_pageOp cancel];
        NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbstcon.php?board=%@&gid=%d&start=%d&pno=%d", _board.name, _gid, _start > 0 ? _start : _gid, _pno];
        _pageOp = [[SMWebLoaderOperation alloc] init];
        _pageOp.highPriority = YES;
        _pageOp.delegate = self;
        _isLoading = YES;
        [_pageOp loadUrl:url withParser:@"bbstcon"];
    }
}

- (void)setPostItems:(NSArray *)postItems
{
    _postItems = postItems;
    [self.tableView reloadData];
}

- (void)updateTableView
{
    [UIView setAnimationsEnabled:NO];
    [_tableView beginUpdates];
    [_tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
//    [_tableView reloadData];
}

- (void)makeupTableViewHeader:(NSString *)text
{
    _labelForTitle.text = text;
    self.title = text;
    CGFloat delta = [_labelForTitle.text sizeWithFont:_labelForTitle.font constrainedToSize:CGSizeMake(_labelForTitle.frame.size.width, CGFLOAT_MAX) lineBreakMode:_labelForTitle.lineBreakMode].height - _labelForTitle.frame.size.height;
    CGRect frame = _tableViewHeader.frame;
    frame.size.height += delta;
    _tableViewHeader.frame = frame;
    _tableView.tableHeaderView = _tableViewHeader;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _postItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SMPostItem *item = _postItems[section];
    // 1. header    2. content  3... attach
    int row = 2 + item.post.attaches.count;
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMPostItem *item = _postItems[indexPath.section];
    if (indexPath.row == 0) {   // header
        return [SMPostGroupHeaderCell cellHeight];
    }
    if (indexPath.row == 1) {
        id v = [_postHeightMap objectForKey:@(item.post.pid)];
        if (v != nil) {
            XLog_d(@"has height: %f", [v floatValue]);
            return [v floatValue];
        }
        return 60.0f;
    }
    // attachs
    return [SMPostGroupAttachCell cellHeight:[self getAttachUrl:[self attachAtIndexPath:indexPath]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 1) {    // attach
        NSString *attachUrl = [self getAttachOriginalUrl:[self attachAtIndexPath:indexPath]];
        PBWebViewController *webView = [[PBWebViewController alloc] init];
        webView.URL = [NSURL URLWithString:attachUrl];
        [self.navigationController pushViewController:webView animated:YES];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isSinglePost && _pno <= _tpage && !_isLoading && indexPath.section == _postItems.count - 1) {    // last post, load next
        [self loadData:YES];
    }

    SMPostItem *item = _postItems[indexPath.section];

    if (indexPath.row == 0) {   // header
        return [self cellForTitle:item];
    } else if (indexPath.row == 1) {    // content
        if (!item.op.isFinished) {
            return [self cellForLoading:item];
        } else if (item.op.data == nil) {
            return [self cellForFail:item];
        } else {
            item.post = item.op.data;
            return [self cellForContent:item];
        }
    } else {
        return [self cellForAttach:[self attachAtIndexPath:indexPath]];
    }
}

#pragma cells

- (SMAttach *)attachAtIndexPath:(NSIndexPath *)indexPath
{
    SMPostItem *item = _postItems[indexPath.section];
    return item.post.attaches[indexPath.row - 2];
}

- (UITableViewCell *)cellForTitle:(SMPostItem *)item
{
    NSString *cellid = @"title_cell";
    SMPostGroupHeaderCell *cell = (SMPostGroupHeaderCell *)[self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[SMPostGroupHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    cell.item = item;
    return cell;
}

- (UITableViewCell *)cellForLoading:(SMPostItem *)item
{
    NSString *cellid = @"loading_cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = @"Loading...";
    return cell;
}

- (UITableViewCell *)cellForFail:(SMPostItem *)item
{
    NSString *cellid = @"fail_cell";
    SMPostFailCell *cell = (SMPostFailCell *)[self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[SMPostFailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.item = item;
    cell.delegate = self;
    return cell;
}

- (UITableViewCell *)cellForContent:(SMPostItem *)item
{
    NSString *cellid = @"content_cell";
    SMPostGroupContentCell *cell = (SMPostGroupContentCell *)[self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[SMPostGroupContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    cell.post = item.post;
    return cell;
}

- (UITableViewCell *)cellForAttach:(SMAttach *)attach
{
    NSString *cellid = @"attach_cell";
    SMPostGroupAttachCell *cell = (SMPostGroupAttachCell *)[self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[SMPostGroupAttachCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.imageViewForAttach.delegate = self;
    cell.url = [self getAttachUrl:attach];
    return cell;
}

- (NSString *)getAttachUrl:(SMAttach *)attach
{
    return [NSString stringWithFormat:@"http://att.newsmth.net/nForum/att/%@/%d/%d/large", attach.boardName, attach.pid, attach.pos];
}

- (NSString *)getAttachOriginalUrl:(SMAttach *)attach
{
    return [NSString stringWithFormat:@"http://att.newsmth.net/nForum/att/%@/%d/%d", attach.boardName, attach.pid, attach.pos];
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
            [self makeupTableViewHeader:postGroup.title];
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
            item.index = tmp.count;
            [tmp addObject:item];
        }];
        XLog_d(@"%d", tmp.count);
        self.postItems = tmp;
        
        // next page
        ++_pno;
    } else if (opt == _singlePostOp) {
        [_tableView endRefreshing:YES];
        SMPost *post = opt.data;
        XLog_d(@"%@", post);
        SMPostItem *item = [[SMPostItem alloc] init];
        item.op = opt;
        item.post = post;
        item.index = 1;
        
        _postTitle = post.title;
        [self makeupTableViewHeader:_postTitle];
        _board = post.board;

        self.postItems = @[item];
        
        _singlePost = post;
    } else {
        [self.tableView reloadData];
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
        [_tableView reloadData];
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

#pragma mark - XImageViewDelegate
- (void)xImageViewDidLoad:(XImageView *)imageView
{
//    [self updateTableView];
    [_tableView reloadData];
}

#pragma mark - SMPostGroupHeaderCellDelegate
- (void)postAfterLogin
{
    [self postGroupHeaderCellOnReply:_replyPost];
}

- (void)postGroupHeaderCellOnReply:(SMPost *)post
{
    if (![SMAccountManager instance].isLogin) {
        _replyPost = post;
        [self performSelectorAfterLogin:@selector(postAfterLogin)];
        return ;
    }
    SMWritePostViewController *writeViewController = [[SMWritePostViewController alloc] init];
    writeViewController.post = post;
    writeViewController.postTitle = _postTitle;
    writeViewController.title = [NSString stringWithFormat:@"回复-%@", _postTitle];
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:writeViewController];
    [self.navigationController presentModalViewController:nvc animated:YES];
    
    [SMUtils trackEventWithCategory:@"postgroup" action:@"reply" label:_board.name];
}

- (void)postGroupHeaderCellOnUsernameClick:(NSString *)username
{
    SMUserViewController *vc = [[SMUserViewController alloc] init];
    vc.username = username;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - SMPostGroupContentCellDelegate
- (void)postGroupContentCell:(SMPostGroupContentCell *)cell heightChanged:(CGFloat)height
{
    id pid = @(cell.post.pid);
    if ([_postHeightMap objectForKey:pid] == nil) {
        [_postHeightMap setObject:@(height) forKey:pid];
        [_tableView reloadData];
    }
}

- (void)postGroupContentCell:(SMPostGroupContentCell *)cell shouldLoadUrl:(NSURL *)url
{
    PBWebViewController *webView = [[PBWebViewController alloc] init];
    webView.URL = url;
    [self.navigationController pushViewController:webView animated:YES];
}

#pragma mark - SMPostFailCellDelegate
- (void)postFailCellOnRetry:(SMPostFailCell *)cell
{
    SMPostItem *item = cell.item;
    SMPost *post = item.post;
//    NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbscon.php?bid=%d&id=%d", _bid, post.pid];

    // use m.newsmth to retry
    // http://m.newsmth.net/article/AdvancedEdu/single/31071/0
    NSString *url = [NSString stringWithFormat:@"http://m.newsmth.net/article/%@/single/%d/0", _board.name, post.pid];
//    XLog_d(@"%@", url);

    [item.op cancel];

    SMWebLoaderOperation *op = [[SMWebLoaderOperation alloc] init];
    op.highPriority = YES;
    op.delegate = self;
    item.op = op;
    
    [op loadUrl:url withParser:@"bbscon"];

    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];

    [SMUtils trackEventWithCategory:@"postgroup" action:@"retry_cell" label:_board.name];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.destructiveButtonIndex) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:STRING_EXPAND_HERE]) {
            _gid = _singlePost.gid;
            _start = _singlePost.pid;
            _isSinglePost = NO;
            [_tableView beginRefreshing];
        } else if ([title isEqualToString:STRING_EXPAND_ALL]) {
            _gid = _singlePost.gid;
            _start = _singlePost.gid;
            _isSinglePost = NO;
            [_tableView beginRefreshing];
        } else {
            SMBoardViewController *vc = [[SMBoardViewController alloc] init];
            vc.board = _board;
            [self.navigationController pushViewController:vc animated:YES];
            
            [SMUtils trackEventWithCategory:@"postgroup" action:@"enter_board" label:_board.name];
        }
    }
}


@end

///////////////////////////////////////////////////////////////
@implementation SMPostItem
@end

