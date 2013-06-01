//
//  ViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "ViewController.h"
#import "XImageView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet XImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageView.url = @"http://att.newsmth.net/att.php?s.978.816101.2792.jpg";
    _imageView.url = @"http://att.newsmth.net/att.php?p.1349.257184.285.jpg";
}


@end
