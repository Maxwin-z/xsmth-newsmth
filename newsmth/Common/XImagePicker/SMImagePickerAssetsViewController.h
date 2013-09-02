//
//  SMImagePickerAssetsViewController.h
//  newsmth
//
//  Created by Maxwin on 13-7-4.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import "SMImagePickerViewController.h"
#import <AssetsLibrary/ALAssetsGroup.h>

@interface SMImagePickerViewController (Private)
- (void)selectAsset:(ALAsset *)asset;
@end

@interface SMImagePickerAssetsViewController : SMViewController
@property (strong, nonatomic) ALAssetsGroup *group;
@property (strong, nonatomic) SMImagePickerViewController *imagePickerViewController;
@end
