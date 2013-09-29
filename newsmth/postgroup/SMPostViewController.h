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

// 分页信息
@interface SMPostPageItem : NSObject
@property (assign, nonatomic) BOOL isPageLoaded;
@property (assign, nonatomic) NSInteger gid;
@property (assign, nonatomic) NSInteger start;
@property (assign, nonatomic) NSInteger pno;
@property (assign, nonatomic) NSInteger tpage;
@property (assign, nonatomic) NSInteger pageIndex;
@end

@interface SMPostViewController : SMViewController
@property (strong, nonatomic) SMBoard *board;  // 版面
@property (assign, nonatomic) NSInteger gid;    // group id
@property (assign, nonatomic) NSInteger start;
@property (strong, nonatomic) SMPostPageItem *currentPageItem;
@property (assign, nonatomic) BOOL fromBoard;

@property (strong, nonatomic) NSString *postUrl;

@end
