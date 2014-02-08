//
//  SMImagePickerAssetsViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-4.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMImagePickerAssetsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SMImagePickerAssetsCell.h"

#define CELL_COLS    4

@interface SMImagePickerAssetsViewController ()<UITableViewDataSource, UITableViewDelegate, SMImagePickerAssetsCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *assets;
@end

@implementation SMImagePickerAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [_group valueForProperty:ALAssetsGroupPropertyName];
    
    _assets = [[NSMutableArray alloc] init];
    [_group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result != nil) {
            [_assets addObject:result];
        }
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:_imagePickerViewController action:@selector(onDoneButtonClick)];
    if (_assets.count == 0) {
        self.tableView = nil; 
    }
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger totalRow = [self tableView:_tableView numberOfRowsInSection:0] - 1;
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:totalRow inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _assets == nil ? 0 : ceilf((_assets.count - 1) / CELL_COLS) + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SMImagePickerAssetsCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cellid";
    SMImagePickerAssetsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SMImagePickerAssetsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell setAssets:_assets start:indexPath.row * 4];
    return cell;
}

#pragma mark - SMImagePickerAssetsCellDelegate
- (void)imagePickerAssetsCellOnClickAtIndex:(NSInteger)index
{
    [_imagePickerViewController selectAsset:_assets[index]];
}

@end
