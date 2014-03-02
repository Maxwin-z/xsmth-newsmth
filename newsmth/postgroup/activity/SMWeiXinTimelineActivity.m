//
//  SMWeiXinTimelineActivity.m
//  newsmth
//
//  Created by Maxwin on 14-3-2.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMWeiXinTimelineActivity.h"

@implementation SMWeiXinTimelineActivity

- (id)init
{
    self = [super init];
    _scene = WXSceneTimeline;
    return self;
}


- (NSString *)activityType
{
    return SMActivityTypePostToWXTimeline;
}

- (NSString *)activityTitle
{
    return @"朋友圈";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"common_share_icon_weixin_friends"];
}

@end
