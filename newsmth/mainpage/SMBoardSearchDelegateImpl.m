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
    filters = [SMConfig historyBoards];
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
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    controller.searchBar.hidden = YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self performSelector:@selector(showHis) withObject:nil afterDelay:0.1];
}

- (void)showHis
{
    self.mainpage.searchDisplayController.searchBar.text = @" ";
}


@end
