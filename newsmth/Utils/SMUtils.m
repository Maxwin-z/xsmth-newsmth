//
//  SMUtils.m
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMUtils.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>

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
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
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

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)hexFromUIColor:(UIColor *)color
{
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }

    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }

    return [NSString stringWithFormat:@"#%x%x%x", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
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

+ (NSString *)json2string:(id)json
{
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (error) {
            XLog_e(@"%@", error);
            return nil;
        }
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return str;
    }
    @catch (NSException *exception) {
        XLog_e(@"%@", exception);
        return nil;
    }
}

+ (void)trackEventWithCategory:(NSString *)category
                        action:(NSString *)action
                         label:(NSString *)label
{
//    NSMutableDictionary *event =
//    [[GAIDictionaryBuilder createEventWithCategory:category
//                                            action:action
//                                             label:label
//                                             value:nil] build];
//
//    [[GAI sharedInstance].defaultTracker send:event];
//    XLog_d(@"track category:" _XLOG_COLOR_RED @"[%@], action[%@], label[%@]" _XLOG_COLOR_RESET, category, action, label);
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

+ (void)savePhoto:(NSData*) dadata completionHandler:(void(^)(BOOL success, NSError * _Nullable error))block
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:dadata options:options];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            //子线程
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(block != nil){
                    block(success, error);
                }
            });
        }];
    }
    else{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:dadata metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if(block != nil){
                block(error == nil, error);
            }
        }];
    }
}

+(BOOL) isGif:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    if (c == 0x47) {
        return YES;
    }else{
        return NO;
    }
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

+ (NSString *)documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count == 0) {
        XLog_e(@"documents folder not exists!!");
        return nil;
    }

    return paths.firstObject;
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


+ (NSString *)gb2312Data2String:(NSData *)data
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    for (size_t i = 0; i != data.length; ++i) {
        unsigned char ch1[1], ch2[2];
        [data getBytes:ch1 range:NSMakeRange(i, 1)];
        if ((int)ch1[0] < 0x7f) {
            [result appendString:[[NSString alloc] initWithBytes:ch1 length:1 encoding:NSASCIIStringEncoding]];
        } else if (i + 1 < data.length) {
            [data getBytes:ch2 range:NSMakeRange(i, 2)];
            @try {
                [result appendString:[[NSString alloc] initWithBytes:ch2 length:2 encoding:enc]];
                ++i;    // 2字节
            }
            @catch (NSException *exception) {
                // just skip this char
            }
        }
    }
    return result;
}

+ (NSString *)trimHtmlTag:(NSString *)html
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<br\\s*/?>"
                                                                           options:0
                                                                             error:&error];
    if (!error) {
        html = [regex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@"\n"];
    }
    
    error = NULL;
    regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>"
                                                      options:0
                                                        error:&error];
    if (!error) {
        html = [regex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@""];
    }
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    html = [html stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    html = [html stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    html = [html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    return html;
}

+ (NSString *)generateUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

+ (NSString *)getSMUUID
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [def stringForKey:USERDEFAULTS_UUID];
    if (uuid.length == 0) {
        uuid = [[self class] generateUUID];
        [def setObject:uuid forKey:USERDEFAULTS_UUID];
    }
    return uuid;
}

+ (NSString *)md5:(NSData *)data
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, data.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
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
