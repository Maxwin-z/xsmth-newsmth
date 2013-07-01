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
