//
//  XScrollIndicator.h
//  HelloScrollIndicator
//
//  Created by Maxwin on 13-9-27.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XScrollIndicator : UIControl
@property (strong, nonatomic) NSArray *titles;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) UIFont *normalFont;
@property (strong, nonatomic) UIFont *highlightFont;
@property (assign, nonatomic) BOOL isDragging;
@end
