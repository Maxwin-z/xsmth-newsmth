//
//  XImageView.m
//  newsmth
//
//  Created by Maxwin on 13-5-31.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "XImageView.h"
#import "SMHttpRequest.h"
#import "ASIHTTPRequestDelegate.h"
#import "XImageViewCache.h"

static NSOperationQueue *downloadQueue;

@interface XImageView ()<ASIHTTPRequestDelegate, ASIProgressDelegate>
@property (strong, nonatomic) SMHttpRequest *downloadRequest;
@property (strong, nonatomic) UILabel *labelForProgress;
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

- (void)setUrl:(NSString *)url
{
    if ([_url isEqualToString:url]) {
        return;
    }
    _url = url;
    if ([[XImageViewCache sharedInstance] isInCache:url]) {
        __block NSString *currentUrl = [url copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [[XImageViewCache sharedInstance] getImage:currentUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_url isEqualToString:currentUrl]) {
                    self.image = image;
                } else {
                    XLog_d(@"url changed from[%@] to[%@]", currentUrl, _url);
                }
            });
        });
    } else {
        [_downloadRequest clearDelegatesAndCancel];
        _downloadRequest = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:url]];
        _downloadRequest.delegate = self;
        _downloadRequest.downloadProgressDelegate = self;
        [[[self class] queue] addOperation:_downloadRequest];
    }
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    _labelForProgress.hidden = YES;
    self.image = [UIImage imageWithData:request.responseData];
    [[XImageViewCache sharedInstance] setImageData:request.responseData forUrl:_url];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    XLog_e(@"download image fail");
}

#pragma mark - ASIProgressDelegate
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    long long total = request.contentLength;
    if (total > 0) {
        CGFloat progress = (CGFloat)(request.totalBytesRead * 1.0 / total);
        [self updateProgress:progress];
    }
}

- (void)updateProgress:(CGFloat)progress
{
    if (_labelForProgress == nil) {
        _labelForProgress = [[UILabel alloc] initWithFrame:self.bounds];
        _labelForProgress.textAlignment = UITextAlignmentCenter;
        _labelForProgress.textColor = [UIColor darkGrayColor];
        _labelForProgress.font = [UIFont systemFontOfSize:12.0f];
        _labelForProgress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_labelForProgress];
    }
    _labelForProgress.hidden = NO;
    _labelForProgress.text = [NSString stringWithFormat:@"%.2f%%", progress * 100];
}

@end
