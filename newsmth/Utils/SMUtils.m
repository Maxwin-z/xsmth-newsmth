//
//  SMUtils.m
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMUtils.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation SMUtils

+ (NSInteger)systemVersion
{
    return [[[UIDevice currentDevice] systemVersion] integerValue];
}

+ (NSString *)systemVersionString
{
    return [[UIDevice currentDevice] systemVersion];
}
+ (NSString *)appVersionString
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (BOOL)isPad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

+ (BOOL)isPortrait
{
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    if (o == UIDeviceOrientationUnknown) {
        o = (UIDeviceOrientation) [[UIApplication sharedApplication] statusBarOrientation];
    }
    return UIDeviceOrientationIsPortrait(o);
}

+ (NSString *)formatDate:(NSDate *)date
{
    int secPerDay = 24 * 3600;
    NSTimeInterval now = [[[NSDate alloc] init] timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ((int)(now / secPerDay) != (int)(date.timeIntervalSince1970 / secPerDay)) {
        [formatter setDateFormat:@"yyyy/MM/dd"];
    } else {
        [formatter setDateFormat:@"HH:mm"];
    }
    return [formatter stringFromDate:date];
}

+ (NSString *)encodeurl:(NSString *)url
{
    CFStringRef escapedStr = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                     (CFStringRef)url,
                                                                     NULL,
                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                     kCFStringEncodingUTF8);
    NSString *result = [NSString stringWithFormat:@"%@", escapedStr];
    CFRelease(escapedStr);
    return result;
}
+ (UIImage *)stretchedImage:(UIImage *)image
{
    return [image stretchableImageWithLeftCapWidth:(image.size.width + 1) / 2 topCapHeight:(image.size.height + 1) / 2];
}

+ (UIColor *)reverseColor:(UIColor *)color
{
    CGFloat rf, gf, bf, af;
    [color getRed:&rf green:&gf blue: &bf alpha: &af];
    
    return [UIColor colorWithRed:1 - rf green:1 - gf blue:1 - bf alpha:af];
}

+ (NSString *)formatSize:(unsigned long long)size
{
    if (size < 1000) {
        return [NSString stringWithFormat:@"%lld", size];
    }
    if (size < 1000 * 1024) {
        return [NSString stringWithFormat:@"%.2fK", size / 1024.0];
    }
    return [NSString stringWithFormat:@"%.2fM", size / 1024.0 / 1024.0];
}

+ (id)string2json:(NSString *)str
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) {
        json = nil;
        XLog_e(@"parse[%@], error[%@]", str, error);
    }
    return json;
}

+ (void)trackEventWithCategory:(NSString *)category
                        action:(NSString *)action
                         label:(NSString *)label
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:category
                                            action:action
                                             label:label
                                             value:nil] build];

    [[GAI sharedInstance].defaultTracker send:event];
    XLog_d(@"track category:" _XLOG_COLOR_RED @"[%@], action[%@], label[%@]" _XLOG_COLOR_RESET, category, action, label);
}

+ (BOOL)writeData:(NSData *)data toDocumentFolder:(NSString *)path
{
    // generate absulote path
    NSString *filepath = [self _absulotePathInDocument:path];
    
    // create folder
    NSString *folder = [filepath stringByDeletingLastPathComponent];
    BOOL isDir;
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            XLog_e(@"create folder:[%@] error[%@]", folder, error);
            return NO;
        }
    }
    
    // write data
    [data writeToFile:filepath options:NSDataWritingFileProtectionComplete error:&error];
    if (error) {
        XLog_e(@"write [%@] error: %@", path, error);
        return NO;
    }
    XLog_d(@"save data to %@", filepath);
    return YES;
}

+ (NSData *)readDataFromDocumentFolder:(NSString *)path
{
    NSString *filepath = [self _absulotePathInDocument:path];
    return [[NSData alloc] initWithContentsOfFile:filepath];
}

+ (BOOL)fileExistsInDocumentFolder:(NSString *)path
{
    NSString *filepath = [self _absulotePathInDocument:path];
    BOOL isDir;
    return [[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDir] && !isDir;
}

+ (NSString *)_absulotePathInDocument:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count == 0) {
        XLog_e(@"documents folder not exists!!");
        return nil;
    }
    NSString *doc = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", doc, path];
    return filepath;
}

+ (void)setIOS7ButtonStyle:(UIButton *)button
{
    UIImage *image = [button imageForState:UIControlStateNormal];
    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [button setImage:image forState:UIControlStateNormal];
}

+ (void)setTextFieldStyle:(UITextField *)textField
{
    UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
    textField.leftView = lv;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
//    UIView *rv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
//    textField.rightView = rv;
//    textField.rightViewMode = UITextFieldViewModeAlways;
    
    textField.background = [SMUtils stretchedImage:[UIImage imageNamed:@"bg_input_field"]];
}

@end


@implementation NSString (SMUtils)

-(CGSize) smSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)mode
{
    if (!self || self.length == 0) {
        return CGSizeZero;
    }
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary * attrs = @{NSFontAttributeName: font};
        //IOS7 测量字符串问题，需向下取整
        CGSize sbSize = [self boundingRectWithSize:size
                                           options:NSStringDrawingUsesLineFragmentOrigin | 
                         NSStringDrawingTruncatesLastVisibleLine
                                        attributes:attrs context:nil].size;
        sbSize.height = ceilf(sbSize.height);
        sbSize.width = ceilf(sbSize.width);
        return sbSize;
    } else {
        return [self sizeWithFont:font constrainedToSize:size lineBreakMode:mode];
    }
}


@end
