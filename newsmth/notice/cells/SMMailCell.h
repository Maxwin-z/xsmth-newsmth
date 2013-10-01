//
//  SMMailCell.h
//  newsmth
//
//  Created by Maxwin on 13-9-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMMailCellDelegate <NSObject>
@optional
- (void)mailCellOnUserClick:(NSString *)username;
@end

@interface SMMailCell : UITableViewCell
@property (strong, nonatomic) SMMailItem *item;
@property (weak, nonatomic) id<SMMailCellDelegate> delegate;
+ (CGFloat)cellHeight:(SMMailItem *)item;
@end
