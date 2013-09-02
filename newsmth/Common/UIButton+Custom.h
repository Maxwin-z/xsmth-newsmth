//
//  UIButton+Custom.h
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SMButtonType) {
    SMButtonTypeGray,
    SMButtonTypeBlue,
    SMButtonTypeRed
};

@interface UIButton (Custom)
- (void)setButtonSMType:(SMButtonType)buttonType;
@end
