//
//  XLog.m
//  TestMXLog
//
//  Created by WenDong Zhang on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XLogUtil.h"

static int isXLogEnable = -1;   // -1: not set, 0: disable, 1: enable
static BOOL log2console = NO;

void _XLog_print(NSString *tag, NSString *colorStr, const char *fileName, const char *funcName, unsigned line, NSString *log)
{
    // show filename without path
    char *file = (char *)malloc(sizeof(char) * strlen(fileName));
    _XLog_getFileName(fileName, file);
    
    NSMutableString *res = [[NSMutableString alloc] initWithCapacity:0];
    
    if (_XLog_isEnable() && !log2console) {
        [res appendFormat:@"%@", colorStr]; // log color
        [res appendFormat:@"%@[%@]", _XLOG_ESC_CH, tag]; // start tag
    }
    
    [res appendFormat:@"%@ ", [[NSDate date] description]];
    [res appendFormat:@"%s %s[%u] ", file, funcName, line];
    [res appendFormat:@"%@", log];
    
    if (_XLog_isEnable() && !log2console) {
        [res appendFormat:@"%@[/%@]", _XLOG_ESC_CH, tag];
        [res appendFormat:@"%@", _XLOG_COLOR_RESET];
    }
    
    if (log2console) {
        NSLog(@"%@", res);
    } else {
        printf("%s", [res UTF8String]);
    }
    
    free(file);
}

BOOL _XLog_isEnable()
{
    return YES;
    if (isXLogEnable == -1) {   // init
        char *xlogEnv = getenv("XLOG_FLAG");
        if (xlogEnv && !strcmp(xlogEnv, "YES")) {
            isXLogEnable = 1;
        } else {
            isXLogEnable = 0;
        }
    }

    if (isXLogEnable == 0) {
        return NO;
    }
    return YES;
}

void _XLog_getFileName(const char *path, char *name)
{
    int l = strlen(path);
    while (--l >= 0 && path[l] != '/') {}
    strcpy(name, path + (l >= 0 ? l + 1 : 0));
}
