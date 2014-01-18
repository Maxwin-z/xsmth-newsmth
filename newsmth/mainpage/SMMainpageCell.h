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
+ (CGFloat)cellHeight:(SMPost *)post withWidth:(CGFloat)width;

@property (strong, nonatomic) SMPost *post;
@end

@interface SMMainpageCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelForBoardName;
@property (weak, nonatomic) IBOutlet UILabel *labelForAuthor;
@end

