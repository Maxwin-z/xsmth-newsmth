//
//  SMPostActivityItemProvider.m
//  newsmth
//
//  Created by Maxwin on 14-3-2.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMPostActivityItemProvider.h"
#import "SMWeiXinSessionActivity.h"

@implementation SMPostActivityItemProvider
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    SMPost *post = self.placeholderItem;
    
    NSString *url = [NSString stringWithFormat:@"http://m.newsmth.net/article/%@/single/%d/0",
                     post.board.name, post.pid];
    
    if ([activityType isEqualToString:SMActivityTypePostToWXSession]
        || [activityType isEqualToString:SMActivityTypePostToWXTimeline]) {
        return @{
                 @"url": url,
                 @"post": post
                 };
    }
    
    NSString *content = [NSString stringWithFormat:@"%@ (原文: %@)", post.content, url];
    if ([activityType isEqualToString:UIActivityTypePostToWeibo]
        || [activityType isEqualToString:UIActivityTypePostToTencentWeibo]
        || [activityType isEqualToString:UIActivityTypePostToTwitter]) {
        NSInteger kTwitterLength = 140;
        content = [post.content substringToIndex:MIN(post.content.length, kTwitterLength)];
    }
    
    return content;
}

@end
