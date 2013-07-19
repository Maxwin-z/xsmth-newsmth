//
//  SMPostGroupViewController.h
//  newsmth
//
//  Created by Maxwin on 13-5-30.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import "SMBoard.h"

typedef NS_ENUM(NSInteger, SMPostGroupCellType) {
    SMPostGroupCellTypeHeader,
    SMPostGroupCellTypeLoading,
    SMPostGroupCellTypeFail,
    SMPostGroupCellTypeContent,
    SMPostGroupCellTypeAttach
};

@interface SMPostGroupViewController : SMViewController
@property (strong, nonatomic) SMBoard *board;  // 版面
@property (assign, nonatomic) NSInteger gid;    // group id
@property (assign, nonatomic) BOOL fromBoard;   // 从版面列表进入，不显示进入本版按钮
@end

@interface SMPostGroupItem : NSObject
@property (strong, nonatomic) SMPost *post;
@property (strong, nonatomic) SMWebLoaderOperation *op;
@property (assign, nonatomic) BOOL loadFail;
@end

@interface SMPostGroupCellData : NSObject
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) SMPostGroupItem *item;
@property (assign, nonatomic) SMPostGroupCellType type;
@property (strong, nonatomic) SMAttach *attach;
@end

