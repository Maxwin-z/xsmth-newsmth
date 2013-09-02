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
    UIColor *colorNormal;
    UIColor *colorPressed;
    UIColor *shadowColorNormal;
    UIColor *shadowColorPressed;
    
    switch (buttonType) {
        case SMButtonTypeGray:
            imageNormal = @"button_gray_default";
            imagePressed = @"button_gray_pressed";
            colorNormal = colorPressed = SMRGB(0x32, 0x32, 0x32);
            shadowColorNormal = shadowColorPressed = SMRGB(0xff, 0xff, 0xff);
            break;
        case SMButtonTypeBlue:
            imageNormal = @"button_blue_default";
            imagePressed = @"button_blue_pressed";
            colorNormal = colorPressed  = SMRGB(0xff, 0xff, 0xff);
            shadowColorNormal = shadowColorPressed = SMRGB(0x32, 0x32, 0x32);
            break;
        case SMButtonTypeRed:
            imageNormal = @"button_red_default";
            imagePressed = @"button_red_pressed";
            colorNormal = colorPressed  = SMRGB(0xff, 0xff, 0xff);
            shadowColorNormal = shadowColorPressed = SMRGB(0x32, 0x32, 0x32);
            break;
        default:
            break;
    }
    
    self.backgroundColor = nil;
    
    self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    
    [self setBackgroundImage:[self stretchedImage:[UIImage imageNamed:imageNormal]] forState:UIControlStateNormal];
    [self setBackgroundImage:[self stretchedImage:[UIImage imageNamed:imagePressed]] forState:UIControlStateHighlighted];
    [self setTitleColor:colorNormal forState:UIControlStateNormal];
    [self setTitleColor:colorPressed forState:UIControlStateHighlighted];
    [self setTitleShadowColor:shadowColorNormal forState:UIControlStateNormal];
    [self setTitleShadowColor:shadowColorPressed forState:UIControlStateHighlighted];
}

- (UIImage *)stretchedImage:(UIImage *)image
{
    return [image stretchableImageWithLeftCapWidth:(image.size.width + 1) / 2 topCapHeight:(image.size.height + 1) / 2];
}


@end
