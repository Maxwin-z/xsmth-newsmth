//
//  SMOfflineFavorTableViewController.m
//  newsmth
//
//  Created by Maxwin on 15/9/27.
//  Copyright © 2015年 nju. All rights reserved.
//

#import "SMOfflineFavorTableViewController.h"
#import "SMMainViewController.h"
#import "SMFavorListViewController.h"

@interface SMOfflineFavorTableViewController ()

@end

@implementation SMOfflineFavorTableViewController

+ (instancetype)instance
{
    static SMOfflineFavorTableViewController *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [SMOfflineFavorTableViewController new];
    });
    return _instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    // 似乎有点丑, but...
    [super viewWillAppear:animated];
    UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"水木收藏夹", @"本地收藏"]];
    self.navigationItem.titleView = sc;
    sc.selectedSegmentIndex = 1;
    
    [sc addTarget:self action:@selector(onTitleViewSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)onTitleViewSegmentedControlValueChanged:(UISegmentedControl *)sc
{
    
    UIViewController *vc;
    if (sc.selectedSegmentIndex == 0) {
        vc = [SMFavorListViewController instance];
    } else {
        vc = [SMOfflineFavorTableViewController instance];
    }
    
    [[SMMainViewController instance] setRootViewController:vc];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
