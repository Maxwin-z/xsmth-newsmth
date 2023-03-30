//
//  SMFavorListViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMFavorListViewController.h"
#import "SMLoginViewController.h"
#import "XPullRefreshTableView.h"
#import "SMBoardViewController.h"
#import "SMFavor.h"
#import "SMBoard.h"
#import "SMMainViewController.h"
#import "SMOfflineFavorTableViewController.h"

static SMFavorListViewController *_instance;

@interface SMFavorListViewController ()
@property (strong, nonatomic) SMWebLoaderOperation *favorListOp;
@property (strong, nonatomic) NSArray *boards;
@end

@implementation SMFavorListViewController

+ (SMFavorListViewController *)instance
{
    if (_instance == nil) {
        _instance = [[SMFavorListViewController alloc] init];
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountChanged) name:NOTIFICATION_ACCOUT object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title.length == 0) {
        self.title = @"收藏";
    }
    if (self.url == nil) {
        self.url = URL_PROTOCOL @"//m.newsmth.net/favor";
    }
    [self accountChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"水木收藏夹", @"本地收藏"]];
    self.navigationItem.titleView = sc;
    sc.selectedSegmentIndex = 0;
    
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

- (void)accountChanged
{
    if ([SMAccountManager instance].isLogin) {
        self.tableView.hidden = NO;
        [self.tableView beginRefreshing];
        [self hideLogin];
        
        [SMUtils trackEventWithCategory:@"favor" action:@"refresh" label:nil];
    } else {
        self.tableView.hidden = YES;
        [self showLogin];
    }
}
@end
