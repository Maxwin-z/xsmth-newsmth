//
//  UIView+Utils.m
//  newsmth
//
//  Created by Maxwin on 14-1-1.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)
- (void)removeAllSubviews
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *v = obj;
        [v removeFromSuperview];
    }];
}

- (void)highlight
{
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 1;
}
@end
