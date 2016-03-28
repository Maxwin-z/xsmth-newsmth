//
//  SMImagePickerAssetsCell.h
//  newsmth
//
//  Created by Maxwin on 13-7-5.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMImagePickerAssetsCellDelegate <NSObject>
@optional
- (void)imagePickerAssetsCellOnClickAtIndex:(NSInteger)index;
@end

@interface SMImagePickerAssetsCell : UITableViewCell
+ (CGFloat)cellHeight:(CGFloat)width;
- (void)setAssets:(NSArray *)assets start:(NSInteger)start width:(CGFloat)cellWidth;

@property (weak, nonatomic) id<SMImagePickerAssetsCellDelegate> delegate;
@end
