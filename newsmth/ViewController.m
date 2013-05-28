//
//  ViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "ViewController.h"
#import "SMWebParser.h"

@interface ViewController ()<ASIHTTPRequestDelegate>
@property (strong, nonatomic) SMWebParser *parser;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    SMHttpRequest *req = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.newsmth.net/bbscon.php?bid=133&id=1936479557"]];
    req.delegate = self;
    [req startAsynchronous];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *rspData = request.responseData;
    NSString *body = [[NSString alloc] initWithData:rspData encoding:enc];
    NSLog(@"rsp:%@", body);
    
    _parser = [[SMWebParser alloc] init];
//    [self.view addSubview:_parser.webView];
    [_parser parseHtml:body withJS:@"bbscon"];
//parseHtml:body withJS:@"bbscon"];
}

@end
