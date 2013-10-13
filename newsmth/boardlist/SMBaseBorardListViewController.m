//
//  SMBaseBorardListViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBaseBorardListViewController.h"
#import "XPullRefreshTableView.h"
#import "SMBoardViewController.h"

@interface SMBaseBorardListViewController ()<SMWebLoaderOperationDelegate, UITableViewDataSource, UITableViewDelegate, XPullRefreshTableViewDelegate>
@property (strong, nonatomic) SMWebLoaderOperation *listOp;

@property (strong, nonatomic) NSArray *items;
@end

@implementation SMBaseBorardListViewController

- (id)init
{
    self = [super initWithNibName:@"SMBaseBorardListViewController" bundle:nil];
    return self;
}

- (void)dealloc
{
    [_listOp cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.xdelegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath) {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)loadData
{
    [_listOp cancel];
    _listOp = [[SMWebLoaderOperation alloc] init];
    _listOp.delegate = self;
    [_listOp loadUrl:_url withParser:@"boardlist,util_notice"];
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f + [SMConfig listFont].lineHeight - [UIFont systemFontOfSize:15].lineHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        cell.backgroundColor = [UIColor clearColor];
    }

    cell.textLabel.font = [SMConfig listFont];
    
    SMBoardListItem *item = _items[indexPath.row];
    if (item.isDir) {
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = @"目录";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = item.board.cnName;
        cell.detailTextLabel.text = item.board.name;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBoardListItem *item = _items[indexPath.row];
    if (item.isDir) {
        SMBaseBorardListViewController *vc = [[[self class] alloc] init];
        vc.url = item.url;
        vc.title = item.title;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        SMBoardViewController *vc = [[SMBoardViewController alloc] init];
        vc.board = item.board;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [self.tableView endRefreshing:YES];
    SMBoardList *boardList = opt.data;
    self.items = boardList.items;
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self.tableView endRefreshing:NO];
    [self toast:error.message];
}

@end
