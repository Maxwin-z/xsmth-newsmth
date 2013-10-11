//
//  SMSettingViewController.m
//  newsmth
//
//  Created by Maxwin on 13-10-2.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMSettingViewController.h"
#import "SMMailComposeViewController.h"
#import <MessageUI/MessageUI.h>

#define MAX_CELL_COUNT  4

typedef enum {
    CellTypeHideTop,
    CellTypeUserClickable,
    CellTypeEnableQMD,
    CellTypeSwipeBack,
    CellTypeBackgroundFetch,
    
    CellTypeFeedback,
    CellTypeRate
}CellType;

typedef enum {
    SectionTypeBoard,
    SectionTypeBackgroundFetch,
    SectionTypeInteract,
    SectionTypeMore
}SectionType;

typedef struct {
    SectionType sectionType;
    char *title;
    char *footer;
    int cellCount;
    CellType cells[MAX_CELL_COUNT];
}SectionData;

static SectionData sections[] = {
    {
        SectionTypeBoard,
        "浏览",
        NULL,
        3,
        {CellTypeHideTop, CellTypeUserClickable, CellTypeEnableQMD}
    },
    {
        SectionTypeInteract,
        "右滑返回",
        "iOS7系统默认支持右滑返回，需要从屏幕最左边滑动。不习惯的用户请禁用此项。",
        1,
        {CellTypeSwipeBack}
    },
    {
        SectionTypeBackgroundFetch,
        "后台获取最新消息",
        "iOS7支持后台定时获取网络数据，一般间隔10min。一天流量大约100kB。需要登录。",
        1,
        {CellTypeBackgroundFetch}
    },
    {
        SectionTypeMore,
        "其他",
        NULL,
        2,
        {CellTypeFeedback, CellTypeRate}
    }
};


@interface SMSettingViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewForTableViewHeader;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForHideTop;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForUserClickable;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForShowQMD;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForBackgroundFetch;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForFeedback;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForRate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForSwipeBack;

@property (weak, nonatomic) IBOutlet UILabel *labelForAppVersion;
@property (weak, nonatomic) IBOutlet UISwitch *switchForHideTop;
@property (weak, nonatomic) IBOutlet UISwitch *switchForUserClickable;
@property (weak, nonatomic) IBOutlet UISwitch *switchForShowQMD;
@property (weak, nonatomic) IBOutlet UISwitch *switchForBackgroundFetch;
@property (weak, nonatomic) IBOutlet UISwitch *switchForSwipeBack;


@end

@implementation SMSettingViewController

- (id)init
{
    self = [super initWithNibName:@"SMSettingViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"更多";
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.tableHeaderView = _viewForTableViewHeader;

    _labelForAppVersion.text = [NSString stringWithFormat:@"xsmth %@ @Maxwin", [SMUtils appVersionString]];
    
    _switchForHideTop.on = [SMConfig disableShowTopPost];
    _switchForUserClickable.on = [SMConfig enableUserClick];
    _switchForSwipeBack.on = [SMConfig enableIOS7SwipeBack];
    _switchForBackgroundFetch.on = [SMConfig enableBackgroundFetch];
    
    if ([SMUtils systemVersion] < 7) {
        _switchForBackgroundFetch.on = _switchForSwipeBack.on = NO;
        _switchForBackgroundFetch.enabled = _switchForSwipeBack.enabled = NO;
    }
}

- (IBAction)onSwitchValueChanged:(UISwitch *)sender
{
    XLog_d(@"%@, %d", sender, sender.on);
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (sender == _switchForHideTop) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_HIDE_TOP_POST];
    }
    if (sender == _switchForShowQMD) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_SHOW_QMD];
    }
    if (sender == _switchForUserClickable) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_USER_CLICKABLE];
    }
    if (sender == _switchForSwipeBack) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_IOS7_SWIPE_BACK];
    }
    if (sender == _switchForBackgroundFetch) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_BACKGROUND_FETCH];
    }
}

#pragma mark - UITableViewDataSource/Delegate
- (UITableViewCell *)cellForType:(CellType)type;
{
    switch (type) {
        case CellTypeHideTop:
            return _cellForHideTop;
        case CellTypeUserClickable:
            return _cellForUserClickable;
        case CellTypeEnableQMD:
            return _cellForShowQMD;
            
        case CellTypeSwipeBack:
            return _cellForSwipeBack;
            
        case CellTypeBackgroundFetch:
            return _cellForBackgroundFetch;
            
        case CellTypeFeedback:
            return _cellForFeedback;
        case CellTypeRate:
            return _cellForRate;
            
        default:
            return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sizeof(sections) / sizeof(SectionData);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sections[section].cellCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    char *title = sections[section].title;
    if (title != NULL) {
        return [NSString stringWithUTF8String:title];
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    char *title = sections[section].footer;
    if (title != NULL) {
        return [NSString stringWithUTF8String:title];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType cellType = sections[indexPath.section].cells[indexPath.row];
    return [self cellForType:cellType];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CellType cellType = sections[indexPath.section].cells[indexPath.row];
    if (cellType == CellTypeFeedback) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"邮件", @"站内信", nil];
        [actionSheet showInView:self.view];
    }
    
    if (cellType == CellTypeRate) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/xsmth-shui-mu-she-qu/id669036871?ls=1&mt=8"]];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    XLog_d(@"%d", buttonIndex);
    if (buttonIndex == 0) { // mail
        if (![MFMailComposeViewController canSendMail]) {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备未设置邮件帐号。请至“系统设置”-“邮件”设置邮件账户" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return ;
        }
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setToRecipients:@[@"zwd2005@gmail.com"]];
        [mail setSubject:@"[xsmth v1.2]意见与反馈"];
        [self.navigationController presentModalViewController:mail animated:YES];
    }
    if (buttonIndex == 1) { // 站内信
        [self doSendMail];
    }
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [SMUtils trackEventWithCategory:@"setting" action:@"feedback" label:@"cancel"];
    }
}

- (void)doSendMail
{
    if (![SMAccountManager instance].isLogin) {
        [self performSelectorAfterLogin:@selector(doSendMail)];
        return ;
    }
    SMMailComposeViewController *mailComposeViewController = [[SMMailComposeViewController alloc] init];
    SMMailItem *mail = [[SMMailItem alloc] init];
    mail.author = @"Maxwin";
    mail.title = @"[xsmth v1.2]意见与反馈";
    mailComposeViewController.mail = mail;
    
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:mailComposeViewController];
    [self.navigationController presentModalViewController:nvc animated:YES];
    
    [SMUtils trackEventWithCategory:@"setting" action:@"feedback" label:@"sm_mail"];
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // do nothing
    if (error != nil) {
        [self toast:[NSString stringWithFormat:@"%@", error.userInfo]];
    } else {
        [SMUtils trackEventWithCategory:@"setting" action:@"feedback" label:@"mail"];
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
