//
//  SMVideoPlayerViewController.m
//  newsmth
//
//  Created by WenDong on 2018/7/4.
//  Copyright © 2018 nju. All rights reserved.
//

#import "SMVideoPlayerViewController.h"
#import <JPVideoPlayer/UIView+WebVideoCache.h>

@interface SMVideoPlayerViewController ()

@end

@implementation SMVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onRightBarButtonItemClick)];
    [self.view jp_playVideoWithURL:self.url];
}

- (void)onRightBarButtonItemClick
{
    [self.view jp_stopPlay];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
