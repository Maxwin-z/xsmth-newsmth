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
#import "XWebViewController.h"
#import "SMNoticeViewController.h"
#import "SMSettingViewController.h"
#import "newsmth-Swift.h"


typedef NS_ENUM(NSInteger, CellType) {
    CellTypeTop,
    CellTypeUser,
    CellTypeFavor,
    CellTypeSections,
    CellTypeNotice,
    CellTypeSetting
};

@interface SMLeftViewController ()<UITableViewDataSource, UITableViewDelegate, SMWebLoaderOperationDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewForSetting;
@property (weak, nonatomic) IBOutlet UIButton *buttonForSetting;
@property (strong, nonatomic) NSArray *cellTypes;

@property (strong, nonatomic) SMWebLoaderOperation *keepLoginOp;
@property (strong, nonatomic) XDonateViewController *donateVC;
@end

@implementation SMLeftViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAccountNotification) name:NOTIFICATION_ACCOUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoticeNofitication) name:NOTIFICATION_NOTICE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActivity) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateProNotification) name:NOTIFYCATION_IAP_PRO object:nil];

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
    CGRect frame = _tableView.frame;
    _tableView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
    _tableView.frame = frame;
    _tableView.scrollsToTop = NO;
    
    frame = _viewForSetting.frame;
    frame.origin.y = SM_STATUS_BAR_HEIGHT;//IS_IPHONE_X ? 44.0f : 20.0f;
    _viewForSetting.frame = frame;
    [self.view addSubview:_viewForSetting];

    UIImage *image = [_buttonForSetting imageForState:UIControlStateNormal];
    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [_buttonForSetting setImage:image forState:UIControlStateNormal];
    
    if (![SMConfig isPro]) {
        self.donateVC = [XDonateViewController new];
        [self.view addSubview:self.donateVC.view];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets inset = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
        NSLog(@"%@", NSStringFromUIEdgeInsets(inset));
        self.tableView.contentInset = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([SMConfig isPro]) return ;
    CGRect frame = self.donateVC.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 150;
    frame.size.width =  self.view.size.width;
    frame.size.height = self.view.frame.size.height - 400;
    self.donateVC.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
    self.donateVC.view.frame = frame;
}

- (void)setupTheme
{
    [super setupTheme];
    [self.tableView reloadData];

    [_buttonForSetting setTitleColor:[SMTheme colorForTintColor] forState:UIControlStateNormal];
}

- (void)onAccountNotification
{
    if ([SMAccountManager instance].isLogin) {
        XLog_d(@"%@", [SMAccountManager instance].name);
        [self.buttonForSetting setTitle:[SMAccountManager instance].name forState:UIControlStateNormal];
    } else {
        [self.buttonForSetting setTitle:@"登录" forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

- (void)onUpdateProNotification
{
    [self.tableView reloadData];
}

- (void)onNoticeNofitication
{
    [self.tableView reloadData];
}

- (void)onBecomeActivity
{
    [self loadNotice];
}

- (IBAction)onMoreButtonClick:(id)sender
{
    SMUserViewController *vc = [[SMUserViewController alloc] init];
    [[SMMainViewController instance] setRootViewController:vc];
    [[SMMainViewController instance] setLeftVisiable:NO];
    [SMUtils trackEventWithCategory:@"left" action:@"user" label:nil];
}

- (void)loadNotice
{
    if ([SMAccountManager instance].isLogin) {
        XLog_d(@"load notice");
        [_keepLoginOp cancel];
        _keepLoginOp = [[SMWebLoaderOperation alloc] init];
        _keepLoginOp.delegate = self;
        [_keepLoginOp loadUrl:URL_PROTOCOL @"//m.mysmth.net/user/query/" withParser:@"notice,util_notice"];
    }
}

#pragma mark - UITableViewDataSource/Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *cellTypes = [[NSMutableArray alloc] init];
    [cellTypes addObject:@(CellTypeSetting)];
    [cellTypes addObject:@(CellTypeNotice)];
//    [cellTypes addObject:@(CellTypeUser)];
    [cellTypes addObject:@(CellTypeSections)];
    [cellTypes addObject:@(CellTypeFavor)];
    [cellTypes addObject:@(CellTypeTop)];
    
    _cellTypes = cellTypes;
    return _cellTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cell.selectedBackgroundView = selectedBackgroundView;
    cell.backgroundColor = [SMTheme colorForBackground];
    cell.textLabel.textColor = [SMTheme colorForPrimary];
    cell.selectedBackgroundView.backgroundColor = [SMTheme colorForHighlightBackground];
    
    UIImageView *seperator = [[UIImageView alloc] init];
    CGRect frame = cell.contentView.bounds;
    seperator.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
    seperator.image = [[UIImage imageNamed:@"common_divider"] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    seperator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [cell.contentView addSubview:seperator];
    cell.detailTextLabel.text = @"";
    CellType cellType = [_cellTypes[indexPath.row] intValue];
    
    NSString *text;
    if (cellType == CellTypeTop) {
        text = @"首页";
    } else if (cellType == CellTypeNotice) {
        SMNotice *notice = [SMAccountManager instance].notice;
        NSMutableArray *comps = [[NSMutableArray alloc] init];
        if (notice.at > 0) {
            [comps addObject:[NSString stringWithFormat:@"At:%d", notice.at]];
        }
        if (notice.reply > 0) {
            [comps addObject:[NSString stringWithFormat:@"Re:%d", notice.reply]];
        }
        if (notice.mail > 0) {
            [comps addObject:@"信"];
        }
        
        NSString *hint = [comps componentsJoinedByString:@", "];
        text = [NSString stringWithFormat:@"消息(%@)", hint.length > 0 ? hint : @"0"];
    } else if (cellType == CellTypeFavor) {
        text = @"收藏";
    } else if (cellType == CellTypeUser) {
        NSString *user = [SMAccountManager instance].name;
        text = user == nil ? @"guest" : user;
    } else if (cellType == CellTypeSections) {
        text = @"分区";
    } else if (cellType == CellTypeSetting) {
        text = @"设置";
//        if (![SMConfig isPro]) {
//            cell.detailTextLabel.text = @"升级到Pro版        :)";
//        }
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
    }else if (cellType == CellTypeNotice) {
        vc = [SMNoticeViewController instance];
        evt = @"notice";
    } else if (cellType == CellTypeFavor) {
        vc = [SMFavorListViewController instance];
        evt = @"favor";
    } else if (cellType == CellTypeUser) {
        vc = [[SMUserViewController alloc] init];
        evt = @"user";
    } else if (cellType == CellTypeSections) {
        SMSectionViewController *tvc = [SMSectionViewController instance];
        tvc.url = URL_PROTOCOL @"//m.mysmth.net/section";
        vc = tvc;
        evt = @"section";
    } else if (cellType == CellTypeSetting) {
        vc = [[SMSettingViewController alloc] init];
        evt = @"setting";
    }
    
    [[SMMainViewController instance] setRootViewController:vc];
    [[SMMainViewController instance] setLeftVisiable:NO];
    
    [SMUtils trackEventWithCategory:@"left" action:evt label:nil];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [SMAccountManager instance].notice = opt.data;
    [[SMMainViewController instance] setBadgeVisiable:NO];
    [[NSUserDefaults standardUserDefaults] setObject:[[SMAccountManager instance].notice encode] forKey:USERDEFAULTS_NOTICE_LATEST];
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    XLog_e(@"%@", error);
}

@end
