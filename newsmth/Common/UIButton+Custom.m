//
//  UIButton+Custom.m
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "UIButton+Custom.h"

@implementation UIButton (Custom)

- (void)setButtonSMType:(SMButtonType)buttonType
{
    NSString *imageNormal;
    NSString *imagePressed;
    
    switch (buttonType) {
        case SMButtonTypeGray:
            imageNormal = @"button_gray_default";
            imagePressed = @"button_gray_pressed";
            break;
        case SMButtonTypeBlue:
            imageNormal = @"button_blue_default";
            imagePressed = @"button_blue_pressed";
            break;
        default:
            break;
    }
    
    self.backgroundColor = nil;
    
    [self setBackgroundImage:[self stretchedImage:[UIImage imageNamed:imageNormal]] forState:UIControlStateNormal];
    [self setBackgroundImage:[self stretchedImage:[UIImage imageNamed:imagePressed]] forState:UIControlStateHighlighted];
}

- (UIImage *)stretchedImage:(UIImage *)image
{
    return [image stretchableImageWithLeftCapWidth:(image.size.width + 1) / 2 topCapHeight:(image.size.height + 1) / 2];
}


@end
