//
//  SMFavorListViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMFavorListViewController.h"
#import "SMLoginViewController.h"
#import "XPullRefreshTableView.h"
#import "SMBoardViewController.h"
#import "SMFavor.h"
#import "SMBoard.h"

static SMFavorListViewController *_instance;

@interface SMFavorListViewController ()<SMWebLoaderOperationDelegate, XPullRefreshTableViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonForLogin;

@property (strong, nonatomic) SMWebLoaderOperation *favorListOp;
@property (strong, nonatomic) NSArray *boards;
@end

@implementation SMFavorListViewController

+ (SMFavorListViewController *)instance
{
    if (_instance == nil) {
        _instance = [[SMFavorListViewController alloc] init];
    }
    return _instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"收藏";
    _tableView.xdelegate = self;
    [self accountChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath) {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)accountChanged
{
    if ([SMAccountManager instance].isLogin) {
        _tableView.hidden = NO;
        _buttonForLogin.hidden = YES;
        [_tableView beginRefreshing];
    } else {
        _tableView.hidden = YES;
        _buttonForLogin.hidden = NO;
    }
}

- (void)loadData
{
    _favorListOp = [[SMWebLoaderOperation alloc] init];
    _favorListOp.delegate = self;
    [_favorListOp loadUrl:@"http://m.newsmth.net/favor" withParser:@"favor"];
}

- (void)setBoards:(NSArray *)boards
{
    _boards = boards;
    [self.tableView reloadData];
}

- (IBAction)onLoginButtonClick:(id)sender
{
    [self performSelectorAfterLogin:@selector(accountChanged)];
}

#pragma mark - UITableDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _boards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"boardcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    SMBoard *board = _boards[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", board.cnName, board.name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBoard *board = _boards[indexPath.row];
    SMBoardViewController *boardVc = [[SMBoardViewController alloc] init];
    boardVc.board = board;
    [self.navigationController pushViewController:boardVc animated:YES];
}

#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [_tableView endRefreshing:YES];
    SMFavor *favor = opt.data;
    self.boards = favor.boards;
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [_tableView endRefreshing:NO];
    [self toast:error.message];
}

@end
