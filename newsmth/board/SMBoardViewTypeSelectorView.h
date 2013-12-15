//
//  SMBoardViewTypeSelectorView.h
//  newsmth
//
//  Created by Maxwin on 13-12-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SMBoardViewTypeTztSortByReply,
    SMBoardViewTypeTztSortByPost,
    SMBoardViewTypeNormal
}SMBoardViewType;

@interface SMBoardViewTypeSelectorView : UIControl
@property (assign, nonatomic) SMBoardViewType viewType;
@end
