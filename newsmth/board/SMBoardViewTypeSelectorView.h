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

@class SMBoardViewTypeSelectorView;
@protocol SMBoardViewTypeSelectorViewDelegate <NSObject>
- (void)boardViewTypeSelectorOnFavorButtonClick:(SMBoardViewTypeSelectorView *)v;
- (void)boardViewTypeSelectorOnSearchButtonClick:(SMBoardViewTypeSelectorView *)v;
@end

@interface SMBoardViewTypeSelectorView : UIControl
@property (assign, nonatomic) SMBoardViewType viewType;
@property (assign, nonatomic) BOOL isFavor;
@property (weak, nonatomic) id<SMBoardViewTypeSelectorViewDelegate> delegate;
@end
