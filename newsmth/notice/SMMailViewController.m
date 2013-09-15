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
#import "SMMailInfoViewController.h"
#import "SMNoticeViewController.h"

@interface SMMailViewController ()<SMWebLoaderOperationDelegate, XPullRefreshTableViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger tpage;

@property (strong, nonatomic) SMWebLoaderOperation *mailOp;
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewForTableHeader;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) NSArray *mails;
@end

@implementation SMMailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"邮箱";
    _tableView.xdelegate = self;
    _tableView.tableHeaderView = _viewForTableHeader;
    [self loadData:NO];
}

- (void)loadData:(BOOL)more
{
    if (!more) {
        _page = 1;
    } else {
        ++_page;
    }
    
    NSString *mailType = @"inbox";
    if (_segmentedControl.selectedSegmentIndex == 1) {
        mailType = @"outbox";
    }
    if (_segmentedControl.selectedSegmentIndex == 2) {
        mailType = @"deleted";
    }
    
    NSString *url = [NSString stringWithFormat:@"http://m.newsmth.net/mail/%@?p=%d", mailType, _page];
    
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

- (IBAction)onSegmentedControlValueChanged:(UISegmentedControl *)sender
{
    [self loadData:NO];
}


#pragma mark - UITableViewDataSource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _mails.count) {
        SMMailItem *item = _mails[indexPath.row];
        return [SMMailCell cellHeight:item];
    }
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mails.count == 0 ? 1 : _mails.count;
}

- (UITableViewCell *)emptyCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"没有任何信件";
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mails.count == 0) {    // empty
        return [self emptyCell];
    }

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (_mails.count > indexPath.row) {
        SMMailItem *item = _mails[indexPath.row];
        SMMailInfoViewController *mailInfoVc = [[SMMailInfoViewController alloc] init];
        mailInfoVc.mail = item;
        [[SMNoticeViewController instance].navigationController pushViewController:mailInfoVc animated:YES];
    }
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
//    XLog_d(@"%@", opt.data);
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
