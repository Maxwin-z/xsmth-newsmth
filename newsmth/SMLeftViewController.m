//
//  SMLeftViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMLeftViewController.h"
#import "SMMainViewController.h"
#import "SMMainpageViewController.h"
#import "SMFavorListViewController.h"
#import "SMAccountManager.h"
#import "SMUserViewController.h"
#import "SMSectionViewController.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeTop,
    CellTypeUser,
    CellTypeFavor,
    CellTypeSections
};

@interface SMLeftViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *cellTypes;
@end

@implementation SMLeftViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAccountNotification) name:NOTIFICATION_ACCOUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActivity) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
}

- (void)onAccountNotification
{
    [self.tableView reloadData];
}

- (void)onBecomeActivity
{
    SMWebLoaderOperation *keepLoginOp = [[SMWebLoaderOperation alloc] init];
    [keepLoginOp loadUrl:@"http://m.newsmth.net/user/query/" withParser:nil];
}

#pragma mark - UITableViewDataSource/Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _cellTypes = @[@(CellTypeUser), @(CellTypeSections), @(CellTypeFavor), @(CellTypeTop)];
    return _cellTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_id"];
    
    UIView *seperator = [[UIView alloc] init];
    CGRect frame = cell.contentView.bounds;
    seperator.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
    seperator.backgroundColor = SMRGB(224, 224, 224);
    seperator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [cell.contentView addSubview:seperator];
    
    CellType cellType = [_cellTypes[indexPath.row] intValue];
    
    NSString *text;
    if (cellType == CellTypeTop) {
        text = @"首页";
    } else if (cellType == CellTypeFavor) {
        text = @"收藏";
    } else if (cellType == CellTypeUser) {
        NSString *user = [SMAccountManager instance].name;
        text = user == nil ? @"guest" : user;
    } else if (cellType == CellTypeSections) {
        text = @"分区";
    }
    
    cell.textLabel.text = text;
    cell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CellType cellType = [_cellTypes[indexPath.row] intValue];

    NSString *evt = @"";
    SMViewController *vc = [SMMainpageViewController instance];
    if (cellType == CellTypeTop) {
        vc = [SMMainpageViewController instance];
        evt = @"home";
    } else if (cellType == CellTypeFavor) {
        vc = [SMFavorListViewController instance];
        evt = @"favor";
    } else if (cellType == CellTypeUser) {
        vc = [[SMUserViewController alloc] init];
        evt = @"user";
    } else if (cellType == CellTypeSections) {
        SMSectionViewController *tvc = [SMSectionViewController instance];
        tvc.url = @"http://m.newsmth.net/section";
        vc = tvc;
        evt = @"section";
    }
    
    [[SMMainViewController instance] setRootViewController:vc];
    [[SMMainViewController instance] setLeftVisiable:NO];
    
    [SMUtils trackEventWithCategory:@"left" action:evt label:nil];
}

@end
