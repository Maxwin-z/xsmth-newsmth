//
//  SMAdViewController.m
//  newsmth
//
//  Created by Maxwin on 14-2-9.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMAdViewController.h"
#import "SSZipArchive.h"

@interface SMAdViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation SMAdViewController

+ (BOOL)hasAd
{
    NSString *adid = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_UPDATE_ADID];
    return [[self class] isAdExists:adid];
}

+ (BOOL)isAdExists:(NSString *)adid
{
    if (adid == nil) return NO;
    NSString *adDir = [[self class] getAdFilePath:adid];
    NSString *filepath = [NSString stringWithFormat:@"%@/index.html", adDir];
    return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
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
    if ([[self class] isAdExists:adid]) {
        return ;
    }
    // download
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *adFileUrl = [NSString stringWithFormat:@"http://maxwin.me/xsmth/service/%@.zip", adid];
        NSString *localZip = [NSString stringWithFormat:@"%@/tmpad.zip", [[self class] getAdFilePath:@""]];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:adFileUrl]];
        
        [data writeToFile:localZip atomically:NO];
        
        [SSZipArchive unzipFileAtPath:localZip toDestination:[[self class] getAdFilePath:adid]];
        
        [[NSUserDefaults standardUserDefaults] setObject:adid forKey:USERDEFAULTS_UPDATE_ADID];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateTimeLabel];
    
    NSString *adid = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_UPDATE_ADID];

    if ([[self class] isAdExists:adid]) {
        NSString *adfile = [NSString stringWithFormat:@"%@/index.html", [[self class] getAdFilePath:adid]];
        NSString *html = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:adfile] encoding:NSUTF8StringEncoding];
        [self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
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

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    XLog_d(@"load: %@", request.URL.absoluteString);
    return YES;
}

@end
