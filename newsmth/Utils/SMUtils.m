//
//  SMUtils.m
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMUtils.h"
#import "GAI.h"

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


+ (void)trackEventWithCategory:(NSString *)category
                        action:(NSString *)action
                         label:(NSString *)label
{
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:category
                                                    withAction:action
                                                     withLabel:label
                                                     withValue:nil];
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
        sbSize.height = ceilf(sbSize.height + 1);   // todo 1...
        sbSize.width = ceilf(sbSize.width);
        return sbSize;
    } else {
        return [self sizeWithFont:font constrainedToSize:size lineBreakMode:mode];
    }
}


@end
