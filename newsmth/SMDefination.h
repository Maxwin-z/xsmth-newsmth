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

#endif
