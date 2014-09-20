//
//  SMForwardActivity.m
//  newsmth
//
//  Created by Maxwin on 14-9-20.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMForwardActivity.h"

@implementation SMForwardActivity

- (NSString *)activityTitle
{
    return @"转寄";
}

- (NSString *)activityType
{
    return SMActivityForwardActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_forward"];
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
