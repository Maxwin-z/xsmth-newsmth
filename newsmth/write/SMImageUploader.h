//
//  SMImageUploader.h
//  newsmth
//
//  Created by Maxwin on 13-7-8.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SMUploadStatus) {
    SMUploadStatusInit,
    SMUploadStatusUploading,
    SMUploadStatusSuccess,
    SMUploadStatusFail
};


@class SMImageUploader;

@protocol SMImageUploaderDelegate <NSObject>
- (void)imageUploaderOnFinish:(SMImageUploader *)uploader;
@optional
- (void)imageUploaderOnProgressChange:(SMImageUploader *)uploader withProgress:(CGFloat)progress;

@end

@interface SMUploadData : NSObject
@property (strong, nonatomic) NSString *file;
@property (strong, nonatomic) NSString *key;
@property (assign, nonatomic) SMUploadStatus status;
@property (assign, nonatomic) CGFloat progress;
@end


@interface SMImageUploader : NSObject
@property (strong, nonatomic) NSArray *files;
@property (strong, nonatomic, readonly) NSArray *uploadDatas;
@property (assign, nonatomic, readonly) NSInteger currentIndex;
@property (weak, nonatomic) id<SMImageUploaderDelegate> delegate;

- (void)start;
- (void)cancel;

@end
