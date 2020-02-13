//
//  SMUpdater.m
//  newsmth
//
//  Created by Maxwin on 13-10-19.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMUpdater.h"
//#import "ASIHTTPRequest.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "SSZipArchive.h"
#import "SMAdViewController.h"
#import <CoreText/CoreText.h>

#define API_PREFIX @"https://maxwin-z.github.io/xsmth/service/"
// #define API_PREFIX @"http://10.0.0.3:8080/"

#define USERDEFAULTS_UPDATE_VERSION   @"updater_version"
#define USERDEFAULTS_UPDATE_PARSER   @"updater_parser"
#define USERDEFAULTS_UPDATE_TEMPLATE @"updater_template"

@interface SMUpdater ()<ASIHTTPRequestDelegate, UIAlertViewDelegate>

@end

@implementation SMUpdater
{
    ASIHTTPRequest *updateReq;
    ASIHTTPRequest *newVersionReq;
    NSInteger currentVersion;
    NSInteger currentParser;
    NSString *currentAdid;
    NSString *currentTemplate;
    SMVersion *newVersion;
}

- (void)checkAndUpdate
{
    currentVersion = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_UPDATE_VERSION];
    currentParser = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_UPDATE_PARSER];
    currentAdid = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_UPDATE_ADID];
    currentTemplate = [[NSUserDefaults standardUserDefaults] stringForKey:USERDEFAULTS_UPDATE_TEMPLATE];
    
    // load [version].json
    NSString *versionUrl = [NSString stringWithFormat:API_PREFIX @"v%@.json", [SMUtils appVersionString]];
    updateReq = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:versionUrl]];
    updateReq.delegate = self;
    [updateReq startAsynchronous];
    
    [self setupPostsTemplate];
//    [self downloadPostPage];
    [self checkTemplate];
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
    [[NSUserDefaults standardUserDefaults] setInteger:newVersion.adratio forKey:USERDEFAULTS_UPDATE_ADRATIO];
    [[NSUserDefaults standardUserDefaults] setInteger:newVersion.adPosition forKey:USERDEFAULTS_UPDATE_ADPOSTION];
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

- (void)setupPostsTemplate
{
//    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"template_posts" ofType:@"zip"];
    NSString *docPath = [SMUtils documentPath];
    
    NSString *filepath = [NSString stringWithFormat:@"template.%@.zip", currentTemplate];
   
    NSString *md5 = [SMUtils md5:[SMUtils readDataFromDocumentFolder:filepath]];
    if ([SMUtils fileExistsInDocumentFolder:filepath] && [currentTemplate isEqualToString:md5]) {
        filepath = [NSString stringWithFormat:@"%@/%@", docPath, filepath];
    } else {
        filepath = [[NSBundle mainBundle] pathForResource:@"template_posts" ofType:@"zip"];
    }
    
    NSString *destPath = [NSString stringWithFormat:@"%@/post/", docPath];
    [SSZipArchive unzipFileAtPath:filepath toDestination:destPath];
    XLog_d(@"unzip posts template %@", filepath);
    
    // copy fonts to post folder
//    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *resourceDirectory = [[NSBundle mainBundle] resourcePath];
    
    NSArray *files = [[NSFileManager defaultManager]
                      contentsOfDirectoryAtPath:resourceDirectory
                      error:NULL];
    for (NSString *file in files) {
        if ([file hasSuffix:@".TTF"]) {
            NSString *from = [NSString stringWithFormat:@"%@/%@", resourceDirectory, file];
//            NSString *to = [NSString stringWithFormat:@"%@/%@", destPath, file];
//            if (![fm fileExistsAtPath:to]) {
//                [fm copyItemAtPath:from toPath:to error:NULL];
//            }
            NSData *data = [NSData dataWithContentsOfFile:from];
            CFErrorRef error;
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
            CGFontRef font = CGFontCreateWithDataProvider(provider);
            if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
                CFStringRef errorDescription = CFErrorCopyDescription(error);
                NSLog(@"Failed to load font: %@", errorDescription);
                CFRelease(errorDescription);
            }
           
            CFRelease(font);
            CFRelease(provider);
        }
    }
}

- (void)checkTemplate
{
    NSString *url = API_PREFIX @"template.json";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        NSString *rsp = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            return ;
        }
        NSDictionary *templateConfig = [SMUtils string2json:rsp];
        NSString *version = [SMUtils appVersionString];
        __block NSString *templateMD5 = nil;
        [templateConfig enumerateKeysAndObjectsUsingBlock:^(NSString *md5, NSString *versions, BOOL * _Nonnull stop) {
            if ([versions rangeOfString:[NSString stringWithFormat:@"|%@|", version]].location != NSNotFound) {
                templateMD5 = md5;
                *stop = YES;
            }
        }];
        [[NSUserDefaults standardUserDefaults] setObject:templateMD5 forKey:USERDEFAULTS_UPDATE_TEMPLATE];

        if (templateMD5 == nil || [templateMD5 isEqualToString:currentTemplate]) {
            return;
        }
        NSString *downloadUrl = [NSString stringWithFormat:API_PREFIX @"template.%@.zip", templateMD5];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadUrl]];
        if (!data) {
            XLog_e(@"download %@ fail", downloadUrl);
            return ;
        }
        NSString *dataMD5 = [SMUtils md5:data];
        if (![templateMD5 isEqualToString:dataMD5]) {
            XLog_e(@"file %@ md5 not match: %@ != %@", downloadUrl, templateMD5, dataMD5);
            return ;
        }
        [SMUtils writeData:data toDocumentFolder:[NSString stringWithFormat:@"template.%@.zip", templateMD5]];
        currentTemplate = templateMD5;
        [self setupPostsTemplate];
        XLog_d(@"download template %@ success", templateMD5);
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/xsmth-for-shui-mu/id1090365014?ls=1&mt=8"]];
        [SMUtils trackEventWithCategory:@"app" action:@"do_update" label:nil];
    } else {
        [SMUtils trackEventWithCategory:@"app" action:@"cancel_update" label:nil];
    }
}

@end
