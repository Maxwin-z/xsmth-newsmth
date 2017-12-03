//
//  SMZanShangViewController.m
//  newsmth
//
//  Created by Maxwin on 03/12/2017.
//  Copyright © 2017 nju. All rights reserved.
//

#import "SMZanShangViewController.h"
#import "SMZanShangUtil.h"

@interface SMZanShangViewController ()

@end

@implementation SMZanShangViewController


- (void)setupTheme
{
    [super setupTheme];
    self.view.backgroundColor = [SMTheme colorForBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"打赏";
    
    UIImage *image = [UIImage imageWithData:[SMZanShangUtil sharedInstance].imageData];
    CGSize size = image.size;
    size.height = size.height * self.view.width / size.width;
    size.width = self.view.width;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.size = size;
    imageView.center = self.view.center;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
}

- (void)done
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
