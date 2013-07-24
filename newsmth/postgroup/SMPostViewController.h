//
//  SMPostViewController.h
//  newsmth
//
//  Created by Maxwin on 13-7-23.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"

@interface SMPostItem : NSObject
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) SMPost *post;
@property (strong, nonatomic) SMWebLoaderOperation *op;
@property (assign, nonatomic) BOOL loadFail;
@end

@interface SMPostViewController : SMViewController
@property (strong, nonatomic) SMBoard *board;  // 版面
@property (assign, nonatomic) NSInteger gid;    // group id
@end
