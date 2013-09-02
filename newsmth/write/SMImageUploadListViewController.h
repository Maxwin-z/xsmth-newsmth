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
{
    NSMutableArray *_lastUploads;
}
@property (strong, nonatomic) SMImageUploader *uploader;
- (void)setLastUploads:(NSArray *)lastUploads;
@end
