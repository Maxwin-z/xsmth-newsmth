//
//  SMPostGroupViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-30.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostGroupViewController.h"
#import "XPullRefreshTableView.h"

@interface SMPostGroupItem : NSObject
@property (strong, nonatomic) NSString *nick;
@property (strong, nonatomic) SMWebLoaderOperation *op;
@end
@implementation SMPostGroupItem
@end

////////////////////////////////////////////////

@interface SMPostGroupViewController ()<UITableViewDataSource, UITableViewDelegate, XPullRefreshTableViewDelegate, SMWebLoaderOperationDelegate>
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;

// data
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) SMWebLoaderOperation *pageOp; // 分页加载数据用op

@property (assign, nonatomic) NSInteger bid;    // board id
@property (assign, nonatomic) NSInteger tpage;  // total page
@property (assign, nonatomic) NSInteger pno;    // current page

@end

@implementation SMPostGroupViewController

- (id)init
{
    self = [super initWithNibName:@"SMPostGroupViewController" bundle:nil];
    if (self) {
        _pno = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.xdelegate = self;
    [self loadData:NO];
}

- (void)loadData:(BOOL)more
{
    if (!more) {
        _pno = 1;
    } else {
        ++_pno;
    }
    NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbstcon.php?board=%@&gid=%d&start=%d&pno=%d", _board, _gid, _gid, _pno];
    _pageOp = [[SMWebLoaderOperation alloc] init];
    _pageOp.delegate = self;
    [_pageOp loadUrl:url withParser:@"bbstcon"];
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource/Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    if (row % 2 == 0) {
        return [self cellForTitleAtRow:row / 2];
    } else {
        return [self cellForContentAtRow:row / 2];
    }
}

- (UITableViewCell *)cellForTitleAtRow:(NSInteger)row
{
    SMPostGroupItem *item = _items[row];
    NSString *cellid = @"title_cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.textLabel.text = item.nick;
    return cell;
}

- (UITableViewCell *)cellForContentAtRow:(NSInteger)row
{
    SMPostGroupItem *item = _items[row];
    NSString *cellid = @"content_cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    if (item.op.result != nil) {
        NSDictionary *data = [item.op.result objectForKey:@"data"];
        cell.textLabel.text = [data objectForKey:@"content"];
    } else {
        cell.textLabel.text = @"Loading";
    }
    return cell;
}

#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData:NO];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    if (opt == _pageOp) {
        // add post to postOps
        NSDictionary *data = [opt.result objectForKey:@"data"];
        NSMutableArray *tmp;
        if (_pno == 1) {    // first page
            [self.tableView endRefreshing:YES];
            tmp = [[NSMutableArray alloc] initWithCapacity:0];
            _bid = [[data objectForKey:@"bid"] intValue];
        } else {
            tmp = [_items mutableCopy];
        }
        NSArray *posts = [data objectForKey:@"posts"];
        [posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSInteger pid = [[obj objectForKey:@"id"] intValue];
            NSString *nick = [obj objectForKey:@"nick"];
            
            NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbscon.php?bid=%d&id=%d", _bid, pid];
            SMWebLoaderOperation *op = [[SMWebLoaderOperation alloc] init];
            op.delegate = self;
            [op loadUrl:url withParser:@"bbscon"];
            
            SMPostGroupItem *item = [[SMPostGroupItem alloc] init];
            item.nick = nick;
            item.op = op;
            [tmp addObject:item];
        }];
        self.items = tmp;
    } else {
        [self.tableView reloadData];
    }
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    XLog_e(@"%@", error);
}


@end
