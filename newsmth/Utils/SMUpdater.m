//
//  SMUpdater.m
//  newsmth
//
//  Created by Maxwin on 13-10-19.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMUpdater.h"
#import "ASIHTTPRequest.h"
#import "SSZipArchive.h"
#import "SMAdViewController.h"

#define API_PREFIX @"http://maxwin.me/xsmth/service/"

#define USERDEFAULTS_UPDATE_VERSION   @"updater_version"
#define USERDEFAULTS_UPDATE_PARSER   @"updater_parser"

@interface SMUpdater ()<ASIHTTPRequestDelegate, UIAlertViewDelegate>

@end

@implementation SMUpdater
{
    ASIHTTPRequest *updateReq;
    ASIHTTPRequest *newVersionReq;
    NSInteger currentVersion;
    NSInteger currentParser;
    NSString *currentAdid;
    SMVersion *newVersion;
}

- (void)checkAndUpdate
{
    currentVersion = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_UPDATE_VERSION];
    currentParser = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_UPDATE_PARSER];
    currentAdid = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_UPDATE_ADID];
    
    // load [version].json
    NSString *versionUrl = [NSString stringWithFormat:API_PREFIX @"v%@.json", [SMUtils appVersionString]];
    updateReq = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:versionUrl]];
    updateReq.delegate = self;
    [updateReq startAsynchronous];
    
    
#warning todo
    [self downloadPostPage];
}

- (void)handleNewVersion
{
    if (newVersion.version) {
        NSString *newVersionUrl = [NSString stringWithFormat:API_PREFIX @"latestversion"];
        newVersionReq = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:newVersionUrl]];
        newVersionReq.delegate = self;
        [newVersionReq startAsynchronous];
    }
    if (currentParser != newVersion.parser) {
        // download parses
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadParsers];
        });
    }

    [SMAdViewController downloadAd:newVersion.adid];
    [[NSUserDefaults standardUserDefaults] setObject:newVersion.adid forKey:USERDEFAULTS_UPDATE_ADID];
    [[NSUserDefaults standardUserDefaults] setInteger:newVersion.gadratio forKey:USERDEFAULTS_UPDATE_GADRATIO];
    [[NSUserDefaults standardUserDefaults] setInteger:newVersion.iadratio forKey:USERDEFAULTS_UPDATE_IADRATIO];
}

- (void)downloadParsers
{
    NSString *configUrl = [NSString stringWithFormat:API_PREFIX @"v%@.parse.json", [SMUtils appVersionString]];
    ASIHTTPRequest *req = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:configUrl]];
    [req startSynchronous];
    if (req.error != nil) {
        XLog_e(@"load parse.json[%@] error:[%@]", configUrl, req.error);
        return ;
    }
    
    NSArray *parseItems = [SMUtils string2json:req.responseString];
    [parseItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SMParserItem *item = [[SMParserItem alloc] initWithJSON:obj];
        XLog_d(@"%@", item);
        if (item.path && item.js && item.md5) {
            NSString *path = [NSString stringWithFormat:@"parser/%@", item.js];
            if ([SMUtils fileExistsInDocumentFolder:path]) {
                NSData *data = [SMUtils readDataFromDocumentFolder:path];
                NSString *js = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([js rangeOfString:item.md5].length != 0) {
                    XLog_d(@"%@ exists, skip", item);
                    return ;    // 同类文件已存在，不再下载。
                }
            }
            
            NSString *jsUrl = [NSString stringWithFormat:API_PREFIX @"/parser/%@", item.path];
            ASIHTTPRequest *jsReq = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:jsUrl]];
            jsReq.responseEncoding = NSUTF8StringEncoding;
            [jsReq startSynchronous];
            if (jsReq.error != nil) {
                XLog_e(@"load js[%@], error[%@]", jsUrl, jsReq.error);
                return ;
            }
            // check md5
            NSString *js =  [[NSString alloc] initWithData:jsReq.responseData encoding:NSUTF8StringEncoding];

            if ([js rangeOfString:item.md5].length > 0) {
                // save
                [self saveJS:js toFile:item.js];
            }
        }
    }];
    
    [[NSUserDefaults standardUserDefaults] setInteger:newVersion.parser forKey:USERDEFAULTS_UPDATE_PARSER];
}

- (void)saveJS:(NSString *)js toFile:(NSString *)filename
{
    NSString *path = [NSString stringWithFormat:@"parser/%@", filename];
    [SMUtils writeData:[js dataUsingEncoding:NSUTF8StringEncoding] toDocumentFolder:path];
}

- (void)downloadPostPage
{
    NSString *url = @"http://192.168.3.161/xsmth/a.zip";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (data) {
            XLog_d(@"download post page success");
            [SMUtils writeData:data toDocumentFolder:@"tmp/post.zip"];
        }
        NSString *docPath = [SMUtils documentPath];
        NSString *filepath = [NSString stringWithFormat:@"%@/tmp/post.zip", docPath];
        NSString *destPath = [NSString stringWithFormat:@"%@/post/", docPath];
        [SSZipArchive unzipFileAtPath:filepath toDestination:destPath];
    });
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
    if (request == updateReq) {
        NSDictionary *json = [SMUtils string2json:responseString];
        newVersion = [[SMVersion alloc] initWithJSON:json];
        if (json) {
            [self handleNewVersion];
        }
    }
    if (request == newVersionReq) {
        [[[UIAlertView alloc] initWithTitle:@"新版本" message:responseString delegate:self cancelButtonTitle:@"稍后提醒" otherButtonTitles:@"现在升级", nil] show];
    }
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    XLog_e(@"%@", error);
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/xsmth-shui-mu-she-qu/id669036871?ls=1&mt=8"]];
        [SMUtils trackEventWithCategory:@"app" action:@"do_update" label:nil];
    } else {
        [SMUtils trackEventWithCategory:@"app" action:@"cancel_update" label:nil];
    }
}

@end
