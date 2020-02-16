//
//  SMPostActivityItemProvider.m
//  newsmth
//
//  Created by Maxwin on 14-3-2.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMPostActivityItemProvider.h"

@implementation SMPostActivityItemProvider
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    SMPost *post = self.placeholderItem;
    
    NSString *url = [NSString stringWithFormat:URL_PROTOCOL @"//m.newsmth.net/article/%@/single/%d/0",
                     post.board.name, post.pid];
    
    return url;
}

@end
