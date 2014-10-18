//
//  SMImageViewerViewController.m
//  newsmth
//
//  Created by Maxwin on 14/10/18.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMImageViewerViewController.h"

@interface SMImageViewerViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation SMImageViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"查看大图";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(onRightBarButtonClick)];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIEdgeInsets inset = UIEdgeInsetsMake(SM_TOP_INSET, 0, 0, 0);
    scrollView.scrollIndicatorInsets = scrollView.contentInset = inset;
    scrollView.minimumZoomScale = 0.1;
    scrollView.maximumZoomScale = 10;
    [self.view addSubview:scrollView];
    
    scrollView.delegate = self;

    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    
    scrollView.contentSize = self.imageView.frame.size;
    [scrollView addSubview:self.imageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)onRightBarButtonClick
{
    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    [self toast:@"保存成功"];
}

@end
