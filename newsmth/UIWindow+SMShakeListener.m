//
//  UIWindow+SMShakeListener.m
//  newsmth
//
//  Created by Maxwin on 13-12-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "UIWindow+SMShakeListener.h"

@implementation UIWindow (SMShakeListener)
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFYCATION_SHAKE object:self];
        [SMUtils trackEventWithCategory:@"setting" action:@"shake" label:nil];
    }
}
@end
