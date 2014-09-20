//
//  SMReplyActivity.m
//  newsmth
//
//  Created by Maxwin on 14-9-20.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMReplyActivity.h"

@implementation SMReplyActivity

- (NSString *)activityTitle
{
    return @"回复";
}

- (NSString *)activityType
{
    return SMActivityReplyActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_reply"];
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
