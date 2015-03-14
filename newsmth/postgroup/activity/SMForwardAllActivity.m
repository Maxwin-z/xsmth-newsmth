//
//  SMForwardAllActivity.m
//  newsmth
//
//  Created by Maxwin on 15/3/14.
//  Copyright (c) 2015年 nju. All rights reserved.
//

#import "SMForwardAllActivity.h"

@implementation SMForwardAllActivity

- (NSString *)activityTitle
{
    return @"合集转寄";
}

- (NSString *)activityType
{
    return SMActivityForwardAllActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_forward_all"];
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
