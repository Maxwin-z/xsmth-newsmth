//
//  SMMainpageViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMainpageViewController.h"
#import "XPullRefreshTableView.h"

@interface SMMainpageViewController ()<UITableViewDataSource, UITableViewDelegate, SMWebLoaderOperationDelegate, XPullRefreshTableViewDelegate>
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;

@property (strong, nonatomic) SMWebLoaderOperation *op;

@property (strong, nonatomic) NSArray *sections;
@end

@implementation SMMainpageViewController

- (id)init
{
    self = [super initWithNibName:@"SMMainpageViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.xdelegate = self;
    [_tableView beginRefreshing];
}

- (void)setSections:(NSArray *)sections
{
    _sections = sections;
    [self.tableView reloadData];
}

- (void)dealloc
{
    [_op cancel];
}

- (void)loadData:(BOOL)more
{
    _op = [[SMWebLoaderOperation alloc] init];
    _op.delegate = self;
    [_op loadUrl:@"http://www.newsmth.net/mainpage.html" withParser:@"mainpage"];
}
#pragma mark - XPullRefreshTableViewDelegate
- (void)tableViewDoRefresh:(XPullRefreshTableView *)tableView
{
    [self loadData:NO];
}

#pragma mark - UITableViewDataSource/Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_sections[section] objectForKey:@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    NSDictionary *item = [[_sections[indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"title"];
    
    return cell;
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [_tableView endRefreshing:YES];
    NSDictionary *result = opt.result;
    int code = [[result objectForKey:@"code"] intValue];
    if (code == 0) {
        self.sections = [result objectForKey:@"data"];
    }
}

@end
