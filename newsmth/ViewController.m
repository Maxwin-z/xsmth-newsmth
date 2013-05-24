//
//  ViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"

@interface ViewController ()<ASIHTTPRequestDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    ASIHTTPRequest *req = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.newsmth.net/bbscon.php?bid=133&id=1936479557"]];
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
    NSLog(@"rsp:%@", request.responseString);
}

@end
