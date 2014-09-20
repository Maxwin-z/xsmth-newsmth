//
//  SMSingleAuthorActivity.m
//  newsmth
//
//  Created by Maxwin on 14-9-20.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMSingleAuthorActivity.h"

@implementation SMSingleAuthorActivity

- (NSString *)activityTitle
{
    return @"同作者";
}

- (NSString *)activityType
{
    return SMActivitySingleAuthorActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_single_author"];
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
