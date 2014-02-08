//
//  SMBoardCell.h
//  newsmth
//
//  Created by Maxwin on 13-6-13.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPost.h"

@protocol SMBoardCellDelegate <NSObject>
@optional
- (void)boardCellOnUserClick:(NSString *)username;
@end

@interface SMBoardCell : UITableViewCell
@property (strong, nonatomic) SMPost *post;
@property (weak, nonatomic) id<SMBoardCellDelegate> delegate;

+ (CGFloat)cellHeight:(SMPost *)post withWidth:(CGFloat)width;
@end
