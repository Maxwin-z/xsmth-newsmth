//
//  SMImagePickerAssetsViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-4.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMImagePickerAssetsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SMImagePickerAssetsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *assets;
@end

@implementation SMImagePickerAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _assets = [[NSMutableArray alloc] init];
    [_group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result != nil) {
            [_assets addObject:result];
        }
    }];
    
    [_tableView reloadData];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _assets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    ALAsset *asset = _assets[indexPath.row];
    
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    return cell;
}
@end
