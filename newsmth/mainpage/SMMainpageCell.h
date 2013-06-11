//
//  SMMainpageCell.h
//  newsmth
//
//  Created by Maxwin on 13-6-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPost.h"

@interface SMMainpageCell : UITableViewCell
+ (CGFloat)cellHeight:(SMPost *)post;

@property (strong, nonatomic) SMPost *post;
@end
