//
//  ViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "ViewController.h"
#import "SMWebLoaderOperation.h"

@interface ViewController ()<SMWebLoaderOperationDelegate>
@property (strong, nonatomic) NSArray *urls;
@property (strong, nonatomic) NSMutableArray *opts;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _urls = @[@"http://www.newsmth.net/bbscon.php?bid=383&id=399040", @"http://www.newsmth.net/bbscon.php?bid=383&id=399043", @"http://www.newsmth.net/bbscon.php?bid=383&id=399055"];
    
    _opts = [[NSMutableArray alloc] init];
    [_urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SMWebLoaderOperation *opt = [[SMWebLoaderOperation alloc] init];
        opt.delegate = self;
        [opt loadUrl:obj withParser:@"bbscon"];
        [_opts addObject:opt];
    }];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    XLog_d(@"url[%@], data[%@]", opt.url, opt.result);
}

@end
