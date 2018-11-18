//
//  SMDefination.h
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#ifndef newsmth_SMDefination_h
#define newsmth_SMDefination_h

#define SM_DATA_SCHEMA @"newsmth://_?"
#define SM_ERROR_DOMAIN @"newsmth_error"

#define SM_AD_DOMIN @"http://intely.cn"
#define SM_AD_APPID @"8"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_X (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0f)
#define IS_IPHONE_X_MAX (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 896.0)


#define SM_TOP_INSET  ((IS_IPHONE_X || IS_IPHONE_X_MAX) ? 88.0f : 64.0f)

#define SMRGB(r, g, b)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]
#define SMRGBA(r, g, b, a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define SM_TINTCOLOR    SMRGB(0, 124, 247)
#define i2s(val)    [NSString stringWithFormat:@"%@", @(val)]

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


typedef enum {
    SMNetworkErrorCodeParseFail = -1,
    SMNetworkErrorCodeRequestFail = 1,
}SMNetworkErrorCode;

#define NOTIFYCATION_THEME_CHANGED  @"notify_theme_changed"
#define NOTIFYCATION_SHAKE  @"notify_shake"
#define NOTIFYCATION_IAP_PRO @"iap_update_pro_success"

#define USERDEFAULTS_STAT_VERSION   @"statversion"  // 每个版本统计一次ga，唯一用户

#define USERDEFAULTS_UUID @"sm_uuid"
#define USERDEFAULTS_USERNAME   @"username"
#define USERDEFAULTS_PASSWORD   @"password"
#define USERDEFAULTS_COOKIES @"cookies"
#define USERDEFAULTS_NOTICE @"notice"   // 保存当前notice信息
#define USERDEFAULTS_NOTICE_LATEST    @"notice_latest"  // 保持最近一次打开Left看到的notice
#define USERDEFAULTS_NOTICE_FETCH @"notice_fetch"   // 保存上次后台获取的notice，检测是否变更

#define USERDEFAULTS_BACKGROUND_FETCH_INDEX @"backgroundfetchindex" // 斐波那契数列下标

#define USERDEFAULTS_BOARD_HISTORY @"board_history"
#define USERDEFAULTS_BOARD_OFFLINE @"board_offline"

#define USERDEFAULTS_EULA_ACCEPTED   @"pref_eula_accepted"

#define USERDEFAULTS_LIST_FONT_FAMILY  @"list_font_family"
#define USERDEFAULTS_LIST_FONT_SIZE  @"list_font_size"
#define USERDEFAULTS_POST_FONT_FAMILY  @"post_font_family"
#define USERDEFAULTS_POST_FONT_SIZE  @"post_font_size"

#define USERDEFAULTS_CONFIG_BACKGROUND_FETCH    @"cfg_backgroundfetch"
#define USERDEFAULTS_CONFIG_BACKGROUND_FETCH_SMART_MODE    @"cfg_backgroundfetchsmartmode"
#define USERDEFAULTS_CONFIG_HIDE_TOP_POST    @"cfg_hidetoppost"
#define USERDEFAULTS_CONFIG_SHOW_QMD    @"cfg_showqmd"
#define USERDEFAULTS_CONFIG_OPTIMIZE_POST_CONTENT   @"cfg_optimize_post_content"
#define USERDEFAULTS_CONFIG_USER_CLICKABLE    @"cfg_userclickable"
#define USERDEFAULTS_CONFIG_SHOW_REPLY_AUTHOR    @"cfg_showreplyauthor"
#define USERDEFAULTS_CONFIG_IOS7_SWIPE_BACK    @"cfg_ios7swipeback"
#define USERDEFAULTS_CONFIG_ENABLE_DAY_MODE @"cfg_enabledaymode"
#define USERDEFUALTS_CONFIG_ENABLE_SHAKE_SWITCH_DAY_MODE    @"cfg_shakeswitchdaymode"
#define USERDEFAULTS_CONFIG_ENABLE_DISABLE_TAIL @"cfg_disable_tail"
#define USERDEFAULTS_CONFIG_ENABLE_DISABLE_AD @"cfg_disable_ad"
#define USERDEFAULTS_CONFIG_ENABLE_MOBILE_AUTO_LOAD_IMAGE @"cfg_enable_mobile_auto_load_image"
#define USERDEFAULTS_CONFIG_ENABLE_TAP_PAGING @"cfg_enable_tap_paging"
#define USERDEFAULTS_CONFIG_ENABLE_PAD_MODE @"cfg_enable_page_mode"

#define USERDEFAULTS_UPDATE_ADID    @"updater_adid"
#define USERDEFAULTS_UPDATE_GADRATIO @"updater_gadratio"
#define USERDEFAULTS_UPDATE_IADRATIO @"updater_iadratio"
#define USERDEFAULTS_UPDATE_ADRATIO @"updater_adratio"
#define USERDEFAULTS_UPDATE_ADPOSTION @"updater_adpostion"

#define USERDEFAULTS_PRO    @"ispro"

#define USERDEFAULTS_SWIPE_HINT @"pref_swipe_hint"

#endif
