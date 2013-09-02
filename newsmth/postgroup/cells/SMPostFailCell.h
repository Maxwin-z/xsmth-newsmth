//
//  SMPostFailCell.h
//  newsmth
//
//  Created by Maxwin on 13-7-2.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPostGroupViewController.h"

@class SMPostFailCell;
@protocol SMPostFailCellDelegate <NSObject>
@optional
- (void)postFailCellOnRetry:(SMPostFailCell *)cell;
@end

@interface SMPostFailCell : UITableViewCell
@property (strong, nonatomic) SMPostGroupCellData *cellData;
@property (weak, nonatomic) id<SMPostFailCellDelegate> delegate;
@end
