//
//  SMPostGroupViewController.h
//  newsmth
//
//  Created by Maxwin on 13-5-30.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"

@interface SMPostGroupViewController : SMViewController
@property (strong, nonatomic) NSString *board;  // 版面
@property (assign, nonatomic) NSInteger gid;    // group id
@property (assign, nonatomic) BOOL fromBoard;   // 从版面列表进入，不显示进入本版按钮
@end
