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
        self.url = @"http://m.newsmth.net/favor";
    }
    if ([SMConfig is2]) {
        self.url = @"http://www.2.newsmth.net/bbsfav.php?select=0";
    }
    [self accountChanged];
}

- (void)onSwitchSite
{
    [super onSwitchSite];
    self.url = [SMConfig is2] ? @"http://www.2.newsmth.net/bbsfav.php?select=0" : @"http://m.newsmth.net/favor";
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
