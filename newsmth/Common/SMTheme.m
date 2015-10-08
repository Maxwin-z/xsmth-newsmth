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
    return [SMConfig enableDayMode] ? SMRGB(0x32, 0x32, 0x32) : SMRGB(0xad, 0xad, 0xae);
}
+ (UIColor *)colorForSecondary
{
    return [SMConfig enableDayMode] ? SMRGB(0x65, 0x65, 0x65) : SMRGB(0x9a, 0x9a, 0x9a);
}

+ (UIColor *)colorForQuote
{
    return [SMConfig enableDayMode] ? SMRGB(0x87, 0x87, 0x87) : SMRGB(0x58, 0x58, 0x59);
}

+ (UIColor *)colorForBarTintColor
{
    return [SMConfig enableDayMode] ? SMRGB(0xff, 0xff, 0xff) : SMRGB(0x26, 0x26, 0x27);
}

+ (UIColor *)colorForTintColor
{
    return [SMConfig enableDayMode] ? SMRGB(0x1c, 0x0, 0xce) : SMRGB(0x87, 0x87, 0x87);
}


+ (UIColor *)colorForBackground
{
    return [SMConfig enableDayMode] ? SMRGB(0xfc, 0xfc, 0xfc) : SMRGB(0x28, 0x28, 0x29);
}

+ (UIColor *)colorForHighlightBackground
{
    return [SMConfig enableDayMode] ? SMRGB(0xe0, 0xe0, 0xe0) : [UIColor darkGrayColor];
}

@end
