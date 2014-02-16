//
//  SMPostGroupAttachCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostGroupAttachCell.h"
#import "XImageViewCache.h"
#import "XImageView.h"

@interface SMPostGroupAttachCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (strong, nonatomic) IBOutlet UIImageView *bgForPhotoFrame;

@property (strong, nonatomic) IBOutlet UIView *viewForContainer;
@end

@implementation SMPostGroupAttachCell

+ (CGFloat)cellHeight:(NSString *)url withWidth:(CGFloat)width
{
    CGFloat padding = 20.0f;
    UIImage *image = [[XImageViewCache sharedInstance] getImage:url];
    if (image) {
        if (image.size.width > width - padding) {   // need scale
            return image.size.height * (width - padding) / image.size.width + padding;
        } else {
            return image.size.height + padding;
        }
    }
    return 187.5f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMPostGroupAttachCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        
        _bgForPhotoFrame.image = [SMUtils stretchedImage:_bgForPhotoFrame.image];
        
        [self.contentView addSubview:_viewForCell];
        
        // select bg view
        UIView *selectBgView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        selectBgView.backgroundColor = [UIColor colorWithRed:0.199 green:0.592 blue:0.896 alpha:0.330];
        
        self.selectedBackgroundView = selectBgView;
    }
    return self;
}

- (void)setUrl:(NSString *)url
{
    _url = url;
    _imageViewForAttach.url = url;
    self.backgroundColor = [SMTheme colorForBackground];

    // v2.1 fix small image
    CGFloat padding = 20;
    CGRect frame = _viewForContainer.frame;
    frame.size.width = self.contentView.frame.size.width - padding;
    
    UIImage *image = [[XImageViewCache sharedInstance] getImage:url];
    if (image) {
        CGFloat width = self.contentView.frame.size.width;
        if (image.size.width < width - padding) {   // just hide frame. todo
            frame.size.width = image.size.width;
        }
    }
    
    _viewForContainer.frame = frame;
}

@end
