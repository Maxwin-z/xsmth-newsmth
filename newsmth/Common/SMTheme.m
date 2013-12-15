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
    return [SMConfig enableDayMode] ? SMRGB(0x32, 0x32, 0x32) : SMRGB(0xf0, 0xf0, 0xf0);
}
+ (UIColor *)colorForSecondary
{
    return [SMConfig enableDayMode] ? SMRGB(0x87, 0x87, 0x87) : SMRGB(0x90, 0x90, 0x90);
}

+ (UIColor *)colorForQuote
{
    return [SMConfig enableDayMode] ? SMRGB(0xca, 0xcb, 0xcc) : SMRGB(0xca, 0xcb, 0xcc);
}
+ (UIColor *)colorForBarTintColor
{
    return [SMConfig enableDayMode] ? SMRGB(0xff, 0xff, 0xff) : SMRGB(0, 0, 0);
}

+ (UIColor *)colorForTintColor
{
    return [SMConfig enableDayMode] ? SMRGB(0, 124, 247) : SMRGB(0xea, 0xea, 0xea);
}


+ (UIColor *)colorForBackground
{
    return [SMConfig enableDayMode] ? SMRGB(0xf0, 0xf0, 0xf0) : SMRGB(0x15, 0x15, 0x15);
}

@end
