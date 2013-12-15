//
//  SMTheme.m
//  newsmth
//
//  Created by Maxwin on 13-12-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMTheme.h"

@implementation SMTheme
// font


// color
+ (UIColor *)colorForPrimary
{
    return SMRGB(0xf0, 0xf0, 0xf0);
//    return SMRGB(0x32, 0x32, 0x32);
}
+ (UIColor *)colorForSecondary
{
    return SMRGB(0x87, 0x87, 0x87);
}
+ (UIColor *)colorForQuote
{
    return SMRGB(0xc0, 0x87, 0x32);
}
+ (UIColor *)colorForBarTintColor
{
    return SMRGB(0x0, 0x10, 0x20);
}

+ (UIColor *)colorForTintColor
{
    return SMRGB(0xff, 0xff, 0);
}


+ (UIColor *)colorForBackground
{
    return SMRGB(0x15, 0x15, 0x15);
}

@end
