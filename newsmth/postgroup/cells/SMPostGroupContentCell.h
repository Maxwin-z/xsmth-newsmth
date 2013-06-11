//
//  SMPostGroupContentCell.h
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPost.h"

@interface SMPostGroupContentCell : UITableViewCell
@property (strong, nonatomic) SMPost* post;

+ (CGFloat)cellHeight:(SMPost *)post;
@end
