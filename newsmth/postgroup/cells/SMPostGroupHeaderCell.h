//
//  SMPostGroupHeaderCell.h
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPost.h"

@protocol SMPostGroupHeaderCellDelegate <NSObject>
- (void)postGroupHeaderCellOnReply:(SMPost *)post;
@end

@interface SMPostGroupHeaderCell : UITableViewCell
@property (strong, nonatomic) SMPost *post;
@property (weak, nonatomic) id<SMPostGroupHeaderCellDelegate> delegate;

+ (CGFloat)cellHeight;
@end
