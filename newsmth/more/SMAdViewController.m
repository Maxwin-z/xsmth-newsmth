//
//  SMAdViewController.m
//  newsmth
//
//  Created by Maxwin on 14-2-9.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMAdViewController.h"
#import "SSZipArchive.h"

@interface SMAdViewController ()
@end

@implementation SMAdViewController

+ (BOOL)hasAd
{
    return YES;
}

+ (NSString *)getAdFilePath:(NSString *)adid
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (paths.count == 0) {
        XLog_e(@"caches folder not exists!!");
        return nil;
    }
    NSString *cachedir = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/%@/", cachedir, adid];
    return filepath;
}

+ (void)downloadAd:(NSString *)adid
{
    NSString *adDir = [[self class] getAdFilePath:adid];
    NSString *filepath = [NSString stringWithFormat:@"%@/index.html", adDir];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        return ;    // already exists
    }
    
    // download
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *adFileUrl = @"http://192.168.3.160/xsmth/ad.zip";
        NSString *localZip = [NSString stringWithFormat:@"%@.zip", [[self class] getAdFilePath:@""]];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:adFileUrl]];
        
        [data writeToFile:localZip atomically:NO];
        
        [SSZipArchive unzipFileAtPath:localZip toDestination:[[self class] getAdFilePath:adid]];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateTimeLabel];
}

- (void)updateTimeLabel
{
    self.labelForTime.text = [NSString stringWithFormat:@"%@", [NSDate date]];
    [self performSelector:@selector(updateTimeLabel) withObject:nil afterDelay:1];
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
