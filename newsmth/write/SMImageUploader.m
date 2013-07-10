//
//  SMImageUploader.m
//  newsmth
//
//  Created by Maxwin on 13-7-8.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMImageUploader.h"
#import "SMWebLoaderOperation.h"
#import "ASIFormDataRequest.h"

typedef NS_ENUM(NSInteger, SMUploadAct) {
    SMUploadActAdd = 1,
    SMUploadActDelete = 2
};

@implementation SMUploadData
@end

@interface SMImageUploader ()<SMWebLoaderOperationDelegate, ASIProgressDelegate>
@property (strong, nonatomic) SMWebLoaderOperation *uploadOp;
@end

@implementation SMImageUploader

- (void)setFiles:(NSArray *)files
{
    _files = files;
    NSMutableArray *datas = [[NSMutableArray alloc] initWithCapacity:_files.count];
    for (int i = 0 ; i != _files.count; ++i) {
        SMUploadData *data = [[SMUploadData alloc] init];
        data.file = _files[i];
        [datas addObject:data];
    }
    _uploadDatas = datas;
}

- (void)start
{
    _currentIndex = 0;
    [self next];
}

- (void)next
{
    if (_currentIndex >= _files.count) {    // done
        if ([_delegate respondsToSelector:@selector(imageUploaderOnFinish:)]) {
            [_delegate imageUploaderOnFinish:self];
        }
        return;
    }
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.newsmth.net/bbsupload.php?act=add"]];
    request.uploadProgressDelegate = self;
    
    SMUploadData *data = _uploadDatas[_currentIndex];
    data.status = SMUploadStatusUploading;
    
    NSString *filename = data.file;
    [request addFile:filename forKey:@"attachfile0"];
    [request addPostValue:@(1) forKey:@"counter"];
    [request addPostValue:@(5242880) forKey:@"MAX_FILE_SIZE"];

    _uploadOp = [[SMWebLoaderOperation alloc] init];
    _uploadOp.delegate = self;
    [_uploadOp loadRequest:request withParser:@"upload"];
}

- (void)cancel
{
    _currentIndex = _uploadDatas.count;
    [_uploadOp cancel];
    _uploadOp = nil;
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    SMUpload *uploadResult = opt.data;
    if (uploadResult.items.count > 0 && uploadResult.act == SMUploadActAdd) {
        SMUploadItem *item = [uploadResult.items lastObject];
        SMUploadData *data = _uploadDatas[_currentIndex];
        data.status = SMUploadStatusSuccess;
        data.key = item.key;
        
        ++_currentIndex;
        [self next];
    }
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    SMUploadData *data = _uploadDatas[_currentIndex];
    data.status = SMUploadStatusFail;
    
    ++_currentIndex;
    [self next];
    XLog_e(@"upload: %@", error.message);
}

#pragma mark - ASIProgressDelegate
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    unsigned long long total = request.postLength;
    if (total > 0) {
        CGFloat progress = request.totalBytesSent / total;
        SMUploadData *data = _uploadDatas[_currentIndex];
        data.progress = progress;
        
        if ([_delegate respondsToSelector:@selector(imageUploaderOnProgressChange:withProgress:)]) {
            [_delegate imageUploaderOnProgressChange:self withProgress:progress];
        }
    }
}

@end
