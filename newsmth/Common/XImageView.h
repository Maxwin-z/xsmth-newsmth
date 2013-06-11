//
//  XImageView.h
//  newsmth
//
//  Created by Maxwin on 13-5-31.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XImageView;
@protocol XImageViewDelegate <NSObject>
@optional
- (void)xImageViewDidLoad:(XImageView *)imageView;
- (void)xImageViewDidFail:(XImageView *)imageView;
@end

@interface XImageView : UIImageView
@property (weak, nonatomic) id<XImageViewDelegate> delegate;
@property (strong, nonatomic) NSString *url;
//@property (assign, nonatomic) 
@end
