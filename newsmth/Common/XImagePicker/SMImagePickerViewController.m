//
//  SMImagePickerViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-4.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMImagePickerViewController.h"
#import "SMImagePickerGroupViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>

@interface SMImagePickerViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *pickerContainer;

@property (weak, nonatomic) IBOutlet UITableView *tableViewForPhotos;
@property (strong, nonatomic) NSMutableArray *assets;

@property (strong, nonatomic) P2PNavigationController *pickerNvc;

@end

@implementation SMImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _assets = [[NSMutableArray alloc] init];
    
    SMImagePickerGroupViewController *groupVc = [[SMImagePickerGroupViewController alloc] init];
    _pickerNvc = [[P2PNavigationController alloc] initWithRootViewController:groupVc];
    _pickerNvc.view.frame = self.pickerContainer.bounds;
    _pickerNvc.navigationBar.barStyle = UIBarStyleBlack;
    _pickerNvc.navigationBar.translucent = YES;

    groupVc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    
    [self.pickerContainer addSubview:_pickerNvc.view];
}

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate/UITableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _assets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = _assets[indexPath.row];
    
    NSString *cellId = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    return cell;
}

@end
