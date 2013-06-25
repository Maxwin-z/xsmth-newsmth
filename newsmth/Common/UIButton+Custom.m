//
//  UIButton+Custom.m
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "UIButton+Custom.h"

@implementation UIButton (Custom)
+ (id)buttonWithSMType:(SMButtonType)buttonType
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *imageName;
    switch (buttonType) {
        case SMButtonTypeBack:
            imageName = @"button_back";
            break;
        case SMButtonTypeCompose:
            imageName = @"button_compose";
            break;
        case SMButtonTypeReply:
            imageName = @"button_reply";
            break;
        default:
            break;
    }
    
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30.0f, 30.0f);
    button.showsTouchWhenHighlighted = YES;
    
    return button;
}
@end
