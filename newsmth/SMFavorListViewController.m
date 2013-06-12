//
//  SMFavorListViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMFavorListViewController.h"

static SMFavorListViewController *_instance;

@interface SMFavorListViewController ()

@end

@implementation SMFavorListViewController

+ (SMFavorListViewController *)instance
{
    if (_instance == nil) {
        _instance = [[SMFavorListViewController alloc] init];
    }
    return _instance;
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
