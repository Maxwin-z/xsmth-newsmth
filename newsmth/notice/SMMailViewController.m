//
//  SMMailViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-28.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMailViewController.h"
#import "XPullRefreshTableView.h"
#import "SMMailCell.h"

@interface SMMailViewController ()<SMWebLoaderOperationDelegate, XPullRefreshTableViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger tpage;

@property (strong, nonatomic) SMWebLoaderOperation *mailOp;
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;
@property (strong, nonatomic) NSArray *mails;
@end

@implementation SMMailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"邮箱";
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
    NSString *url = [NSString stringWithFormat:@"http://m.newsmth.net/mail/inbox?p=%d", _page];
    
    [_mailOp cancel];
    _mailOp = [[SMWebLoaderOperation alloc] init];
    _mailOp.delegate = self;
    [_mailOp loadUrl:url withParser:@"mail"];
}

- (void)setMails:(NSArray *)mails
{
    _mails = mails;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMMailItem *item = _mails[indexPath.row];
    return [SMMailCell cellHeight:item];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"mail_cell";
    SMMailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SMMailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SMMailItem *item = _mails[indexPath.row];
    cell.item = item;
    
    if (indexPath.row == _mails.count - 1 && _page < _tpage) {
        [self loadData:YES];
    }
    
    return cell;
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    XLog_d(@"%@", opt.data);
    [_tableView endRefreshing:YES];

    SMMailList *mailList = opt.data;

    NSMutableArray *tmp;
    if (_page == 1) {
        _tpage = mailList.tpage;
        tmp = [[NSMutableArray alloc] init];
    } else {
        tmp = [_mails mutableCopy];
    }
    
    [tmp addObjectsFromArray:mailList.items];
    self.mails = tmp;
    
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
