//
//  SMBoardSearchDelegateImpl.m
//  newsmth
//
//  Created by Maxwin on 13-10-11.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBoardSearchDelegateImpl.h"
#import "SMBoardViewController.h"

@implementation SMBoardSearchDelegateImpl
{
    NSArray *boards;
    NSArray *filters;
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
//    if ([self.mainpage.searchDisplayController.searchBar.text isEqualToString:@" "]) {
//        filters = [SMConfig historyBoards];
//        [self.mainpage.searchDisplayController.searchResultsTableView reloadData];
//    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filters.count;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString
{
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if (searchString.length) {
        NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"(name contains[cd] %@) or (cnName contains[cd] %@)",
                                        searchString, searchString];
        filters = [boards filteredArrayUsingPredicate:resultPredicate];
    } else {
        filters = [SMConfig historyBoards];
    }
    
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    NSDictionary *board = filters[indexPath.row];
    cell.textLabel.text = board[@"name"];
    cell.detailTextLabel.text = board[@"cnName"];
    cell.backgroundColor = [SMTheme colorForBackground];
    cell.textLabel.textColor = [SMTheme colorForPrimary];
    cell.detailTextLabel.textColor = [SMTheme colorForSecondary];
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
    
//    [SMUtils trackEventWithCategory:@"boardsearch" action:@"enterBoard" label:self.mainpage.searchDisplayController.searchBar.text];
}

//- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
//{
//    controller.searchBar.hidden = YES;
//}
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    [self performSelector:@selector(showHis) withObject:nil afterDelay:0.1];
//}
//
//- (void)showHis
//{
//    if (self.mainpage.searchDisplayController.searchBar.text.length == 0) {
//        self.mainpage.searchDisplayController.searchBar.text = @" ";
//    }
//}

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
        filters = [boards filteredArrayUsingPredicate:resultPredicate];
    } else {
        filters = [SMConfig historyBoards];
    }
    [self.resultTableView reloadData];
}
@end
