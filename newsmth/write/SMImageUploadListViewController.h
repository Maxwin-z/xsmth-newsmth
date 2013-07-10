//
//  SMImageUploadListViewController.h
//  newsmth
//
//  Created by Maxwin on 13-7-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import "SMImageUploader.h"

@interface SMImageUploadListViewController : SMViewController
@property (strong, nonatomic) SMImageUploader *uploader;
@property (strong, nonatomic) NSArray *lastUploads;
@end
