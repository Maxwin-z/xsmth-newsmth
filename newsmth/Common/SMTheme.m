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
    return [SMConfig enableDayMode] ? SMRGB(0x32, 0x32, 0x32) : SMRGB(0xcd, 0xcd, 0xcd);
}
+ (UIColor *)colorForSecondary
{
    return [SMConfig enableDayMode] ? SMRGB(0x65, 0x65, 0x65) : SMRGB(0x9a, 0x9a, 0x9a);
}

+ (UIColor *)colorForQuote
{
    return [SMConfig enableDayMode] ? SMRGB(0x87, 0x87, 0x87) : SMRGB(0x78, 0x78, 0x78);
}

+ (UIColor *)colorForBarTintColor
{
    return [SMConfig enableDayMode] ? SMRGB(0xff, 0xff, 0xff) : SMRGB(0, 0, 0);
}

+ (UIColor *)colorForTintColor
{
    return [SMConfig enableDayMode] ? SMRGB(0x1c, 0x0, 0xce) : SMRGB(0x87, 0x87, 0x87);
}


+ (UIColor *)colorForBackground
{
    return [SMConfig enableDayMode] ? SMRGB(0xf0, 0xf0, 0xf0) : SMRGB(0xf, 0xf, 0xf);
}

@end
