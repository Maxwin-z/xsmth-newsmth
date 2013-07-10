//
//  SMImageUploadListViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMImageUploadListViewController.h"

typedef NS_ENUM(NSInteger, SectionType) {
    SectionTypeUploading,
    SectionTypeUploaded
};

@interface SMImageUploadListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sectionTypes;
@end

@implementation SMImageUploadListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _sectionTypes = [[NSMutableArray alloc] init];
    if (_uploader.uploadDatas.count > 0) {
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
        return _uploader.uploadDatas.count;
    } else {
        return _lastUploads.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SectionType secType = [_sectionTypes[indexPath.section] intValue];
    if (secType == SectionTypeUploading) {
        SMUploadData *data = _uploader.uploadDatas[indexPath.row];
        NSString *text = [NSString stringWithFormat:@"%@ (%2.0f%%)", [data.file lastPathComponent], data.progress * 100];
        cell.textLabel.text = text;
    } else {
        SMUploadItem *item = _lastUploads[indexPath.row];
        cell.textLabel.text = item.name;
    }
    
    return cell;
}

@end
