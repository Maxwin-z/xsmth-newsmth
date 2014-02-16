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
@property (weak, nonatomic) IBOutlet UIView *viewForNotice;
@property (weak, nonatomic) IBOutlet UILabel *labelForMail;
@property (weak, nonatomic) IBOutlet UILabel *labelForReply;
@property (weak, nonatomic) IBOutlet UILabel *labelForAt;
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
        
        [[NSFileManager defaultManager] removeItemAtPath:localZip error:NULL];
    });
}

- (id)init
{
    self = [super initWithNibName:@"SMAdViewController" bundle:nil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoticeNotification) name:NOTIFICATION_NOTICE object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *adid = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_UPDATE_ADID];

    if ([[self class] isAdExists:adid]) {
        NSString *adfile = [NSString stringWithFormat:@"%@/index.html", [[self class] getAdFilePath:adid]];
        NSString *html = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:adfile] encoding:NSUTF8StringEncoding];
        [self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        self.view.backgroundColor = [SMTheme colorForBackground];
        
        [SMUtils trackEventWithCategory:@"ad" action:@"full" label:adid];
    } else {
        self.webView.hidden = YES;
        self.view.backgroundColor = [UIColor clearColor];
    }
    [self onNoticeNotification];
}

- (void)onNoticeNotification
{
    SMNotice *notice = [SMAccountManager instance].notice;
    if ([SMAccountManager instance].isLogin &&
        (notice.mail > 0 || notice.reply > 0 || notice.at > 0)) {
        self.viewForNotice.hidden = NO;
        self.labelForMail.text = notice.mail > 0 ? @"信" : @"";
        self.labelForReply.text = notice.reply > 0 ? i2s(notice.reply) : @"";
        self.labelForAt.text = notice.at > 0 ? i2s(notice.at) : @"";
    } else {
        self.viewForNotice.hidden = YES;
    }
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    XLog_d(@"load: %@", request.URL.absoluteString);
    return YES;
}

@end
