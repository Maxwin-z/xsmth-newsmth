//
//  SMImageUploader.m
//  newsmth
//
//  Created by Maxwin on 13-7-8.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMImageUploader.h"
#import "SMWebLoaderOperation.h"
//#import "ASIFormDataRequest.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SMUtils.h"

typedef NS_ENUM(NSInteger, SMUploadAct) {
    SMUploadActAdd = 1,
    SMUploadActDelete = 2
};

@implementation SMUploadData
@end

@interface SMImageUploader ()<SMWebLoaderOperationDelegate, ASIProgressDelegate>
@property (strong, nonatomic) SMWebLoaderOperation *uploadOp;
@property (strong, nonatomic) SMWebLoaderOperation *deleteOp;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) BOOL isUploading;
@end

@implementation SMImageUploader

- (id)init
{
    self = [super init];
    if (self) {
        _currentIndex = 0;
        _queue = dispatch_queue_create("me.maxwin.newsmth", DISPATCH_QUEUE_SERIAL);
        _uploadQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addAssets:(NSArray *)assets
{
    // notify new assets comming.
    if ([_delegate respondsToSelector:@selector(imageUploaderOnProgressChange:withProgress:)]) {
        [_delegate imageUploaderOnProgressChange:self withProgress:0];
    }
    
    if ([_delegateForList respondsToSelector:@selector(imageUploaderOnProgressChange:withProgress:)]) {
        [_delegateForList imageUploaderOnProgressChange:self withProgress:0];
    }
    
    dispatch_async(_queue, ^{
        NSArray *files = [self resizeImages:assets];
        NSMutableArray *datas = [[NSMutableArray alloc] initWithCapacity:files.count];
        for (int i = 0 ; i != files.count; ++i) {
            ALAsset *asset = assets[i];
            SMUploadData *data = [[SMUploadData alloc] init];
            data.file = files[i];
            [datas addObject:data];
            data.thumbImage = [UIImage imageWithCGImage:asset.thumbnail];
        }
        [_uploadQueue addObjectsFromArray:datas];

        // start upload
        [self next];
    });
}

- (NSArray *)resizeImages:(NSArray *)assets
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:assets.count];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd_HH-mm-ss"];
    
    for (int i = 0; i != assets.count; ++i) {
        ALAsset *asset = assets[i];
        NSString *filePath = nil;
        NSDate *now = [NSDate date];
        
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(assetRepresentation.size);
        NSUInteger buffered = [assetRepresentation getBytes:buffer fromOffset:0.0 length:assetRepresentation.size error:nil];
        NSData *sourceData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        if([SMUtils isGif:sourceData]){
            filePath = [NSString stringWithFormat:@"%@/xsmth_%d_%@.gif", docPath, i, [formatter stringFromDate:now]];
            [sourceData writeToFile:filePath atomically:YES];
        }
        else{
            filePath = [NSString stringWithFormat:@"%@/xsmth_%d_%@.jpg", docPath, i, [formatter stringFromDate:now]];

            CGImageRef fullResImage = [assetRepresentation fullResolutionImage];
            NSString *adjustment = [[assetRepresentation metadata] objectForKey:@"AdjustmentXMP"];
            if (adjustment) {
                NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
                CIImage *image = [CIImage imageWithCGImage:fullResImage];
                
                NSError *error = nil;
                NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                             inputImageExtent:image.extent
                                                                        error:&error];
                CIContext *context = [CIContext contextWithOptions:nil];
                if (filterArray && !error) {
                    for (CIFilter *filter in filterArray) {
                        [filter setValue:image forKey:kCIInputImageKey];
                        image = [filter outputImage];
                    }
                    fullResImage = [context createCGImage:image fromRect:[image extent]];
                }
            }
            UIImage *imageOriginal = [UIImage imageWithCGImage:fullResImage
                                                         scale:[assetRepresentation scale]
                                                   orientation:(UIImageOrientation)[assetRepresentation orientation]];
            
            UIImage *imageResized = [self resizeImage:imageOriginal toMaxSize:800.0f];
            
            NSData *imageData = UIImageJPEGRepresentation(imageResized, 0.9);
            
            [imageData writeToFile:filePath atomically:YES];
        }
        
        [files addObject:filePath];
    }
    
    return files;
}

- (UIImage *)resizeImage:(UIImage *)image toMaxSize:(CGFloat)maxSize
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat scale = 1.0f;
    if (width > height && height > maxSize) {
        scale = maxSize / height;
    }
    if (height > width && width > maxSize) {
        scale = maxSize / width;
    }
    
    XLog_d(@"scale: %f", scale);
    
    UIGraphicsBeginImageContext(CGSizeMake(width * scale, height * scale));
    [image drawInRect:CGRectMake(0, 0, width * scale, height * scale)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (void)removeAtIndex:(NSInteger)index
{
    if (index < _currentIndex) {    // already uploaded
        --_currentIndex;
        SMUploadData *data = _uploadQueue[index];
        NSString *deleteUrl = [NSString stringWithFormat:URL_PROTOCOL @"//www.newsmth.net/bbsupload.php?act=delete&attachname=%@", data.key];
        _deleteOp = [[SMWebLoaderOperation alloc] init];
        _deleteOp.delegate = self;
        [_deleteOp loadUrl:deleteUrl withParser:@"upload"];
        
        [_uploadQueue removeObjectAtIndex:index];
    } else if (index == _currentIndex) {    // uploading
        [_uploadOp cancel];
        [_uploadQueue removeObjectAtIndex:index];
        [self next];
    } else {    // in queue
        [_uploadQueue removeObjectAtIndex:index];
    }
}

- (void)next
{
    if (_isUploading) { // 防止重入
        return ;
    }

    dispatch_async(_queue, ^{
        if (_currentIndex >= _uploadQueue.count) {    // done
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_delegate respondsToSelector:@selector(imageUploaderOnFinish:)]) {
                    [_delegate imageUploaderOnFinish:self];
                }
                if ([_delegateForList respondsToSelector:@selector(imageUploaderOnFinish:)]) {
                    [_delegateForList imageUploaderOnFinish:self];
                }
            });
            return;
        }
        
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:URL_PROTOCOL @"//www.newsmth.net/bbsupload.php?act=add"]];
        request.uploadProgressDelegate = self;
        
        SMUploadData *data = _uploadQueue[_currentIndex];
        data.status = SMUploadStatusUploading;
        
        NSString *filename = data.file;
        [request addFile:filename forKey:@"attachfile0"];
        [request addPostValue:@(1) forKey:@"counter"];
        [request addPostValue:@(5242880) forKey:@"MAX_FILE_SIZE"];
        
        _uploadOp = [[SMWebLoaderOperation alloc] init];
        _uploadOp.delegate = self;
        _isUploading = YES;
        [_uploadOp loadRequest:request withParser:@"upload"];
    });
}

- (void)cancel
{
    _currentIndex = _uploadQueue.count;
    [_uploadOp cancel];
    _uploadOp = nil;
    _isUploading = NO;
    [self next];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    if (opt == _uploadOp) {
        SMUpload *uploadResult = opt.data;
        if (uploadResult.items.count > 0 && uploadResult.act == SMUploadActAdd) {
            SMUploadItem *item = [uploadResult.items lastObject];
            SMUploadData *data = _uploadQueue[_currentIndex];
            data.status = SMUploadStatusSuccess;
            data.key = item.key;
            
            ++_currentIndex;
            _isUploading = NO;
            [self next];
        }
        [SMUtils trackEventWithCategory:@"upload" action:@"success" label:nil];
    } else {    // delete op
        [SMUtils trackEventWithCategory:@"upload" action:@"delete" label:nil];
        XLog_d(@"删除成功");
    }
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    if (opt == _uploadOp) {
        SMUploadData *data = _uploadQueue[_currentIndex];
        data.status = SMUploadStatusFail;
        
        ++_currentIndex;
        _isUploading = NO;
        [self next];
        [SMUtils trackEventWithCategory:@"upload" action:@"fail" label:nil];
    }
    XLog_e(@"upload: %@", error.message);
}

#pragma mark - ASIProgressDelegate
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    unsigned long long total = request.postLength;
    if (total > 0) {
        CGFloat progress = request.totalBytesSent / total;
        SMUploadData *data = _uploadQueue[_currentIndex];
        data.progress = progress;
        
        if ([_delegate respondsToSelector:@selector(imageUploaderOnProgressChange:withProgress:)]) {
            [_delegate imageUploaderOnProgressChange:self withProgress:progress];
        }
        
        if ([_delegateForList respondsToSelector:@selector(imageUploaderOnProgressChange:withProgress:)]) {
            [_delegateForList imageUploaderOnProgressChange:self withProgress:progress];
        }
    }
}

@end
