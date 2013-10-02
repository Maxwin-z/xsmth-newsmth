//
//  SMPageCell.h
//  newsmth
//
//  Created by Maxwin on 13-10-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPostViewController.h"

@protocol SMPageCellDelegate <NSObject>
- (void)pageCellDoRetry:(SMPostPageItem *)pageItem;
@end

@interface SMPageCell : UITableViewCell
@property (strong, nonatomic) SMPostPageItem *pageItem;
@property (weak, nonatomic) id<SMPageCellDelegate> delegate;
@end
