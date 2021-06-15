//
//  SMImageUploadListViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMImageUploadListViewController.h"
#import "SMImagePickerViewController.h"

typedef NS_ENUM(NSInteger, SectionType) {
    SectionTypeUploading,
    SectionTypeUploaded
};

@interface SMImageUploadListViewController ()<UITableViewDataSource, UITableViewDelegate, SMImageUploaderDelegate, SMWebLoaderOperationDelegate, SMImagePickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sectionTypes;

@property (strong, nonatomic) SMWebLoaderOperation *deleteOp;

@property (strong, nonatomic) SMImagePickerViewController *imagePicker;
@end

@implementation SMImageUploadListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"上传列表";
    
    _uploader.delegateForList = self;
    self.tableView.editing = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onRightBarButtonClick)];
}

- (void)setLastUploads:(NSArray *)lastUploads
{
    _lastUploads = [lastUploads mutableCopy];
    [self.tableView reloadData];
}

- (void)onRightBarButtonClick
{
    _imagePicker = [[SMImagePickerViewController alloc] init];
    _imagePicker.delegate = self;
    [self presentModalViewController:_imagePicker animated:YES];

}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _sectionTypes = [[NSMutableArray alloc] init];
    if (_uploader.uploadQueue.count > 0) {
        [_sectionTypes addObject:@(SectionTypeUploading)];
    }
    if (_lastUploads.count > 0) {
        [_sectionTypes addObject:@(SectionTypeUploaded)];
    }
    return _sectionTypes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SectionType secType = [_sectionTypes[section] intValue];
    if (secType == SectionTypeUploading) {
        return @"上传中";
    } else {
        return @"上次上传的附件";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionType secType = [_sectionTypes[section] intValue];
    if (secType == SectionTypeUploading) {
        return _uploader.uploadQueue.count;
    } else {
        return _lastUploads.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
    SectionType secType = [_sectionTypes[indexPath.section] intValue];
    if (secType == SectionTypeUploading) {
        SMUploadData *data = _uploader.uploadQueue[indexPath.row];
        NSString *text = [NSString stringWithFormat:@"%@ (%2.0f%%)", [data.file lastPathComponent], data.progress * 100];
        cell.imageView.image = data.thumbImage;
        cell.textLabel.text = text;
    } else {
        SMUploadItem *item = _lastUploads[indexPath.row];
        cell.textLabel.text = item.name;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SectionType secType = [_sectionTypes[indexPath.section] intValue];
        if (secType == SectionTypeUploading) {
            [_uploader removeAtIndex:indexPath.row];
            [self.tableView reloadData];
        } else { // delete uploaded
            SMUploadItem *item = _lastUploads[indexPath.row];

            NSString *deleteUrl = [NSString stringWithFormat:URL_PROTOCOL @"//www.mysmth.net/bbsupload.php?act=delete&attachname=%@", item.key];
            _deleteOp = [[SMWebLoaderOperation alloc] init];
            _deleteOp.delegate = self;
            [_deleteOp loadUrl:deleteUrl withParser:@"upload"];
            
            [_lastUploads removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - SMImageUploaderDelegate
- (void)imageUploaderOnProgressChange:(SMImageUploader *)uploader withProgress:(CGFloat)progress
{
    [self.tableView reloadData];
}

- (void)imageUploaderOnFinish:(SMImageUploader *)uploader
{
    [self.tableView reloadData];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [self.tableView reloadData];
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self toast:error.message];
}

#pragma mark - SMImagePickerViewDelegate
- (void)imagePickerViewControllerDidSelectAssets:(NSArray *)assets
{
    if (assets.count > 0) {
        [_uploader addAssets:assets];
    }
}

@end
