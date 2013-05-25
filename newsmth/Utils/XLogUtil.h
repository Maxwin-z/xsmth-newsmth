//
//  XLog.h
//  TestMXLog
//
//  Created by WenDong Zhang on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _XLOG_ESC_CH @"\033"
#define _XLOG_LEVEL_DEBUG    @"DEBUG"
#define _XLOG_LEVEL_INFO     @"INFO"
#define _XLOG_LEVEL_WARN     @"WARN"
#define _XLOG_LEVEL_ERROR    @"ERROR"

// colors for log level, change it as your wish
#define _XLOG_COLOR_RED   _XLOG_ESC_CH @"#FF0000"
#define _XLOG_COLOR_GREEN _XLOG_ESC_CH @"#000099"
#define _XLOG_COLOR_BROWN  _XLOG_ESC_CH @"#FF9966"
// hard code, use 00000m for reset flag
#define _XLOG_COLOR_RESET _XLOG_ESC_CH @"#00000m"


#if defined (__cplusplus)
extern "C" {
#endif

    void _XLog_print(NSString *tag, NSString *colorStr, const char *fileName, const char *funcName, unsigned line, NSString *log);
    
    void _XLog_getFileName(const char *path, char *name);
    
    BOOL _XLog_isEnable();

#if defined (__cplusplus)
}
#endif

#define XLog_log(tag, color, ...) _XLog_print(tag, color, __FILE__, __FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define XLog_d(...) XLog_log(_XLOG_LEVEL_DEBUG, _XLOG_COLOR_GREEN, __VA_ARGS__)
#define XLog_i(...) XLog_log(_XLOG_LEVEL_INFO, _XLOG_COLOR_RESET, __VA_ARGS__)
#define XLog_v(...) XLog_log(_XLOG_LEVEL_WARN, _XLOG_COLOR_BROWN, __VA_ARGS__)
#define XLog_e(...) XLog_log(_XLOG_LEVEL_ERROR, _XLOG_COLOR_RED, __VA_ARGS__)

