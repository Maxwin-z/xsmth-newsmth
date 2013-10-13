//
//  SMSettingViewController.m
//  newsmth
//
//  Created by Maxwin on 13-10-2.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMSettingViewController.h"
#import "SMMailComposeViewController.h"
#import "SMFontSelectorViewController.h"
#import <MessageUI/MessageUI.h>

#define MAX_CELL_COUNT  4

typedef enum {
    CellTypeHideTop,
    CellTypeUserClickable,
    CellTypeShowReplyAuthor,
    CellTypeEnableQMD,
    CellTypeSwipeBack,
    CellTypeBackgroundFetch,
    
    CellTypeListFont,
    CellTypePostFont,
    
    CellTypeFeedback,
    CellTypeRate
}CellType;

typedef enum {
    SectionTypeBoard,
    SectionTypeBackgroundFetch,
    SectionTypeInteract,
    SectionTypePostFont,
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
        4,
        {CellTypeHideTop, CellTypeEnableQMD, CellTypeUserClickable, CellTypeShowReplyAuthor}
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
        SectionTypePostFont,
        "字体",
        NULL,
        2,
        {CellTypeListFont, CellTypePostFont}
    },
    {
        SectionTypeMore,
        "其他",
        NULL,
        2,
        {CellTypeFeedback, CellTypeRate}
    }
};


@interface SMSettingViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewForTableViewHeader;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForHideTop;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForUserClickable;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForShowReplyAuthor;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForShowQMD;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForBackgroundFetch;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForFeedback;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForRate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForSwipeBack;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForPostFont;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForListFont;

@property (weak, nonatomic) IBOutlet UILabel *labelForAppVersion;
@property (weak, nonatomic) IBOutlet UISwitch *switchForHideTop;
@property (weak, nonatomic) IBOutlet UISwitch *switchForUserClickable;
@property (weak, nonatomic) IBOutlet UISwitch *switchForShowReplyAuthor;
@property (weak, nonatomic) IBOutlet UISwitch *switchForShowQMD;
@property (weak, nonatomic) IBOutlet UISwitch *switchForBackgroundFetch;
@property (weak, nonatomic) IBOutlet UISwitch *switchForSwipeBack;

@property (weak, nonatomic) IBOutlet UILabel *labelForPostFont;
@property (weak, nonatomic) IBOutlet UISlider *sliderForPostFont;
@property (weak, nonatomic) IBOutlet UILabel *labelForListFont;
@property (weak, nonatomic) IBOutlet UISlider *sliderForListFont;

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
    _switchForShowReplyAuthor.on = [SMConfig enableShowReplyAuthor];
    _switchForSwipeBack.on = [SMConfig enableIOS7SwipeBack];
    _switchForBackgroundFetch.on = [SMConfig enableBackgroundFetch];
    _switchForShowQMD.on = [SMConfig enableShowQMD];
    
    _sliderForListFont.value = [SMConfig listFont].pointSize;
    _sliderForPostFont.value = [SMConfig postFont].pointSize;
    
    if ([SMUtils systemVersion] < 7) {
        _switchForBackgroundFetch.on = _switchForSwipeBack.on = NO;
        _switchForBackgroundFetch.enabled = _switchForSwipeBack.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView beginUpdates];
    [_tableView endUpdates];
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
    if (sender == _switchForShowReplyAuthor) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_SHOW_REPLY_AUTHOR];
    }
    if (sender == _switchForSwipeBack) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_IOS7_SWIPE_BACK];

        [def synchronize];
        [[[UIAlertView alloc] initWithTitle:@"!!注意!!" message:@"需要重启应用，使之生效" delegate:self cancelButtonTitle:@"稍后重启" otherButtonTitles:@"现在重启", nil] show];
    }
    if (sender == _switchForBackgroundFetch) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_BACKGROUND_FETCH];
    }
}

- (IBAction)onPostFontSliderValueChanged:(UISlider *)slider
{
    NSInteger size = (int)slider.value;
    if (slider == _sliderForListFont) {
        [[NSUserDefaults standardUserDefaults] setInteger:size forKey:USERDEFAULTS_LIST_FONT_SIZE];
    }
    if (slider == _sliderForPostFont) {
        [[NSUserDefaults standardUserDefaults] setInteger:size forKey:USERDEFAULTS_POST_FONT_SIZE];
    }
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

#pragma mark - cache

#pragma mark - UITableViewDataSource/Delegate
- (UITableViewCell *)cellForType:(CellType)type;
{
    switch (type) {
        case CellTypeHideTop:
            return _cellForHideTop;
            
        case CellTypeUserClickable:
            return _cellForUserClickable;
        case CellTypeShowReplyAuthor:
            return _cellForShowReplyAuthor;
            
        case CellTypeEnableQMD:
            return _cellForShowQMD;
            
        case CellTypeSwipeBack:
            return _cellForSwipeBack;
            
        case CellTypeBackgroundFetch:
            return _cellForBackgroundFetch;
            
        case CellTypeListFont:
            return _cellForListFont;
        case CellTypePostFont:
            return _cellForPostFont;
            
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType cellType = sections[indexPath.section].cells[indexPath.row];

    if (cellType == CellTypeListFont) {
        _labelForListFont.font = [SMConfig listFont];   // change font.
        _labelForListFont.text = [NSString stringWithFormat:@"列表字体预览：%@", _labelForListFont.font.familyName];
        CGFloat delta = _cellForListFont.frame.size.height - _labelForListFont.frame.size.height;
        return delta + [_labelForListFont.text smSizeWithFont:_labelForListFont.font constrainedToSize:CGSizeMake(_labelForListFont.frame.size.width, CGFLOAT_MAX) lineBreakMode:_labelForListFont.lineBreakMode].height;
    }

    if (cellType == CellTypePostFont) {
        _labelForPostFont.font = [SMConfig postFont];   // change font.
        _labelForPostFont.text = [NSString stringWithFormat:@"文章字体预览：%@", _labelForPostFont.font.familyName];
        CGFloat delta = _cellForPostFont.frame.size.height - _labelForPostFont.frame.size.height;
        return delta + [_labelForPostFont.text smSizeWithFont:_labelForPostFont.font constrainedToSize:CGSizeMake(_labelForPostFont.frame.size.width, CGFLOAT_MAX) lineBreakMode:_labelForPostFont.lineBreakMode].height;
    }
    return 44.0f;
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
    
    if (cellType == CellTypePostFont || cellType == CellTypeListFont) {
        SMFontSelectorViewController *vc = [[SMFontSelectorViewController alloc] init];
        __weak SMSettingViewController *weakSelf = self;
        vc.fontSelectedBlock = ^(NSString *fontName) {
            [[NSUserDefaults standardUserDefaults] setObject:fontName forKey:cellType == CellTypePostFont ? USERDEFAULTS_POST_FONT_FAMILY : USERDEFAULTS_LIST_FONT_FAMILY];
            [weakSelf.tableView reloadData];
        };
        vc.selectedFont = cellType == CellTypePostFont ? [SMConfig postFont] : [SMConfig listFont];
        P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:vc];
        [self.navigationController presentModalViewController:nvc animated:YES];
    }
    
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
        [mail setSubject:[NSString stringWithFormat:@"[xsmth v%@]意见与反馈", [SMUtils appVersionString]]];
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
    mail.title = [NSString stringWithFormat:@"[xsmth v%@]意见与反馈", [SMUtils appVersionString]];
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://maxwin.me/xsmth/start.html"]];
        exit(0);
    }
}

@end
