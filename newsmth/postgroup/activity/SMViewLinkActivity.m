//
//  SMViewLinkActivity.m
//  newsmth
//
//  Created by Maxwin on 14-4-5.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMViewLinkActivity.h"

@implementation SMViewLinkActivity
- (NSString *)activityTitle
{
    return @"访问文中链接";
}

- (NSString *)activityType
{
    return SMActivityViewLinkActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_link"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)performActivity
{
    [self activityDidFinish:YES];
}

@end
