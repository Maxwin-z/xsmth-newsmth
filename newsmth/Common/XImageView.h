//
//  XImageView.h
//  newsmth
//
//  Created by Maxwin on 13-5-31.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^XImageViewGetSizeBlock)(long long size);
typedef void (^XImageViewUpdateProgressBlock)(CGFloat progress);
typedef void (^XImageViewDidLoadBlock)(void);
typedef void (^XImageViewDidFailBlock)(void);

@class XImageView;
@protocol XImageViewDelegate <NSObject>
@optional
- (void)xImageViewDidLoad:(XImageView *)imageView;
- (void)xImageViewDidFail:(XImageView *)imageView;

- (void)xImageView:(XImageView *)imageView didGetSize:(long long)size;
- (void)xImageView:(XImageView *)imageView updateProgress:(CGFloat)progress;
@end

@interface XImageView : UIImageView
@property (weak, nonatomic) id<XImageViewDelegate> delegate;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIImage *defaultImage;
//@property (assign, nonatomic)
/*!
 * auto load image after set url. defalt is YES.
 */
@property (assign, nonatomic) BOOL autoLoad;    // v2.4 允许手动加载图片

@property (copy, nonatomic) XImageViewGetSizeBlock getSizeBlock;
@property (copy, nonatomic) XImageViewUpdateProgressBlock updateProgressBlock;
@property (copy, nonatomic) XImageViewDidLoadBlock didLoadBlock;
@property (copy, nonatomic) XImageViewDidFailBlock didFailBlock;

@end
