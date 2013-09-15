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


#define k90DegreesCounterClockwiseAngle  (-M_PI / 2.0f)

@interface SMImagePickerCell : UITableViewCell
@end

@implementation SMImagePickerCell
- (void)layoutSubviews
{
    [super layoutSubviews];
    UIImageView *imageView = self.imageView;
    imageView.frame = CGRectInset(self.bounds, 3.0f, 3.0f);
}
@end


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
    _pickerNvc.navigationBar.translucent = YES;

    groupVc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    groupVc.imagePickerViewController = self;
    groupVc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButtonClick)];
    
    [self.pickerContainer addSubview:_pickerNvc.view];
    
    CGRect frame = _tableViewForPhotos.frame;
    _tableViewForPhotos.transform = CGAffineTransformRotate(CGAffineTransformIdentity, k90DegreesCounterClockwiseAngle);
    _tableViewForPhotos.frame = frame;
}

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)onDoneButtonClick
{
    if ([_delegate respondsToSelector:@selector(imagePickerViewControllerDidSelectAssets:)]) {
        [_delegate imagePickerViewControllerDidSelectAssets:_assets];
    }
    [self dismiss];
}

- (void)selectAsset:(ALAsset *)asset
{
    [_assets addObject:asset];
    [_tableViewForPhotos reloadData];
}

#pragma mark - UITableViewDelegate/UITableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _assets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = _assets[indexPath.row];
    
    NSString *cellId = @"cellid";
    SMImagePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SMImagePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -k90DegreesCounterClockwiseAngle);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_assets removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
}



@end
