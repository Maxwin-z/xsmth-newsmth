//
//  SMWeiXinSessionActivity.m
//  newsmth
//
//  Created by Maxwin on 14-3-2.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMWeiXinSessionActivity.h"

@interface SMWeiXinSessionActivity ()
@property (strong, nonatomic) NSString *text;
@end

@implementation SMWeiXinSessionActivity

+ (UIActivityCategory)activityCategory
{
//    return UIActivityCategoryShare;
    return UIActivityCategoryAction;
}

- (id)init
{
    self = [super init];
    _scene = WXSceneSession;
    return self;
}

- (NSString *)activityType
{
    return SMActivityTypePostToWXSession;
}

- (NSString *)activityTitle
{
    return @"微信好友";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"common_share_icon_weixin"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    self.text = activityItems.firstObject;
}

- (void)performActivity
{
    SendMessageToWXReq *req = [SendMessageToWXReq new];
    
    req.text = self.text;
    req.bText = YES;
    req.scene = _scene;
    [WXApi sendReq:req];
    
    [self activityDidFinish:YES];
}

@end
