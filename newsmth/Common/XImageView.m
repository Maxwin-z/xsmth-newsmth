//
//  XImageView.m
//  newsmth
//
//  Created by Maxwin on 13-5-31.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "XImageView.h"
#import "SMHttpRequest.h"
//#import "ASIHTTPRequestDelegate.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import "XImageViewCache.h"

static NSOperationQueue *downloadQueue;

@interface XImageView ()<ASIHTTPRequestDelegate, ASIProgressDelegate>
@property (strong, nonatomic) SMHttpRequest *downloadRequest;
@property (strong, nonatomic) UILabel *labelForProgress;
@property (assign, nonatomic) BOOL isLoaded;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@end

@implementation XImageView

+ (NSOperationQueue *)queue
{
    if (downloadQueue == nil) {
        downloadQueue = [[NSOperationQueue alloc] init];
        downloadQueue.maxConcurrentOperationCount = 2;
    }
    return downloadQueue;
}

- (id)init
{
    self = [super init];
    [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.autoLoad = YES;
    
    _labelForProgress = [[UILabel alloc] initWithFrame:self.bounds];
    _labelForProgress.backgroundColor = [UIColor clearColor];
    _labelForProgress.textAlignment = UITextAlignmentCenter;
    _labelForProgress.textColor = [UIColor blackColor];
    _labelForProgress.font = [UIFont systemFontOfSize:12.0f];
    _labelForProgress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_labelForProgress];
}

- (void)dealloc
{
    _labelForProgress = nil;
    [_downloadRequest clearDelegatesAndCancel];
}

- (void)setUrl:(NSString *)url
{
    if (self.isLoaded && [_url isEqualToString:url]) {
        return;
    }
    
    if (![_url isEqualToString:url]) {  // url change
        self.isLoaded = NO;
        self.autoLoad = self.autoLoad;  // 重置自动加载选项
    }
    
    _url = url;
    
    // show default image;
    if (_defaultImage == nil) {
        _defaultImage = [UIImage imageNamed:@"placeholder.jpg"];
    }
    self.image = _defaultImage;
    
//    self.backgroundColor = [UIColor lightGrayColor];
    
    if ([[XImageViewCache sharedInstance] isInCache:url]) {
        self.isLoaded = YES;
        self.labelForProgress.hidden = YES;
        __block NSString *currentUrl = [url copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [[XImageViewCache sharedInstance] getImage:currentUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_url isEqualToString:currentUrl]) {
                    self.image = image;
                    if ([_delegate respondsToSelector:@selector(xImageViewDidLoad:)]) {
                        [_delegate xImageViewDidLoad:self];
                    }
                    if (self.didLoadBlock) {
                        self.didLoadBlock();
                    }
                } else {
                    XLog_d(@"url changed from[%@] to[%@]", currentUrl, _url);
                }
            });
        });
    } else if (self.autoLoad) {
        [_downloadRequest clearDelegatesAndCancel];
        _downloadRequest = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:url]];
        _downloadRequest.delegate = self;
        _downloadRequest.downloadProgressDelegate = self;
        _labelForProgress.hidden = YES;
        [[[self class] queue] addOperation:_downloadRequest];
    } else {    // try to get image size by http HEAD
        SMHttpRequest *headReq = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:url]];
        headReq.requestMethod = @"HEAD";
        [headReq setHeadersReceivedBlock:^(NSDictionary *responseHeaders) {
            long long size = [responseHeaders[@"Content-Length"] longLongValue];
            XLog_d(@"image size: %@, %@", _url, @(size));
            if (size > 0) {
                self.labelForProgress.text = [NSString stringWithFormat:@"点击加载图片 (%@)", [SMUtils formatSize:size]];
                if (self.getSizeBlock) {
                    self.getSizeBlock(size);
                }
            }
        }];
        [headReq startAsynchronous];
    }
}

- (void)setAutoLoad:(BOOL)autoLoad
{
    _autoLoad = autoLoad;
    if (!autoLoad && !self.isLoaded) {
        self.labelForProgress.hidden = NO;
        self.labelForProgress.text = @"点击加载图片";
        [self addStartDownloadTapGesture];
    }
}

- (void)addStartDownloadTapGesture
{
    self.userInteractionEnabled = YES;
    if (self.tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    }
    [self addGestureRecognizer:_tapGesture];
}

- (void)onTap
{
    self.userInteractionEnabled = NO;
    [self removeGestureRecognizer:_tapGesture];
    self.autoLoad = YES;
    self.url = _url;    // retry
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.responseData.length != request.contentLength) {
        
        NSRange range = [request.url.absoluteString rangeOfString:@"att.mysmth.net"];
        if (range.location != NSNotFound) {
            NSString *alternate_url = [
            self.url stringByReplacingOccurrencesOfString:@"att.mysmth.net"
                                       withString:@"newsmth.net"];
            // 替换域名后重试
            [_downloadRequest clearDelegatesAndCancel];
            _downloadRequest = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:alternate_url]];
            _downloadRequest.delegate = self;
            _downloadRequest.downloadProgressDelegate = self;
            _labelForProgress.hidden = YES;
            [[[self class] queue] addOperation:_downloadRequest];
            return;
        }
        [self requestFailed:request];
        return ;
    }
    _labelForProgress.hidden = YES;
    self.isLoaded = YES;
    self.image = [UIImage imageWithData:request.responseData];
    [[XImageViewCache sharedInstance] setImageData:request.responseData forUrl:_url];
    if ([_delegate respondsToSelector:@selector(xImageViewDidLoad:)]) {
        [_delegate xImageViewDidLoad:self];
    }
    if (self.didLoadBlock) {
        self.didLoadBlock();
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    XLog_e(@"download image fail, %@", _url);
    _labelForProgress.hidden = NO;
    _labelForProgress.text = @"下载失败，点击重试";
    self.isLoaded = NO;
    [self addStartDownloadTapGesture];
    
    if (self.didFailBlock) {
        self.didFailBlock();
    }
}

#pragma mark - ASIProgressDelegate
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    long long total = request.contentLength;
    if (total > 0) {
        CGFloat progress = (CGFloat)(request.totalBytesRead * 1.0 / total);
        [self updateProgress:progress];
        if (self.updateProgressBlock) {
            self.updateProgressBlock(progress);
        }
    }
}

- (void)updateProgress:(CGFloat)progress
{
    _labelForProgress.hidden = NO;
    _labelForProgress.text = [NSString stringWithFormat:@"%d%%", (int)(progress * 100)];
}

@end
