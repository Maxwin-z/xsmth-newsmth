//
//  SMImagePickerAssetsViewController.h
//  newsmth
//
//  Created by Maxwin on 13-7-4.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import <AssetsLibrary/ALAssetsGroup.h>

@interface SMImagePickerAssetsViewController : SMViewController
@property (strong, nonatomic) ALAssetsGroup *group;
@end
