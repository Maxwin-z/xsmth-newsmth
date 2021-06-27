//
//  SMBoardSearchDelegateImpl.m
//  newsmth
//
//  Created by Maxwin on 13-10-11.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBoardSearchDelegateImpl.h"
#import "SMBoardViewController.h"
#import "SMWebLoaderOperation.h"

@implementation SMBoardSearchDelegateImpl
{
    NSArray *boards;
    NSArray *filters;
    SMWebLoaderOperation *op;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"boards" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        boards = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

    }
    return self;
}

- (void)reload
{
    [self.resultTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.backgroundColor = [SMTheme colorForBackground];
    cell.textLabel.textColor = [SMTheme colorForPrimary];
    cell.detailTextLabel.textColor = [SMTheme colorForSecondary];
    
    NSDictionary *board = filters[indexPath.row];
    cell.textLabel.text = board[@"name"];
    cell.detailTextLabel.text = board[@"cnName"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *b = filters[indexPath.row];
    SMBoard *board = [[SMBoard alloc] initWithJSON:b];
    SMBoardViewController *vc = [[SMBoardViewController alloc] init];
    vc.board = board;
    [self.mainpage.navigationController pushViewController:vc animated:YES];
    [self.mainpage.navigationItem.searchController setActive:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.mainpage.navigationItem.searchController.searchBar resignFirstResponder];
}

#pragma mark - UISearchControllerDelegate
- (void)didDismissSearchController:(UISearchController *)searchController
{
    self.mainpage.navigationItem.searchController = nil;
    XLog_d(@"dissmiss search");
}

#pragma mark - UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if (searchString.length) {
        NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"(name contains[cd] %@) or (cnName contains[cd] %@)",
                                        searchString, searchString];
        filters = [boards filteredArrayUsingPredicate:resultPredicate] ;
        if (op) {
            [op cancel];
        }
        op = [SMWebLoaderOperation new];
        __block __typeof(self) weakSelf = self;
        op.onSuccess = ^(SMBaseData *data) {
            SMBoardList *bl = (SMBoardList *)data;

            NSMutableArray *bs = [weakSelf->filters mutableCopy];
            [bl.items enumerateObjectsUsingBlock:^(SMBoardListItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
                if(!item.isDir && [bs indexOfObjectPassingTest:^BOOL(NSDictionary *board, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([item.board.name isEqualToString:board[@"name"]]) {
                        *stop = YES;
                        return YES;
                    }
                    return NO;
                }] == NSNotFound) {
                    [bs addObject:@{
                        @"name": item.board.name,
                        @"cnName": item.board.cnName
                    }];
                }
            }];
            [bs sortUsingComparator:^NSComparisonResult(NSDictionary *b1, NSDictionary *b2) {
                return [b1[@"name"] compare:b2[@"name"]];
            }];
            weakSelf->filters = bs;
            [weakSelf.resultTableView reloadData];
        };
        
        if (searchString.length >= 2) {
            [op loadUrl:[NSString stringWithFormat:@"http://m.mysmth.net/go?name=%@", searchString] withParser:@"boardlist"];
        }
    } else {
        filters = [SMConfig historyBoards];
    }
    [self.resultTableView reloadData];
}
@end
