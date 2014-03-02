//
//  SMWeiXinSessionActivity.h
//  newsmth
//
//  Created by Maxwin on 14-3-2.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

#define SMActivityTypePostToWXSession @"SMActivityTypePostToWXSession"
#define SMActivityTypePostToWXTimeline @"SMActivityTypePostToWXTimeline"

@interface SMWeiXinSessionActivity : UIActivity
{
    enum WXScene _scene;
}
@end
