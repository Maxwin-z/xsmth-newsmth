//
//  SMUserViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-30.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMUserViewController.h"
#import "SMLoginViewController.h"

@interface SMUserViewController ()

@end

@implementation SMUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)onLoginButtonClick:(id)sender
{
    SMLoginViewController *loginVc = [[SMLoginViewController alloc] init];
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:loginVc];
    [self presentModalViewController:nvc animated:YES];
}

@end
