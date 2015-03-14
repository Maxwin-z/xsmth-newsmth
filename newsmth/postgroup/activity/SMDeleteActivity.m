//
//  SMDeleteActivity.m
//  newsmth
//
//  Created by Maxwin on 15/3/14.
//  Copyright (c) 2015年 nju. All rights reserved.
//

#import "SMDeleteActivity.h"

@implementation SMDeleteActivity

- (NSString *)activityTitle
{
    return @"删除";
}

- (NSString *)activityType
{
    return SMActivityDeleteActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_delete"];
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
