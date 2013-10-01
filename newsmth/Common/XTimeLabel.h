//
//  XTimeLabel.h
//  newsmth
//
//  Created by Maxwin on 13-10-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTimeLabel : UILabel
@property (strong, nonatomic) NSDate *beginTime;
@property (strong, nonatomic) NSString *formatter;
@end
