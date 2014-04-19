//
//  SMPostLinksViewController.m
//  newsmth
//
//  Created by Maxwin on 14-4-6.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMPostLinksViewController.h"
#import "PBWebViewController.h"

@interface SMPostLinksViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation SMPostLinksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"访问链接";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.contentInset = self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(SM_TOP_INSET, 0, 0, 0);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setupTheme
{
    [super setupTheme];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.post.links.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static UITableViewCell *cell;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
    }
    
    CGRect frame = cell.frame;
    frame.size.width = self.tableView.frame.size.width;
    cell.frame = frame;
    
    cell.textLabel.text = @"Hello";
    [cell layoutIfNeeded];
    
    CGFloat delta = 20;
    
    NSString *link = self.post.links[indexPath.row];
    CGFloat height = [link smSizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(cell.textLabel.frame.size.width, CGFLOAT_MAX) lineBreakMode:cell.textLabel.lineBreakMode].height + delta;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
    }
    
    cell.contentView.backgroundColor = [SMTheme colorForBackground];
    cell.textLabel.backgroundColor = [SMTheme colorForBackground];
    cell.textLabel.textColor = [SMTheme colorForPrimary];
    
    NSString *link = self.post.links[indexPath.row];
    cell.textLabel.text = link;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *link = self.post.links[indexPath.row];
    if ([[link lowercaseString] hasSuffix:@".mp4"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
    } else {
        PBWebViewController *webView = [[PBWebViewController alloc] init];
        webView.URL = [NSURL URLWithString:link];
        [self.navigationController pushViewController:webView animated:YES];
    }

}
@end
