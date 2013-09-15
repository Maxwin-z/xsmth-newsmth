//
//  SMMailCell.h
//  newsmth
//
//  Created by Maxwin on 13-9-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMMailCell : UITableViewCell
@property (strong, nonatomic) SMMailItem *item;

+ (CGFloat)cellHeight:(SMMailItem *)item;
@end
