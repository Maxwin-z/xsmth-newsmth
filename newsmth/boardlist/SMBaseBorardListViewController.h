//
//  SMBaseBorardListViewController.h
//  newsmth
//
//  Created by Maxwin on 13-7-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import "XPullRefreshTableView.h"

@interface SMBaseBorardListViewController : SMViewController
@property (strong, nonatomic) NSString *url;
@property (weak, nonatomic) IBOutlet XPullRefreshTableView *tableView;

- (void)loadData;
@end
