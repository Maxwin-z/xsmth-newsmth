//
//  SMPostGroupAttachCell.h
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XImageView.h"

@interface SMPostGroupAttachCell : UITableViewCell
@property (strong, nonatomic) NSString *url;

+ (CGFloat)cellHeight:(NSString *)url;
@property (weak, nonatomic) IBOutlet XImageView* imageViewForAttach;
@end
