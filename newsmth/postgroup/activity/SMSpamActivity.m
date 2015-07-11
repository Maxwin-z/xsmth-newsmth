//
//  SMSpamActivity.m
//  newsmth
//
//  Created by Maxwin on 15/7/11.
//  Copyright (c) 2015年 nju. All rights reserved.
//

#import "SMSpamActivity.h"

@implementation SMSpamActivity

- (NSString *)activityTitle
{
    return @"举报";
}

- (NSString *)activityType
{
    return SMActivitySpamActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_report"];
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
