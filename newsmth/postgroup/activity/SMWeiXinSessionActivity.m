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
@property (strong, nonatomic) NSDictionary *shareInfo;
@end

@implementation SMWeiXinSessionActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
//    return UIActivityCategoryAction;
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
    return [UIImage imageNamed:[SMUtils systemVersion] > 7 ? @"common_share_icon_weixin_ios8" : @"common_share_icon_weixin"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return [WXApi isWXAppInstalled];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
//    self.text = activityItems.firstObject;
    self.shareInfo = activityItems.firstObject;
}

- (void)performActivity
{
    SMPost *post = self.shareInfo[@"post"];
    NSString *url = self.shareInfo[@"url"];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = post.title;
    message.description = post.content;
    [message setThumbImage:[UIImage imageNamed:@"icon"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    [WXApi sendReq:req];
    
//    SendMessageToWXReq *req = [SendMessageToWXReq new];
//    
//    req.text = self.text;
//    req.bText = YES;
//    req.scene = _scene;
//    [WXApi sendReq:req];
//    
    [self activityDidFinish:YES];
}

@end
