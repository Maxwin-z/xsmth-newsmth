//
//  SMImagePickerAssetsCell.m
//  newsmth
//
//  Created by Maxwin on 13-7-5.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMImagePickerAssetsCell.h"
#import <AssetsLibrary/ALAsset.h>

@interface SMImagePickerAssetsCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *imageButton;

@end

@implementation SMImagePickerAssetsCell

+ (CGFloat)cellHeight
{
    return 83.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMImagePickerAssetsCell" owner:self options:nil];
        CGRect frame = self.frame;
        frame.size = _viewForCell.bounds.size;
        self.frame = frame;
        
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (void)setAssets:(NSArray *)assets start:(NSInteger)start;
{
    int i = 0;
    for (; i + start != assets.count && i != _imageButton.count; ++i) {
        UIButton *button = _imageButton[i];
        ALAsset *asset = assets[i + start];
        [button setImage:[UIImage imageWithCGImage:asset.thumbnail] forState:UIControlStateNormal];
        button.tag = i + start;
        button.hidden = NO;
    }
    for (; i < _imageButton.count; ++i) {
        UIButton *button = _imageButton[i];
        button.hidden = YES;
    }
}

- (IBAction)onImageButtonClick:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(imagePickerAssetsCellOnClickAtIndex:)]) {
        [_delegate imagePickerAssetsCellOnClickAtIndex:button.tag];
    }
}

@end
