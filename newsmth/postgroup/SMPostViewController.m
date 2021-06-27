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
#import "XWebViewController.h"
#import "SMWritePostViewController.h"
#import "SMUserViewController.h"
#import "SMBoardViewController.h"
#import "XScrollIndicator.h"
#import "SMPageCell.h"
#import "SMIPadSplitViewController.h"
#import "SMMainViewController.h"
#import "SMBoardSearchViewController.h"
#import "SMMailComposeViewController.h"
#import <Social/Social.h>
#import "SMPostActivityItemProvider.h"
#import "SMMailToActivity.h"
#import "SMViewLinkActivity.h"
#import "SMDiagnoseViewController.h"
#import "SMPostWebLoaderOperation.h"
#import "SMDBManager.h"
#import "SMBoardViewTypeSelectorView.h"
#import "SMPostLinksViewController.h"
#import "SMPostViewControllerV2.h"

#define STRING_EXPAND_HERE  @"从此处展开"
#define STRING_EXPAND_ALL  @"同主题展开"


@interface SMPostViewController ()<UITableViewDataSource, UITableViewDelegate, SMWebLoaderOperationDelegate, XPullRefreshTableViewDelegate, XImageViewDelegate, SMPostGroupHeaderCellDelegate, SMPostGroupContentCellDelegate, SMPostFailCellDelegate, SMPageCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *tableViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (strong, nonatomic) XScrollIndicator *scrollIndicator;

@property (strong, nonatomic) SMWebLoaderOperation *singlePostOp;   // Re, At, Search...
@property (strong, nonatomic) SMPost *singlePost;

@property (strong, nonatomic) SMWebLoaderOperation *pageOp; // 分页加载数据用op
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSArray *items;   // items列表
@property (strong, nonatomic) NSArray *prepareItems;    // 滚动时，临时存储数据

@property (assign, nonatomic) int bid;    // board id
//@property (assign, nonatomic) NSInteger tpage;  // total page
//@property (assign, nonatomic) NSInteger pno;    // current page
@property (assign, nonatomic) BOOL isSinglePost;

// 支持继续加载
@property (assign, nonatomic) NSInteger totalPage;   // 一共有多少页
//@property (assign, nonatomic) NSInteger start;  // 当前开始的post id
//@property (assign, nonatomic) NSInteger pno;    // 从开始的post id已加载了多少页
//@property (assign, nonatomic) NSInteger tpage;  // 从开始的post id，一共有多少页

/*
 默认totalPage = 0, start = 第一个post id
 每次触发继续加载，设置当前最后一个post id为start, pno = 1
 数据返回，加数据合并到当前list中, totalPage += tpage - 1.
*/

@property (strong, nonatomic) NSMutableDictionary *postHeightMap;   // cache post webview height;

@property (strong, nonatomic) SMPost *replyPost;    // 准备回复的主题
@property (strong, nonatomic) NSString *postTitle;


// 转寄
@property (strong, nonatomic) SMWebLoaderOperation *forwardOp;

// v2.1 full post viewer
@property (strong, nonatomic) IBOutlet UIView *viewForFullPostContainer;
@property (weak, nonatomic) IBOutlet UIWebView *webViewForFullPost;

@property (assign, nonatomic) NSInteger failTimes;

// v2.4 用户主动刷新，清除缓存主题
@property (assign, nonatomic) BOOL isAutoLoad;
@end

@implementation SMPostViewController

- (id)init
{
    self = [super initWithNibName:@"SMPostViewController" bundle:nil];
    if (self) {
//        _pno = 1;
        _totalPage = 0;
        _postHeightMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    // cancel all requests
    [_pageOp cancel];
    [_singlePostOp cancel];
    [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SMPostItem class]]) {
            SMPostItem *item = obj;
            [item.op cancel];
        }
        if ([obj isKindOfClass:[SMPostPageItem class]]) {
            SMPostPageItem *item = obj;
            [item.op cancel];
        }
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isAutoLoad = YES;
    self.tableView.xdelegate = self;
    
    if (_board == nil && _postUrl != nil) {
        _isSinglePost = YES;
    }
    [self.tableView beginRefreshing];
    

    CGRect frame = self.view.bounds;
    frame.origin.x = frame.size.width - 28;
    frame.origin.y = SM_TOP_INSET + 20.0f;;
    frame.size.height -= frame.origin.y + 40.0f;
    frame.size.width -= frame.origin.x;
    
    _scrollIndicator = [[XScrollIndicator alloc] initWithFrame:frame];
    [self.view addSubview:_scrollIndicator];
    _scrollIndicator.hidden = YES;
    _scrollIndicator.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [_scrollIndicator addTarget:self action:@selector(onScrollIndicatorValueChanged) forControlEvents:UIControlEventValueChanged];
    [_scrollIndicator addTarget:self action:@selector(onScrollIndicatorTouchEnd) forControlEvents:UIControlEventTouchCancel];
    
    // v2.1
//    self.webViewForFullPost.scrollView.contentInset = self.webViewForFullPost.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(SM_TOP_INSET, 0, 0, 0);
    self.webViewForFullPost.scrollView.scrollsToTop = NO;
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

- (void)setupTheme
{
    [super setupTheme];
    _labelForTitle.textColor = [SMTheme colorForPrimary];
    _viewForFullPostContainer.backgroundColor = [SMTheme colorForBackground];
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

- (void)onDeviceRotate
{
    [super onDeviceRotate];
    [self.postHeightMap removeAllObjects];
    [self.tableView reloadData];
}

- (void)loadData:(BOOL)more
{
    if (_isSinglePost) {    // at me.
//        _pno = _tpage = 1;
        _currentPageItem.pno = _currentPageItem.tpage = 1;
        [_singlePostOp cancel];
        _singlePostOp = [[SMWebLoaderOperation alloc] init];
        _singlePostOp.delegate = self;
        [_singlePostOp loadUrl:_postUrl withParser:@"bbscon,util_notice"];
    } else {
        SMPostPageItem *pageItem = [[SMPostPageItem alloc] init];
        pageItem.gid = _gid;
        if (_start == 0) {
            [SMWebLoaderOperation cancelAllOperations];
            pageItem.start = _gid;
        } else {
            pageItem.start = _start;
        }
        pageItem.pageIndex = 1;
        pageItem.pno = 1;
        pageItem.startIndex = 0;
        
        self.prepareItems = @[pageItem];
        self.tableView.enablePullLoad = YES;
    }
}

- (void)loadPageData:(SMPostPageItem *)item
{
    _currentPageItem.isLoading = NO;
    _currentPageItem = item;
    _currentPageItem.isPageLoaded = NO;
    _currentPageItem.isLoadFail = NO;
    _currentPageItem.isLoading = YES;

    [_currentPageItem.op cancel];
    [_pageOp cancel];
    NSString *url = [NSString stringWithFormat:URL_PROTOCOL @"//www.mysmth.net/bbstcon.php?board=%@&gid=%@&start=%@&pno=%@", _board.name, @(_gid), @(_currentPageItem.start), @(_currentPageItem.pno)];
    _pageOp = [[SMWebLoaderOperation alloc] init];
    _pageOp.highPriority = YES;
    _pageOp.delegate = self;
    _currentPageItem.op = _pageOp;
    _isLoading = YES;
    [_pageOp loadUrl:url withParser:@"bbstcon"];
}

- (void)onScrollIndicatorValueChanged
{
    if (!_scrollIndicator.isDragging) {
        return; // 程序设置的位置，不做处理
    }
    
    NSInteger index = _scrollIndicator.selectedIndex;
    __block NSInteger section = 0;
    [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SMPostPageItem class]]) {
            SMPostPageItem *pageItem = obj;
            if (pageItem.pageIndex == index + 1) {
                section = idx;
                *stop = YES;
            }
        }
    }];
    if (section < _items.count) {
//        XLog_v(@"scrollto section: %d of %d", section, _items.count);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)onScrollIndicatorTouchEnd
{
    if (_prepareItems) {
        self.items = _prepareItems;
    } else {
        [self.tableView reloadData];
    }
    NSString *label = [NSString stringWithFormat:@"%@/%@", @(_scrollIndicator.selectedIndex), @(_scrollIndicator.titles.count)];
    [SMUtils trackEventWithCategory:@"postgroup" action:@"scrollindicator" label:label];
    XLog_d(@"%@", label);
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    _prepareItems = nil;    // clear tmp data
    [self.tableView reloadData];
}

- (void)setPrepareItems:(NSArray *)prepareItems
{
    if (!_scrollIndicator.isDragging) {
        self.items = prepareItems;
    } else {
        _prepareItems = prepareItems;
    }
}

- (void)setTotalPage:(NSInteger)totalPage
{
    _totalPage = totalPage;
    
    if (_totalPage < 2) return ;
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    for (int i = 0; i < _totalPage; ++i) {
        [pages addObject:[NSString stringWithFormat:@"%d", i + 1]];
    }
    _scrollIndicator.titles = pages;
}

- (void)updateTableView
{
    [UIView setAnimationsEnabled:NO];
    [_tableView beginUpdates];
    [_tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}

- (void)makeupTableViewHeader:(NSString *)text
{
    _labelForTitle.text = text;
    self.title = text;
    CGFloat delta = [_labelForTitle.text smSizeWithFont:_labelForTitle.font constrainedToSize:CGSizeMake(_labelForTitle.frame.size.width, CGFLOAT_MAX) lineBreakMode:_labelForTitle.lineBreakMode].height - _labelForTitle.frame.size.height;
    CGRect frame = _tableViewHeader.frame;
    frame.size.height += delta;
    _tableViewHeader.frame = frame;
    _tableView.tableHeaderView = _tableViewHeader;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id item = _items[section];
    if ([item isKindOfClass:[SMPostPageItem class]]) {
        return 1;
    } else {
        SMPostItem *postItem = item;
        // 1. header    2. content  3... attach
        size_t row = 2 + postItem.post.attaches.count;
        return row;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = _items[indexPath.section];
    if ([item isKindOfClass:[SMPostPageItem class]]) {
        SMPostPageItem *pageItem = item;
        if (pageItem.isPageLoaded) {
            return 0;
        } else {
            return self.tableView.bounds.size.height;
        }
    } else {
        SMPostItem *postItem = item;
        if (indexPath.row == 0) {   // header
            return [SMPostGroupHeaderCell cellHeight:item];
        }
        if (indexPath.row == 1) {   // content
            if (postItem.op.data) {
                postItem.post = postItem.op.data;
            }
            if ([SMConfig enableOptimizePostContent] && postItem.post.content) {  // label
                return [SMPostGroupContentCell cellHeight:postItem.post withWidth:self.tableView.frame.size.width];
            } else {    // webview
                id v = [_postHeightMap objectForKey:@(postItem.post.pid)];
                if (v != nil) {
                    return [v floatValue];
                }
                return 60.0f;
            }
        }
        // attachs
        return [SMPostGroupAttachCell cellHeight:[self getAttachUrl:[self attachAtIndexPath:indexPath]] withWidth:self.tableView.frame.size.width];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 1) {    // attach
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看原图", @"保持图片", nil];
        [sheet.rac_buttonClickedSignal subscribeNext:^(id x) {
            NSInteger buttonIndex = [x integerValue];
            if (buttonIndex == sheet.cancelButtonIndex) {
                return ;
            }
            if ([[sheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"查看原图"]) {
                NSString *attachUrl = [self getAttachOriginalUrl:[self attachAtIndexPath:indexPath]];
                XWebViewController *webView = [[XWebViewController alloc] init];
                webView.url = [NSURL URLWithString:attachUrl];
                [self.navigationController pushViewController:webView animated:YES];
            } else {
                SMPostGroupAttachCell *attachCell = (SMPostGroupAttachCell *)[tableView cellForRowAtIndexPath:indexPath];
                if ([attachCell isKindOfClass:[SMPostGroupAttachCell class]]) {
                    UIImageWriteToSavedPhotosAlbum(attachCell.imageViewForAttach.image, nil, nil, nil);
                }
            }
        }];
        [sheet showInView:self.view];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isSinglePost && _currentPageItem.pno <= _currentPageItem.tpage && !_isLoading && indexPath.section == _items.count - 1) {    // last post, load next
        [self loadData:YES];
    }
    
    id item = _items[indexPath.section];
    if ([item isKindOfClass:[SMPostPageItem class]]) {
        static NSString *pageCellId = @"pagecellid";
        SMPageCell *cell = [tableView dequeueReusableCellWithIdentifier:pageCellId];
        if (cell == nil) {
            cell = [[SMPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pageCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        SMPostPageItem *pageItem = item;
        cell.pageItem = item;
        
        if (!pageItem.isPageLoaded && !pageItem.isLoadFail && !pageItem.isLoading && !self.scrollIndicator.isDragging) {
            // v2.1 防止分页抖动。仅显示cell top 1/3的地方，才加载数据
            CGRect currentCellFrame = [tableView rectForRowAtIndexPath:indexPath];
            CGFloat offsetY = tableView.contentOffset.y;
//            XLog_d(@"++++%@ %@, %@, %@", @(pageItem.pno), NSStringFromCGRect(currentCellFrame), @(offsetY), @(offsetY - currentCellFrame.origin.y));
            // todo rewrite
            if (offsetY - currentCellFrame.origin.y < 400) {
                [self loadPageData:pageItem];
            }
        }
        
        if (!self.scrollIndicator.isDragging) {
            self.scrollIndicator.selectedIndex = pageItem.pageIndex - 1;
        }
        
        return cell;
    } else {
        SMPostItem *postItem = item;
        
        if (!self.scrollIndicator.isDragging) {
            self.scrollIndicator.selectedIndex = postItem.pageIndex - 1;
        }
        
        if (indexPath.row == 0) {   // header
            return [self cellForTitle:item];
        } else if (indexPath.row == 1) {    // content
            if (!postItem.op.isDone) {
                return [self cellForLoading:postItem];
            } else if (postItem.op.data == nil) {
                return [self cellForFail:postItem];
            } else {
                postItem.post = postItem.op.data;
                
                // v2.4 mark post as read
                [[SMDBManager instance] insertPostReadCount:postItem.post type:SMBoardViewTypeNormal];
                return [self cellForContent:postItem atIndexPath:indexPath];
            }
        } else {
            return [self cellForAttach:[self attachAtIndexPath:indexPath]];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hidePostCellActions];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollIndicator.titles.count > 1) {
        self.scrollIndicator.hidden = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScrollIndicator) object:nil];
    [self performSelector:@selector(hideScrollIndicator) withObject:nil afterDelay:0.5f];
}

- (void)hideScrollIndicator
{
    if (!self.scrollIndicator.isDragging) {
        self.scrollIndicator.hidden = YES;
    }
}

#pragma mark cells

- (SMAttach *)attachAtIndexPath:(NSIndexPath *)indexPath
{
    SMPostItem *item = _items[indexPath.section];
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
        cell.viewController = self;
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
    cell.backgroundColor = [SMTheme colorForBackground];
    cell.textLabel.textColor = [SMTheme colorForPrimary];

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

- (UITableViewCell *)cellForContent:(SMPostItem *)item atIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = [NSString stringWithFormat:@"content_cell_%@", @(indexPath.section % 3)];
//    NSString *cellid = @"content_cell";
    SMPostGroupContentCell *cell = (SMPostGroupContentCell *)[self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[SMPostGroupContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    [cell setPost:item.post withOptimize:[SMConfig enableOptimizePostContent]];
//    cell.post = item.post;
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
    NSString *type = @"large";
    return [NSString stringWithFormat:URL_PROTOCOL @"//att.mysmth.net/nForum/att/%@/%d/%d/%@", attach.boardName, attach.pid, attach.pos, type];
}

- (NSString *)getAttachOriginalUrl:(SMAttach *)attach
{
    return [NSString stringWithFormat:URL_PROTOCOL @"//att.mysmth.net/nForum/att/%@/%d/%d", attach.boardName, attach.pid, attach.pos];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    if (opt == _pageOp) {
        _isLoading = NO;
        _currentPageItem.isPageLoaded = YES;
        _currentPageItem.isLoading = NO;
        
        // add post to postOps
        SMPostGroup *postGroup = opt.data;
        
        if (_totalPage == 0) {  // 首次或刷新操作，构建新的数组postItems
            [self.tableView endRefreshing:YES];
            _bid = postGroup.bid;
            _postTitle = postGroup.title;
            [self makeupTableViewHeader:postGroup.title];
        }
        [self.tableView setLoadMoreHide];
        
        NSInteger index = [_items indexOfObject:_currentPageItem];
        if (_currentPageItem.isLastOne) {
            index = _items.count - 1;
        }
        NSMutableArray *headArray = [[_items subarrayWithRange:NSMakeRange(0, index + 1)] mutableCopy];
        NSArray *tailArray = [_items subarrayWithRange:NSMakeRange(index + 1, _items.count - index - 1)];
        
        // add postItems
        __block BOOL needRemoveFirstPost = _totalPage != 0 && _currentPageItem.pno == 1; // 继续加载使用最后一条做开始，会导致重复
        [postGroup.posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SMPost *post = obj;

            // 再次检测是否第一条重复（保险期间）
            if (needRemoveFirstPost) {
                needRemoveFirstPost = NO;
                SMPostItem *lastItem = [headArray lastObject];
                if (lastItem.post.pid == post.pid) {    // 重复，跳过
                    return ;
                }
            }
            
            NSString *url = [NSString stringWithFormat:URL_PROTOCOL @"//www.mysmth.net/bbscon.php?bid=%@&id=%@", @(_bid), @(post.pid)];
            if (![SMConfig enableShowQMD]) {
                url = [NSString stringWithFormat:URL_PROTOCOL @"//m.mysmth.net/article/%@/single/%d/0",
                             _board.name, post.pid];
            }

           // SMWebLoaderOperation *op = [[SMWebLoaderOperation alloc] init];
            SMPostWebLoaderOperation *op = [SMPostWebLoaderOperation new];
            post.board = self.board;
            post.board.bid = self.bid;
            op.delegate = self;
            [op loadPost:post fromMobile:![SMConfig enableShowQMD]];
            // [op loadUrl:url withParser:@"bbscon,util_notice"];
            
            SMPostItem *item = [[SMPostItem alloc] init];
            item.op = op;
            item.post = post;
            item.index = _currentPageItem.startIndex + idx;
            item.pageIndex = _currentPageItem.pageIndex;

            [headArray addObject:item];
        }];
        
        if (_currentPageItem.pno == 1 && postGroup.tpage > 1) {  // 首次加载，构建新的数组postItems
            NSUInteger countPerPage = postGroup.posts.count;
            for (int i = 2; i <= postGroup.tpage; ++i) {
                SMPostPageItem *pageItem = [[SMPostPageItem alloc] init];
                pageItem.gid = _currentPageItem.gid;
                pageItem.start = _currentPageItem.start;
                pageItem.pno = i;
                pageItem.pageIndex = _totalPage + i;
                pageItem.startIndex = countPerPage * (i - 1) + _currentPageItem.startIndex;
                
                [headArray addObject:pageItem];
            }
            self.totalPage += postGroup.tpage;
        } else if (_totalPage == 0) {
            self.totalPage = 1;
        }
        
        [headArray addObjectsFromArray:tailArray];
        self.prepareItems = headArray;

    } else if (opt == _singlePostOp) {
        [_tableView endRefreshing:YES];
        SMPost *post = opt.data;
//        XLog_d(@"%@", post);
        SMPostItem *item = [[SMPostItem alloc] init];
        item.op = opt;
        item.post = post;
        item.index = 0;
        
        _postTitle = post.title;
        [self makeupTableViewHeader:_postTitle];
        _board = post.board;

        self.prepareItems = @[item];
        
        _singlePost = post;
    } else if (opt == _forwardOp) {
        SMWriteResult *res = _forwardOp.data;
        if (res.success) {
            [self toast:@"转寄成功"];
        }
        XLog_d(@"%@", res);
    } else {
        if ([opt.data isKindOfClass:[SMPost class]]) {
            SMPost *post = opt.data;
            if (post.hasNotice) {
                [SMAccountManager instance].notice = post.notice;
            }
        }
        
        if (!_scrollIndicator.isDragging) {
            [self.tableView reloadData];
        }
    }

    self.failTimes = 0;
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    XLog_d(@"%@ %@", opt.url, error);
    if (opt == _pageOp) {
        _currentPageItem.isLoadFail = YES;
        _currentPageItem.isLoading = NO;
        [_tableView setLoadMoreHide];
    }
    
    if (opt == _forwardOp) {
        [self toast:error.message];
    }
    
    if (opt == _singlePostOp) {
        _isLoading = NO;
        [self.tableView endRefreshing:NO];
        [self toast:error.message];
    } else if (!_scrollIndicator.isDragging) {
        [_tableView reloadData];
    }
    
    if (++self.failTimes > 1 && (opt == _pageOp || opt == _singlePostOp)) {
        self.failTimes = 0;
        [SMDiagnoseViewController diagnose:opt.url rootViewController:self];
    }
}

#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    if (!self.isAutoLoad) {
        if (!self.isSinglePost && self.gid > 0) {
            [[SMDBManager instance] deletePostsWithGid:self.gid board:_board.name];
        }
        [SMUtils trackEventWithCategory:@"postgroup" action:@"refresh" label:_board.name];
    }
    // 第一次自动刷新后，设置为NO
    self.isAutoLoad = NO;

    _totalPage = 0;
    [self loadData:NO];
}

- (void)tableViewDoLoadMore:(XPullRefreshTableView *)tableView
{
    // get last page item
    SMPostPageItem *pageItem = nil;
    for (int i = (int)_items.count - 1; i >= 0; --i) {
        id item = _items[i];
        if ([item isKindOfClass:[SMPostPageItem class]]) {
            pageItem = item;
            break;
        }
    }
    if (pageItem) { // should be always exists
        SMPostItem *postItem = [_items lastObject];
        if ([postItem isKindOfClass:[SMPostItem class]]) {  // should be
            pageItem.start = postItem.post.pid;
            pageItem.startIndex = postItem.pageIndex - 1;
            pageItem.pno = 1;
            pageItem.isLastOne = YES;
            [self loadPageData:pageItem];
            [SMUtils trackEventWithCategory:@"postgroup" action:@"loadmore" label:_board.name];
        } else {
            XLog_e(@"last item is not post");
        }
    } else {
        XLog_e(@"cannot find page item");
    }
}

- (void)tableViewDoRetry:(XPullRefreshTableView *)tableView
{
    [self loadData:YES];
    [self.tableView setLoadMoreShow];
    [SMUtils trackEventWithCategory:@"postgroup" action:@"retry" label:_board.name];
}

#pragma mark - XImageViewDelegate
- (void)xImageViewDidLoad:(XImageView *)imageView
{
    if (!_scrollIndicator.isDragging) {
        [_tableView reloadData];
    }
}

#pragma mark - SMPostGroupHeaderCellDelegate
- (void)postAfterLogin
{
    [self postGroupHeaderCellOnReply:_replyPost];
}

- (void)postGroupHeaderCellOnReply:(SMPost *)post
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:USERDEFAULTS_SWIPE_HINT]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"帖子上左滑← ←有更多选项" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERDEFAULTS_SWIPE_HINT];
    }
    [self doReplyPost:post];
    [SMUtils trackEventWithCategory:@"postgroup" action:@"reply" label:_board.name];
}

- (void)postGroupHeaderCellOnUsernameClick:(NSString *)username
{
    SMUserViewController *vc = [[SMUserViewController alloc] init];
    vc.username = username;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doReplyPost:(SMPost *)post
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
    if ([SMConfig iPadMode]) {
        [[SMIPadSplitViewController instance] presentModalViewController:nvc animated:YES];
    } else {
        [self presentModalViewController:nvc animated:YES];
    }
}

#pragma mark - SMPostGroupContentCellDelegate
- (void)postGroupContentCell:(SMPostGroupContentCell *)cell heightChanged:(CGFloat)height
{
    id pid = @(cell.post.pid);
    if ([_postHeightMap objectForKey:pid] == nil) {
        [_postHeightMap setObject:@(height) forKey:pid];
        if (!_scrollIndicator.isDragging) {
            [_tableView reloadData];
        }
    }
}

- (void)postGroupContentCell:(SMPostGroupContentCell *)cell fullHtml:(NSString *)html
{
    [self showFullPostWithHtml:html];
}

- (void)postGroupContentCell:(SMPostGroupContentCell *)cell shouldLoadUrl:(NSURL *)url
{
    if ([[url.absoluteString lowercaseString] hasSuffix:@".mp4"]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        XWebViewController *webView = [[XWebViewController alloc] init];
        webView.url = url;
        [self.navigationController pushViewController:webView animated:YES];
    }
}

- (void)postGroupContentCellOnReply:(SMPostGroupContentCell *)cell
{
    [self doReplyPost:cell.post];
    [self hidePostCellActions];
    
    [SMUtils trackEventWithCategory:@"postgroup" action:@"reply_swipe" label:_board.name];
}

- (void)postGroupContentCellOnForward:(SMPostGroupContentCell *)cell
{
    _replyPost = cell.post;
    [self performSelectorAfterLogin:@selector(forwardAfterLogin)];
    
    [SMUtils trackEventWithCategory:@"postgroup" action:@"forward_swipe" label:_board.name];
}

- (void)forwardAfterLogin
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"转寄"
                                                        message:@"请输入转寄到的id或email"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"转寄", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].text = [SMAccountManager instance].name;
    [alertView show];
    [self hidePostCellActions];
}

- (void)postGroupContentCellOnSearch:(SMPostGroupContentCell *)cell
{
    SMBoardSearchViewController *svc = [[SMBoardSearchViewController alloc] initWithStyle:UITableViewStylePlain];
    svc.board = _board;
    svc.postAuthor = cell.post.author;
    svc.postTitle = self.postTitle;
    
    [self hidePostCellActions];

    if ([SMConfig iPadMode]) {
        [[(SMMainViewController *)([SMIPadSplitViewController instance].masterViewController) centerViewController] pushViewController:svc animated:YES];
    } else {
        [self.navigationController pushViewController:svc animated:YES];
    }

    [SMUtils trackEventWithCategory:@"postgroup" action:@"search_swipe" label:_board.name];
    
}

- (void)postGroupContentCellOnMoreAction:(SMPostGroupContentCell *)cell
{
    [self hidePostCellActions];

    if (NSClassFromString(@"UIActivityViewController") != nil) {
        SMPost *post = cell.post;
        post.board = self.board;
        
        NSString *url = [NSString stringWithFormat:URL_PROTOCOL @"//m.mysmth.net/article/%@/single/%d/0",
                         post.board.name, post.pid];

        SMPostActivityItemProvider *provider = [[SMPostActivityItemProvider alloc] initWithPlaceholderItem:post];
        SMMailToActivity *mailtoActivity = [SMMailToActivity new];
        SMViewLinkActivity *viewLinkActivity = [SMViewLinkActivity new];

        NSMutableArray *activites = [[NSMutableArray alloc] initWithArray:@[mailtoActivity]];
        if (post.links.count > 0) {
            [activites addObject:viewLinkActivity];
        }
        
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[provider, [NSURL URLWithString:url]] applicationActivities:activites];
        if (&UIActivityTypeAirDrop != NULL) {
            avc.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeMessage];
        } else {
            avc.excludedActivityTypes = @[UIActivityTypeMessage];
        }
        @weakify(self);
        @weakify(avc);
        avc.completionHandler = ^(NSString *activityType, BOOL completed) {
            @strongify(self);
            @strongify(avc);
            if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
                [self toast:@"已Copy链接到剪切板"];
            }
            if ([activityType isEqualToString:SMActivityTypeMailToAuthor]) {
                if ([SMUtils systemVersion] < 7) {  // fixme: ios6 animation cause crash
                    [self performSelector:@selector(mailtoWithPost:) withObject:post afterDelay:1];
                } else {
                    [self mailtoWithPost:post];
                }
            }
            if ([activityType isEqualToString:SMActivityViewLinkActivity]) {
                SMPostLinksViewController *vc = [SMPostLinksViewController new];
                vc.post = post;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            [SMUtils trackEventWithCategory:@"postgroup" action:@"more_action" label:activityType];
            avc.completionHandler = nil;
        };
       
        if ([SMUtils isPad] && [SMUtils systemVersion] >= 8) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:avc];
            
            CGRect frame = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height, 0, 0);
            [popover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:0 animated:YES];
        } else {
            [self.view.window.rootViewController presentViewController:avc animated:YES completion:nil];
        }

//        [self.navigationController presentModalViewController:avc animated:YES];
        return;
    }
    
    NSString *titleForShare = @"分享";
    NSString *titleForMail = @"发信";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:titleForShare, titleForMail, nil];
    @weakify(self);
    [actionSheet.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
        NSString *title = [actionSheet buttonTitleAtIndex:[buttonIndex integerValue]];
        if ([title isEqualToString:titleForShare]) {    // share
            NSString *titleForWXSession = @"微信好友";
            NSString *titleForWXTimeline = @"朋友圈";
            NSString *titleForTencentWeibo = @"腾讯微博";
            NSString *titleForWeibo = @"微博";
            NSString *titleForTwitter = @"twitter";
            UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:titleForWXSession, titleForWXTimeline, nil];
            
            // 内置分享
            if (NSClassFromString(@"SLComposeViewController") != nil) {
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTencentWeibo]) {
                    [shareActionSheet addButtonWithTitle:titleForTencentWeibo];
                }
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
                    [shareActionSheet addButtonWithTitle:titleForWeibo];
                }
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                    [shareActionSheet addButtonWithTitle:titleForTwitter];
                }
            }
            
            shareActionSheet.cancelButtonIndex = [shareActionSheet addButtonWithTitle:@"取消"];
            
            [shareActionSheet.rac_buttonClickedSignal subscribeNext:^(NSNumber *buttonIndex) {
                NSString *title = [shareActionSheet buttonTitleAtIndex:[buttonIndex integerValue]];
                
                SMPost *post = cell.post;
                NSString *url = [NSString stringWithFormat:URL_PROTOCOL @"//m.mysmth.net/article/%@/single/%d/0",
                                 _board.name, post.pid];

                if ([title isEqualToString:titleForWeibo]
                    || [title isEqualToString:titleForTencentWeibo]
                    || [title isEqualToString:titleForTwitter]) {
                    NSString *serviceType = [title isEqualToString:titleForWeibo] ? SLServiceTypeSinaWeibo : [title isEqualToString:titleForTencentWeibo] ? SLServiceTypeTencentWeibo : SLServiceTypeTwitter;
                    SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:serviceType];
                    NSInteger twitterWeiboSize = 140;
                    [vc setInitialText:[post.content substringToIndex:MIN(post.content.length, twitterWeiboSize)]];
                    [vc addURL:[NSURL URLWithString:url]];
                    
                    [self presentModalViewController:vc animated:YES];
                }
            }];
            [shareActionSheet showInView:self.view];
        } else if ([title isEqualToString:titleForMail]) {  // mail
            [self mailtoWithPost:cell.post];
        }
        @strongify(self);
        [self hidePostCellActions];
    }];
    [actionSheet showInView:self.view];
}

- (void)hidePostCellActions
{
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SMPostGroupContentCell class]]) {
            SMPostGroupContentCell *cell = obj;
            [cell hideActionView];
        }
    }];
}

- (void)mailtoWithPost:(SMPost *)post
{
    if (![SMAccountManager instance].isLogin) {
        [self performSelectorAfterLogin:NULL];  // todo
        return ;
    }
    
    SMMailComposeViewController *vc = [[SMMailComposeViewController alloc] init];
    SMMailItem *mail = [SMMailItem new];
    mail.title = post.title;
    mail.content = post.content;
    mail.author = post.author;
    vc.mail = mail;
    
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:vc];
    [self.view.window.rootViewController presentModalViewController:nvc animated:YES];
}

#pragma mark - SMPostFailCellDelegate
- (void)postFailCellOnRetry:(SMPostFailCell *)cell
{
    SMPostItem *item = cell.item;
    SMPost *post = item.post;
    NSString *url = [NSString stringWithFormat:URL_PROTOCOL @"//m.mysmth.net/article/%@/single/%d/0", _board.name, post.pid];

    [item.op cancel];

    SMWebLoaderOperation *op = [[SMWebLoaderOperation alloc] init];
    op.highPriority = YES;
    op.delegate = self;
    item.op = op;
    
    [op loadUrl:url withParser:@"bbscon,util_notice"];

    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];

    [SMUtils trackEventWithCategory:@"postgroup" action:@"retry_cell" label:_board.name];
}

#pragma mark - SMPageCellDelegate
- (void)pageCellDoRetry:(SMPostPageItem *)pageItem
{
    [self loadPageData:pageItem];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.destructiveButtonIndex && buttonIndex >= 0) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:STRING_EXPAND_HERE]) {
            _gid = _singlePost.gid;
            _start = _singlePost.pid;
            _isSinglePost = NO;
            [self.postHeightMap removeAllObjects];
            [_tableView beginRefreshing];
            [SMUtils trackEventWithCategory:@"postgroup" action:@"expand" label:@"here"];
        } else if ([title isEqualToString:STRING_EXPAND_ALL]) {
            SMPostViewControllerV2 *vc = [SMPostViewControllerV2 new];
            vc.post = _singlePost;
            [self.navigationController pushViewController:vc animated:YES];
            /*
            _gid = _singlePost.gid;
            _start = _singlePost.gid;
            _isSinglePost = NO;
            [self.postHeightMap removeAllObjects];
            [_tableView beginRefreshing];
             */
            [SMUtils trackEventWithCategory:@"postgroup" action:@"expand" label:@"all"];
        } else {
            SMBoardViewController *vc = [[SMBoardViewController alloc] init];
            vc.board = _board;
            
            if ([SMUtils isPad]) {
                [[SMMainViewController instance] setRootViewController:vc];
            } else {
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            [SMUtils trackEventWithCategory:@"postgroup" action:@"enter_board" label:_board.name];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *text = [alertView textFieldAtIndex:0].text;
        if (text.length != 0) {
            _forwardOp = [[SMWebLoaderOperation alloc] init];

            NSString *formUrl = URL_PROTOCOL @"//www.mysmth.net/bbsfwd.php?do";
            SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:formUrl]];
            
            NSString *postBody = [NSString stringWithFormat:@"board=%@&id=%d&target=%@&noansi=1", self.board.name, _replyPost.pid, [SMUtils encodeurl:text]];
            [request setRequestMethod:@"POST"];
            [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
            [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
            
            _forwardOp.delegate = self;
            [_forwardOp loadRequest:request withParser:@"bbsfwd"];
        }
    }
}

#pragma mark - Full post viewer
- (void)showFullPostWithHtml:(NSString *)html
{
    [self.webViewForFullPost loadHTMLString:html baseURL:nil];

    UIView *window = [UIApplication sharedApplication].keyWindow;
    
    CGFloat angle = 0;
    CGRect frame = window.bounds;
    
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    if (o == UIDeviceOrientationUnknown) {
        o = (UIDeviceOrientation) [[UIApplication sharedApplication] statusBarOrientation];
    }
    
    if (o == UIDeviceOrientationLandscapeLeft) {
        angle = M_PI_2;
    }
    if (o == UIDeviceOrientationLandscapeRight){
        angle = -M_PI_2;
    }
    
    self.viewForFullPostContainer.transform = CGAffineTransformMakeRotation(angle);
    self.viewForFullPostContainer.frame = frame;
    [window addSubview:self.viewForFullPostContainer];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSString *js = @"window.location.href='#tail'";
        [self.webViewForFullPost stringByEvaluatingJavaScriptFromString:js];
    });
    
    self.viewForFullPostContainer.hidden = NO;
    self.webViewForFullPost.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.webViewForFullPost.alpha = 1;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

- (IBAction)closeFullPost
{
    self.viewForFullPostContainer.hidden = YES;
    [self.viewForFullPostContainer removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

@end

///////////////////////////////////////////////////////////////
@implementation SMPostItem
@end

@implementation SMPostPageItem
@end

