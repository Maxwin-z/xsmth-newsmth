//
//  SMPostGroupContentCell.h
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPost.h"

@class SMPostGroupContentCell;

@protocol SMPostGroupContentCellDelegate <NSObject>
- (void)postGroupContentCell:(SMPostGroupContentCell *)cell heightChanged:(CGFloat)height;
@optional
- (void)postGroupContentCell:(SMPostGroupContentCell *)cell shouldLoadUrl:(NSURL *)url;
@end

@interface SMPostGroupContentCell : UITableViewCell
@property (strong, nonatomic) SMPost* post;
@property (weak, nonatomic) id<SMPostGroupContentCellDelegate> delegate;
@end
