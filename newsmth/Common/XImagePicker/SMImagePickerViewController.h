//
//  SMImagePickerViewController.h
//  newsmth
//
//  Created by Maxwin on 13-7-4.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import <AssetsLibrary/ALAsset.h>

@protocol SMImagePickerViewDelegate <NSObject>
@optional
- (void)imagePickerViewControllerDidSelectAssets:(NSArray *)assets;
@end

@interface SMImagePickerViewController : SMViewController
@property (weak, nonatomic) id<SMImagePickerViewDelegate> delegate;
@end
