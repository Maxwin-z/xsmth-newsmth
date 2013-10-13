//
//  SMDefination.h
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#ifndef newsmth_SMDefination_h
#define newsmth_SMDefination_h

#define SM_DATA_SCHEMA @"newsmth://"
#define SM_ERROR_DOMAIN @"newsmth_error"

#define SM_TOP_INSET    64.0f

#define SMRGB(r, g, b)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]
#define SM_TINTCOLOR    SMRGB(0, 124, 247)

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

#define USERDEFAULTS_USERNAME   @"username"
#define USERDEFAULTS_PASSWORD   @"password"
#define USERDEFAULTS_NOTICE @"notice"

#define USERDEFAULTS_BOARD_HISTORY @"board_history"
#define USERDEFAULTS_POST_FONT_FAMILY  @"post_font_family"
#define USERDEFAULTS_POST_FONT_SIZE  @"post_font_size"

#define USERDEFAULTS_CONFIG_BACKGROUND_FETCH    @"cfg_backgroundfetch"
#define USERDEFAULTS_CONFIG_HIDE_TOP_POST    @"cfg_hidetoppost"
#define USERDEFAULTS_CONFIG_SHOW_QMD    @"cfg_showqmd"
#define USERDEFAULTS_CONFIG_USER_CLICKABLE    @"cfg_userclickable"
#define USERDEFAULTS_CONFIG_IOS7_SWIPE_BACK    @"cfg_ios7swipeback"

#endif
