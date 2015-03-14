//
//  SMEditActivity.m
//  newsmth
//
//  Created by Maxwin on 15/3/14.
//  Copyright (c) 2015年 nju. All rights reserved.
//

#import "SMEditActivity.h"

@implementation SMEditActivity

- (NSString *)activityTitle
{
    return @"编辑";
}

- (NSString *)activityType
{
    return SMActivityEditActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_edit"];
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
