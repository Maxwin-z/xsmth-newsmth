//
//  SMFontSelectorViewController.h
//  newsmth
//
//  Created by Maxwin on 13-10-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMFontSelectorViewController : UITableViewController
@property (strong, nonatomic) void (^fontSelectedBlock)(NSString *fontName);
@property (strong, nonatomic) UIFont *selectedFont;
@end
