//
//  SMBoardHistoryViewController.m
//  newsmth
//
//  Created by WenDong on 2019/10/13.
//  Copyright © 2019 nju. All rights reserved.
//

#import "SMBoardHistoryViewController.h"

@interface SMBoardResultController : UITableViewController
@end
@implementation SMBoardResultController
@end

@interface SMBoardHistoryViewController () <UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) SMBoardResultController *resultController;
@end

@implementation SMBoardHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultController = [SMBoardResultController new];
    self.resultController.tableView.dataSource = self;
    self.resultController.tableView.delegate = self;
    [self.resultController.tableView reloadData];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchResultsUpdater = self;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.navigationItem.searchController = self.searchController;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"board";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    return cell;
}

#pragma mark - UISearchResyltsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
}


@end
