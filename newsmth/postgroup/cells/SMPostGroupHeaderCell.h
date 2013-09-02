//
//  SMPostGroupHeaderCell.h
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPostGroupViewController.h"

@protocol SMPostGroupHeaderCellDelegate <NSObject>
- (void)postGroupHeaderCellOnReply:(SMPost *)post;
@optional
- (void)postGroupHeaderCellOnUsernameClick:(NSString *)username;
@end

@interface SMPostGroupHeaderCell : UITableViewCell
@property (strong, nonatomic) SMPostGroupCellData *data;
@property (weak, nonatomic) id<SMPostGroupHeaderCellDelegate> delegate;

+ (CGFloat)cellHeight;
@end
