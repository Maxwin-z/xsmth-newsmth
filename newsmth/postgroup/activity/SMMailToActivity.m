//
//  SMMailToActivity.m
//  newsmth
//
//  Created by Maxwin on 14-3-2.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMMailToActivity.h"

@implementation SMMailToActivity
- (NSString *)activityTitle
{
    return @"发信给作者";
}

- (NSString *)activityType
{
    return SMActivityTypeMailToAuthor;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"tabbar_mail"];
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
