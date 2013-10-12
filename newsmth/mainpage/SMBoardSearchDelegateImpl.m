//
//  SMBoardSearchDelegateImpl.m
//  newsmth
//
//  Created by Maxwin on 13-10-11.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBoardSearchDelegateImpl.h"
#import "AMBlurView.h"

@implementation SMBoardSearchDelegateImpl
{
    NSArray *boards;
    NSArray *filters;
}

- (id)init
{
    self = [super init];
    if (self) {
        boards = filters = @[@{@"name":@"Civilization",@"title": @"文明"},@{@"name":@"CrossGate",@"title": @"魔力宝贝"},@{@"name":@"CStrike",@"title": @"反恐精英"},@{@"name":@"Diablo",@"title": @"暗黑破坏神"},@{@"name":@"DotaAllstars",@"title": @"Dota爱好者"},@{@"name":@"Falcom",@"title": @"Falcom之家"},@{@"name":@"GalGame",@"title": @"美少女游戏"},@{@"name":@"Game",@"title": @"电脑游戏"},@{@"name":@"GameIndustry",@"title": @"游戏圈"},@{@"name":@"Heroes",@"title": @"魔法门之英雄无敌"},@{@"name":@"KOEI",@"title": @"光荣游戏"},@{@"name":@"LOL",@"title": @"英雄联盟"},@{@"name":@"MonsterHunter",@"title": @"怪物猎人"},@{@"name":@"Mud",@"title": @"网络泥巴"},@{@"name":@"OnlineGame",@"title": @"网络游戏"},@{@"name":@"PalSword",@"title": @"御剑江湖"},@{@"name":@"SimulateFlight",@"title": @"模拟飞行"},@{@"name":@"SportsGame",@"title": @"体育游戏"},@{@"name":@"StarCraft",@"title": @"星际争霸"},@{@"name":@"StarCraftII",@"title": @"星际争霸2"},@{@"name":@"TouHou",@"title": @"东方幻想乡"},@{@"name":@"TVGame",@"title": @"视频游戏"},@{@"name":@"WarCraft",@"title": @"魔兽争霸"},@{@"name":@"WebGame",@"title": @"网页游戏"},@{@"name":@"WesternRPG",@"title": @"欧美RPG"},@{@"name":@"WoW",@"title": @"魔兽世界"}];
    }
    return self;
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
                                        predicateWithFormat:@"(name contains[cd] %@)",
                                        searchString];
        filters = [boards filteredArrayUsingPredicate:resultPredicate];
    } else {
        filters = boards;
    }
    
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    NSDictionary *board = filters[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", board[@"name"], board[@"title"]];
    return cell;
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
