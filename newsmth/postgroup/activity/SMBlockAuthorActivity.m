//
//  SMSingleAuthorActivity.m
//  newsmth
//
//  Created by bh1cqx on 7/27/19.
//  Copyright © 2019 nju. All rights reserved.
//

#import "SMBlockAuthorActivity.h"

@implementation SMBlockAuthorActivity

- (NSString *)activityTitle
{
    return @"屏蔽作者";
}

- (NSString *)activityType
{
    return SMActivityBlockAuthorActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_blocked_author"];
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
