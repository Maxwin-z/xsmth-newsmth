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
#import "XImageViewCache.h"
#import "XWebViewController.h"
//#import "SMDonateViewController.h"
#import <MessageUI/MessageUI.h>
#import "SMIPadSplitViewController.h"
#import "SMEULAViewController.h"
#import "SMBlockedAuthorsViewController.h"
#import "XImageView.h"

#define MAX_CELL_COUNT  6

typedef enum {
    CellTypePadMode,
    
    CellTypeDisableTail,
    CellTypeDisableAd,
    
    CellTypeHideTop,
    CellTypeUserClickable,
    CellTypeShowReplyAuthor,
    CellTypeEnableQMD,
    CellTypeSwipeBack,
    CellTypeEnableDayMode,
    CellTypeShakeSwitchDayMode,
    CellTypeOptimizePostContent,
    CellTypeEnableMobileAutoLoadImage,
    CellTypeTapPaging,
    
    CellTypeBackgroundFetch,
    CellTypeBackgroundFetchSmartMode,
    CellTypeBackgroundFetchHelp,
    
    CellTypeListFont,
    CellTypePostFont,
    
    CellTypeBlockedAuthors,
    CellTypeEULA,
    CellTypeFeedback,
    CellTypeRate,
    CellTypeClearCache,
    CellTypeClearPostCache,
    
    CellTypeThxPsyYiYi,
    CellTypeAbout,
    CellTypeDonate,
    CellTypeZanShang
    
}CellType;

typedef enum {
    SectionTypeIAP,
    SectionTypeBoard,
    SectionTypePostView,
    SectionTypeBackgroundFetch,
    SectionTypeInteract,
    SectionTypePostFont,
    SectionTypeMore,
    SectionTypeThanks,
    SectionTypeDayMode
}SectionType;

typedef struct {
    SectionType sectionType;
    char *title;
    char *footer;
    int cellCount;
    CellType cells[MAX_CELL_COUNT];
}SectionData;

static SectionData sections[] = {
    /*
    {
        SectionTypeIAP,
        "支持开发者",
        NULL,
        4,
        {CellTypeDonate, CellTypeDisableTail, CellTypeDisableAd, CellTypeAbout}
    },
     */
    {
        SectionTypeBackgroundFetch,
        "后台获取最新邮件、回复、AT",
        "iOS7支持后台定时获取网络数据，需要登录。",
        3,
        {CellTypeBackgroundFetch, CellTypeBackgroundFetchSmartMode, CellTypeBackgroundFetchHelp}
    },
    {
        SectionTypeBoard,
        "浏览",
        NULL,
        4,
        {CellTypeHideTop, CellTypeUserClickable, CellTypeShowReplyAuthor, CellTypePadMode}
    },
    {
        SectionTypePostView,
        "帖子",
        NULL,
        3,
        {
            CellTypeEnableMobileAutoLoadImage,
            CellTypeEnableQMD,
            CellTypeTapPaging
        }
    },
    {
        SectionTypeDayMode,
        "日间/夜间模式",
        NULL,
        2,
        {
            CellTypeShakeSwitchDayMode,
            CellTypeEnableDayMode
        }
    },
    {
        SectionTypeInteract,
        "右滑返回",
        "iOS7系统默认支持右滑返回，需要从屏幕最左边滑动。不习惯的用户请禁用此项。",
        1,
        {CellTypeSwipeBack}
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
        5,
        {CellTypeBlockedAuthors, CellTypeEULA, CellTypeFeedback, CellTypeRate, CellTypeClearCache, CellTypeClearPostCache}
    },
    {
        SectionTypeThanks,
        "感谢",
        NULL,
        3,
        {CellTypeThxPsyYiYi, CellTypeAbout, CellTypeZanShang /*, CellTypeDonate */}
    }
};


@interface SMSettingViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewForTableViewHeader;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForHideTop;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForUserClickable;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForShowReplyAuthor;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForShowQMD;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForOptimizePostContent;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForBackgroundFetch;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForBackgroundFetchSmartMode;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForFeedback;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForRate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForSwipeBack;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForPostFont;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForListFont;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForClearCache;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForClearPostCache;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForThxPsyYiYi;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForBackgroundFetchHelp;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForEnableDayMode;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForShakeSwitchDayMode;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForAbout;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForDonate;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForBlockedAuthors;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForEULA;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForDisableTail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForDisableAd;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForTapPaging;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForEnableMobileAutoLoadImage;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForPadMode;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForZanShang;
@property (weak, nonatomic) IBOutlet XImageView *imageViewForZanShang;
@property (assign, nonatomic) CGFloat heigitForZanShang;

@property (weak, nonatomic) IBOutlet UILabel *labelForAppVersion;
@property (weak, nonatomic) IBOutlet UISwitch *switchForHideTop;
@property (weak, nonatomic) IBOutlet UISwitch *switchForUserClickable;
@property (weak, nonatomic) IBOutlet UISwitch *switchForShowReplyAuthor;
@property (weak, nonatomic) IBOutlet UISwitch *switchForShowQMD;
@property (weak, nonatomic) IBOutlet UISwitch *switchForOptimizePostContent;
@property (weak, nonatomic) IBOutlet UISwitch *switchForBackgroundFetch;
@property (weak, nonatomic) IBOutlet UISwitch *switchForBackgroundFetchSmartMode;
@property (weak, nonatomic) IBOutlet UISwitch *switchForSwipeBack;
@property (weak, nonatomic) IBOutlet UISwitch *switchForEnableDayMode;
@property (weak, nonatomic) IBOutlet UISwitch *switchForShakeSwitchDayMode;
@property (weak, nonatomic) IBOutlet UISwitch *switchForDisableTail;
@property (weak, nonatomic) IBOutlet UISwitch *switchForDisableAd;
@property (weak, nonatomic) IBOutlet UISwitch *switchForEnableMobileAutoLoadImage;
@property (weak, nonatomic) IBOutlet UISwitch *switchForTapPaging;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlForPadMode;

@property (weak, nonatomic) IBOutlet UILabel *labelForPostFont;
@property (weak, nonatomic) IBOutlet UISlider *sliderForPostFont;
@property (weak, nonatomic) IBOutlet UILabel *labelForListFont;
@property (weak, nonatomic) IBOutlet UISlider *sliderForListFont;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorForClearCache;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorForClearPostCache;

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
    
    self.title = @"设置";
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.tableHeaderView = _viewForTableViewHeader;

    _labelForAppVersion.text = [NSString stringWithFormat:@"xsmth %@ @Maxwin", [SMUtils appVersionString]];
    
    _switchForHideTop.on = [SMConfig disableShowTopPost];
    _switchForUserClickable.on = [SMConfig enableUserClick];
    _switchForShowReplyAuthor.on = [SMConfig enableShowReplyAuthor];
    _switchForOptimizePostContent.on = [SMConfig enableOptimizePostContent];
    _switchForSwipeBack.on = [SMConfig enableIOS7SwipeBack];
    _switchForBackgroundFetch.on = [SMConfig enableBackgroundFetch];
    _switchForBackgroundFetchSmartMode.on = [SMConfig enableBackgroundFetchSmartMode];
    _switchForShowQMD.on = [SMConfig enableShowQMD];
    _switchForEnableDayMode.on = [SMConfig enableDayMode];
    _switchForShakeSwitchDayMode.on = [SMConfig enableShakeSwitchDayMode];
    _switchForDisableTail.on = [SMConfig disableTail];
    _switchForDisableAd.on = [SMConfig disableAd];
    _switchForEnableMobileAutoLoadImage.on = [SMConfig enableMobileAutoLoadImage];
    _switchForTapPaging.on = [SMConfig enableTapPaing];
    
    _sliderForListFont.value = [SMConfig listFont].pointSize;
    _sliderForPostFont.value = [SMConfig postFont].pointSize;
    
    _segmentedControlForPadMode.selectedSegmentIndex = [SMConfig iPadMode] ? 0 : 1;
    
    if ([SMUtils systemVersion] < 7) {
        _switchForBackgroundFetch.on = _switchForSwipeBack.on = _switchForBackgroundFetchSmartMode.on = NO;
        _switchForBackgroundFetch.enabled = _switchForSwipeBack.enabled = _switchForBackgroundFetchSmartMode.enabled = NO;
    }
    
    self.heigitForZanShang = 0.1f;
    
//    if ([SMConfig isPro]) {
//        _cellForDonate.textLabel.text = @"已升级为Pro版";
//    }
//    _switchForDisableTail.enabled = _switchForDisableAd.enabled = [SMConfig isPro];
    
    __block unsigned long long cacheSize = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        cacheSize = [[XImageViewCache sharedInstance] cacheSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            _cellForClearCache.detailTextLabel.text = [SMUtils formatSize:cacheSize];
            _activityIndicatorForClearCache.hidden = YES;
            [self.tableView reloadData];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __block unsigned long long postsSize = [self postCacheSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            _cellForClearPostCache.detailTextLabel.text = [SMUtils formatSize:postsSize];
            _activityIndicatorForClearPostCache.hidden = YES;
            [self.tableView reloadData];
        });
    });
    
    [self loadZanShangImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateProNotification) name:NOTIFYCATION_IAP_PRO object:nil];
}

- (void)loadZanShangImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://maxwin-z.github.io/xsmth/zanshang.md"];
        NSError *error = nil;
        NSString *imageUrl = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if ([imageUrl hasPrefix:@"http"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageViewForZanShang.url = [imageUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                __weak SMSettingViewController *weakSelf = self;
                [self.imageViewForZanShang setDidLoadBlock:^{
                    UIImage *image = weakSelf.imageViewForZanShang.image;
                    if (image.size.width > 0) {
                        CGFloat padding = 21.0f;
                        self.heigitForZanShang = weakSelf.imageViewForZanShang.frame.size.width * image.size.height / image.size.width + padding;
                        [weakSelf.tableView reloadData];
                    }
                }];
            });

        }
    });
}

- (NSString *)postsPath
{
    return [[SMUtils documentPath] stringByAppendingString:@"/posts/"];
}

- (unsigned long long)postCacheSize
{
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self.postsPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSError *error;
        NSString *fullPath = [self.postsPath stringByAppendingPathComponent:fileName];
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        if (!error) {
            fileSize += [fileDictionary fileSize];
        } else {
            XLog_e(@"attribute file error: %@, %@", fullPath, error);
        }
    }
    
    return fileSize;
}

- (void)clearPostCache
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:self.postsPath error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [self.postsPath stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                XLog_e(@"remove file fail: %@", fullPath);
            } else {
                XLog_d(@"remove file success: %@", fullPath);
            }
        }
    } else {
        XLog_e(@"%@", error);
    }
    
    // remove blocklist
    [fileMgr removeItemAtPath:[[SMUtils documentPath] stringByAppendingString:@"/blocklist.json"] error:nil];
}

- (void)setupTheme
{
    [super setupTheme];
    _labelForAppVersion.textColor = [SMTheme colorForPrimary];
    _labelForPostFont.textColor = [SMTheme colorForPrimary];
    _labelForListFont.textColor = [SMTheme colorForPrimary];
    [_switchForEnableDayMode setOn:[SMConfig enableDayMode] animated:YES];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView beginUpdates];
    [_tableView endUpdates];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInset = UIApplication.sharedApplication.keyWindow.safeAreaInsets;
    }
}

- (void)onUpdateProNotification
{
    if ([SMConfig isPro]) {
        _cellForDonate.textLabel.text = @"已升级为Pro版";
    }
    _switchForDisableTail.enabled = _switchForDisableAd.enabled = [SMConfig isPro];

    [self.tableView reloadData];
}

- (IBAction)onSwitchValueChanged:(UISwitch *)sender
{
    NSString *action = @"";
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (sender == _switchForHideTop) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_HIDE_TOP_POST];
        action = @"hideTopPost";
    }
    if (sender == _switchForShowQMD) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_SHOW_QMD];
        action = @"showQMD";
    }
    if (sender == _switchForUserClickable) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_USER_CLICKABLE];
        action = @"userClickable";
    }
    if (sender == _switchForShowReplyAuthor) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_SHOW_REPLY_AUTHOR];
        action = @"showReplyAuthor";
    }
    if (sender == _switchForOptimizePostContent) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_OPTIMIZE_POST_CONTENT];
        action = @"optimizePostContent";
    }
    if (sender == _switchForSwipeBack) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_IOS7_SWIPE_BACK];
        action = @"swipeBack";

        [def synchronize];
        [[[UIAlertView alloc] initWithTitle:@"!!注意!!" message:@"需要重启应用，使之生效" delegate:self cancelButtonTitle:@"稍后重启" otherButtonTitles:@"现在重启", nil] show];
    }
    if (sender == _switchForBackgroundFetch) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_BACKGROUND_FETCH];
        _switchForBackgroundFetchSmartMode.enabled = _switchForBackgroundFetch.on;
        action = @"backgroundFetch";
    }
    if (sender == _switchForBackgroundFetchSmartMode) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_BACKGROUND_FETCH_SMART_MODE];
        action = @"backgroundFetchSmartMode";
    }
    
    if (sender == _switchForEnableDayMode) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_ENABLE_DAY_MODE];
        action = @"enableDayMode";
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFYCATION_THEME_CHANGED object:nil];
    }
    
    if (sender == _switchForShakeSwitchDayMode) {
        [def setBool:sender.on forKey:USERDEFUALTS_CONFIG_ENABLE_SHAKE_SWITCH_DAY_MODE];
        action = @"enableShakeSwitchDayMode";
    }
    
    if (sender == _switchForDisableTail) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_ENABLE_DISABLE_TAIL];
        action = @"proDisableTail";
    }
    
    if (sender == _switchForDisableAd) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_ENABLE_DISABLE_AD];
        action = @"proDisableAd";
    }
    
    if (sender == _switchForEnableMobileAutoLoadImage) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_ENABLE_MOBILE_AUTO_LOAD_IMAGE];
        action = @"enableMobileAutoLoadImage";
    }
    
    if (sender == _switchForTapPaging) {
        [def setBool:sender.on forKey:USERDEFAULTS_CONFIG_ENABLE_TAP_PAGING];
        action = @"enableTapPaging";
    }

    [SMUtils trackEventWithCategory:@"setting" action:action label:sender.on ? @"on" : @"off"];
}

- (IBAction)onPadModeSegmentedControlValueChanged:(UISegmentedControl *)sender
{
    BOOL padMode = sender.selectedSegmentIndex == 0;
    [[NSUserDefaults standardUserDefaults] setBool:padMode forKey:USERDEFAULTS_CONFIG_ENABLE_PAD_MODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[[UIAlertView alloc] initWithTitle:@"!!注意!!" message:@"需要重启应用，使之生效" delegate:self cancelButtonTitle:nil otherButtonTitles:@"重启", nil] show];
}

- (IBAction)onPostFontSliderValueChanged:(UISlider *)slider
{
    NSInteger size = (int)slider.value;
    if (slider == _sliderForListFont) {
        [[NSUserDefaults standardUserDefaults] setInteger:size forKey:USERDEFAULTS_LIST_FONT_SIZE];
        [SMUtils trackEventWithCategory:@"setting" action:@"listfont" label:i2s(size)];
    }
    if (slider == _sliderForPostFont) {
        [[NSUserDefaults standardUserDefaults] setInteger:size forKey:USERDEFAULTS_POST_FONT_SIZE];
        [SMUtils trackEventWithCategory:@"setting" action:@"postfont" label:i2s(size)];
    }
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

#pragma mark - cache

#pragma mark - UITableViewDataSource/Delegate
- (void)fixPadModeCell  // don't know wht
{
    CGRect frame = self.segmentedControlForPadMode.frame;
    frame.origin.x = self.cellForPadMode.bounds.size.width - frame.size.width - 10;
    self.segmentedControlForPadMode.frame = frame;
}

- (UITableViewCell *)cellForType:(CellType)type;
{
    switch (type) {
        case CellTypeDisableTail:
            return _cellForDisableTail;
        case CellTypeDisableAd:
            return _cellForDisableAd;
            
        case CellTypeHideTop:
            return _cellForHideTop;
            
        case CellTypeUserClickable:
            return _cellForUserClickable;
        case CellTypeShowReplyAuthor:
            return _cellForShowReplyAuthor;
        case CellTypeOptimizePostContent:
            return _cellForOptimizePostContent;
        case CellTypeEnableMobileAutoLoadImage:
            return _cellForEnableMobileAutoLoadImage;
        case CellTypeTapPaging:
            return _cellForTapPaging;
        case CellTypePadMode:
            [self fixPadModeCell];
            return _cellForPadMode;
            
        case CellTypeEnableQMD:
            return _cellForShowQMD;
            
        case CellTypeEnableDayMode:
            return _cellForEnableDayMode;
        case CellTypeShakeSwitchDayMode:
            return _cellForShakeSwitchDayMode;
            
        case CellTypeSwipeBack:
            return _cellForSwipeBack;
            
        case CellTypeBackgroundFetch:
            return _cellForBackgroundFetch;
        case CellTypeBackgroundFetchSmartMode:
            return _cellForBackgroundFetchSmartMode;
        case CellTypeBackgroundFetchHelp:
            return _cellForBackgroundFetchHelp;
            
        case CellTypeListFont:
            return _cellForListFont;
        case CellTypePostFont:
            return _cellForPostFont;

        case CellTypeBlockedAuthors:
            return _cellForBlockedAuthors;
        case CellTypeEULA:
            return _cellForEULA;
        case CellTypeFeedback:
            return _cellForFeedback;
        case CellTypeRate:
            return _cellForRate;
        case CellTypeClearCache:
            return _cellForClearCache;
        case CellTypeClearPostCache:
            return _cellForClearPostCache;
            
        case CellTypeThxPsyYiYi:
            return _cellForThxPsyYiYi;
        case CellTypeAbout:
            return _cellForAbout;
        case CellTypeDonate:
            return _cellForDonate;
        case CellTypeZanShang:
            return _cellForZanShang;
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
    SectionData sec = sections[section];
    NSInteger count = sec.cellCount;
    if (sec.sectionType == SectionTypeBoard && ![SMUtils isPad]) {
        --count;
    }
    return count;
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
    
    if (cellType == CellTypeZanShang) {
        return self.heigitForZanShang;
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
    UITableViewCell *cell = [self cellForType:cellType];
    cell.backgroundColor = [SMTheme colorForBackground];
    cell.textLabel.textColor = [SMTheme colorForPrimary];
    cell.detailTextLabel.textColor = [SMTheme colorForSecondary];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CellType cellType = sections[indexPath.section].cells[indexPath.row];
    
    NSString *action = @"";
    if (cellType == CellTypePostFont || cellType == CellTypeListFont) {
        SMFontSelectorViewController *vc = [[SMFontSelectorViewController alloc] init];
        __weak SMSettingViewController *weakSelf = self;
        vc.fontSelectedBlock = ^(NSString *fontName) {
            [[NSUserDefaults standardUserDefaults] setObject:fontName forKey:cellType == CellTypePostFont ? USERDEFAULTS_POST_FONT_FAMILY : USERDEFAULTS_LIST_FONT_FAMILY];
            [weakSelf.tableView reloadData];
        };
        vc.selectedFont = cellType == CellTypePostFont ? [SMConfig postFont] : [SMConfig listFont];
        P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:vc];
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:nvc animated:YES];
        
        action = cellType == CellTypePostFont ? @"changePostFont" : @"changeListFont";
    }

    if (cellType == CellTypeBlockedAuthors) {
        SMBlockedAuthorsViewController *vc = [SMBlockedAuthorsViewController new];
        if ([SMConfig iPadMode]) {
            [SMIPadSplitViewController instance].detailViewController = vc;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

    if (cellType == CellTypeEULA) {
        SMEULAViewController *vc = [SMEULAViewController new];
        vc.hideAgreeButton = YES;
        if ([SMConfig iPadMode]) {
            [SMIPadSplitViewController instance].detailViewController = vc;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    if (cellType == CellTypeFeedback) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"邮件", @"站内信", nil];
        [actionSheet showInView:self.view];
    }
    
    if (cellType == CellTypeRate) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/xsmth-for-shui-mu/id1090365014?ls=1&mt=8"]];
        action = @"rate";
    }
    
    if (cellType == CellTypeThxPsyYiYi) {
        XWebViewController *vc = [[XWebViewController alloc] init];
        vc.url = [NSURL URLWithString:@"https://maxwin-z.github.io/xsmth/PsyYiYi.html"];
        
        if ([SMConfig iPadMode]) {
            [SMIPadSplitViewController instance].detailViewController = vc;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }

        action = @"PsyYiYi";
    }
    
    if (cellType == CellTypeDonate) {
//        SMDonateViewController *vc = [SMDonateViewController new];
//        [self.navigationController pushViewController:vc animated:YES];
        action = @"donate";
    }
    
    if (cellType == CellTypeAbout) {
        XWebViewController *vc = [[XWebViewController alloc] init];
        vc.url = [NSURL URLWithString:@"https://maxwin-z.github.io/xsmth/about.html"];
        if ([SMConfig iPadMode]) {
            [SMIPadSplitViewController instance].detailViewController = vc;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
        action = @"about";
    }

    if (cellType == CellTypeBackgroundFetchHelp) {
        XWebViewController *vc = [[XWebViewController alloc] init];
        vc.url = [NSURL URLWithString:@"https://maxwin-z.github.io/xsmth/background_fetch_help.html"];
        if ([SMConfig iPadMode]) {
            [SMIPadSplitViewController instance].detailViewController = vc;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
        action = @"fetchHelp";
    }

    if (cellType == CellTypeClearCache) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            _activityIndicatorForClearCache.hidden = YES;
            _cellForClearCache.detailTextLabel.text = @"";
            [[XImageViewCache sharedInstance] clearCache];
            dispatch_async(dispatch_get_main_queue(), ^{
                _cellForClearCache.detailTextLabel.text = @"0";
                _activityIndicatorForClearCache.hidden = YES;
            });
        });
        action = @"clearImageCache";
    }
    
    if (cellType == CellTypeClearPostCache) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            _activityIndicatorForClearPostCache.hidden = YES;
            _cellForClearPostCache.detailTextLabel.text = @"";
            [self clearPostCache];
            dispatch_async(dispatch_get_main_queue(), ^{
                _cellForClearPostCache.detailTextLabel.text = @"0";
                _activityIndicatorForClearPostCache.hidden = YES;
            });
        });
        action = @"clearPostsCache";
    }
    
    if (cellType == CellTypeZanShang) {
        // TODO
    }
    
    [SMUtils trackEventWithCategory:@"setting" action:action label:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // mail
        if (![MFMailComposeViewController canSendMail]) {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备未设置邮件帐号。请至“系统设置”-“邮件”设置邮件账户" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return ;
        }
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setToRecipients:@[@"zwd2005@gmail.com"]];
        [mail setSubject:[NSString stringWithFormat:@"[xsmth v%@]意见与反馈", [SMUtils appVersionString]]];
        mail.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:mail animated:YES];
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

    if ([SMConfig iPadMode]) {
        [[SMIPadSplitViewController instance] presentModalViewController:nvc animated:YES];
    } else {
        [self presentModalViewController:nvc animated:YES];
    }
    
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://maxwin-z.github.io/xsmth/start.html"]];
        [SMUtils trackEventWithCategory:@"setting" action:@"restart" label:nil];
        exit(0);
    }
}

@end
