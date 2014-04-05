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

- (void)postGroupContentCellOnReply:(SMPostGroupContentCell *)cell;
- (void)postGroupContentCellOnForward:(SMPostGroupContentCell *)cell;
- (void)postGroupContentCellOnSearch:(SMPostGroupContentCell *)cell;
- (void)postGroupContentCellOnMoreAction:(SMPostGroupContentCell *)cell;

- (void)postGroupContentCell:(SMPostGroupContentCell *)cell fullHtml:(NSString *)html;

@optional
- (void)postGroupContentCell:(SMPostGroupContentCell *)cell shouldLoadUrl:(NSURL *)url;
@end

@interface SMPostGroupContentCell : UITableViewCell
@property (weak, nonatomic) id<SMPostGroupContentCellDelegate> delegate;
@property (strong, nonatomic, readonly) SMPost *post;

+ (CGFloat)cellHeight:(SMPost *)post withWidth:(CGFloat)width;

- (void)setPost:(SMPost *)post withOptimize:(BOOL)optimizeForIP4;

- (void)hideActionView;
@end
