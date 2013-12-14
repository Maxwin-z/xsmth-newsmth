//
//  SMUpdater.m
//  newsmth
//
//  Created by Maxwin on 13-10-19.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMUpdater.h"
#import "ASIHTTPRequest.h"

#define API_PREFIX @"http://maxwin.me/xsmth/service/"

#define USERDEFAULTS_UPDATE_VERSION   @"updater_version"
#define USERDEFAULTS_UPDATE_PARSER   @"updater_parser"

@interface SMUpdater ()<ASIHTTPRequestDelegate>

@end

@implementation SMUpdater
{
    ASIHTTPRequest *updateReq;
    NSInteger currentVersion;
    NSInteger currentParser;
    SMVersion *newVersion;
}

- (void)checkAndUpdate
{
    currentVersion = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_UPDATE_VERSION];
    currentParser = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_UPDATE_PARSER];
    
    // load [version].json
    NSString *versionUrl = [NSString stringWithFormat:API_PREFIX @"v%@.json", [SMUtils appVersionString]];
    updateReq = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:versionUrl]];
    updateReq.delegate = self;
    [updateReq startAsynchronous];
}

- (void)handleNewVersion
{
    if (currentVersion != newVersion.version) {
        // TODO show new app version update info
    }
    if (currentParser != newVersion.parser) {
        // download parses
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadParsers];
        });
    }
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
            [jsReq startSynchronous];
            if (jsReq.error != nil) {
                XLog_e(@"load js[%@], error[%@]", jsUrl, jsReq.error);
                return ;
            }
            // check md5
            NSString *js = jsReq.responseString;
            if ([js rangeOfString:item.md5].length > 0) {
                // save
                [self saveJS:js toFile:item.js];
            }
        }
    }];
}

- (void)saveJS:(NSString *)js toFile:(NSString *)filename
{
    NSString *path = [NSString stringWithFormat:@"parser/%@", filename];
    [SMUtils writeData:[js dataUsingEncoding:NSUTF8StringEncoding] toDocumentFolder:path];
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *json = [SMUtils string2json:request.responseString];
    newVersion = [[SMVersion alloc] initWithJSON:json];
    if (newVersion.version != 0 || newVersion.parser != 0) {
        [self handleNewVersion];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    XLog_e(@"%@", error);
}

@end
