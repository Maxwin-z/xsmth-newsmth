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
@end

@implementation SMPostGroupAttachCell

+ (CGFloat)cellHeight:(NSString *)url withWidth:(CGFloat)width
{
    UIImage *image = [[XImageViewCache sharedInstance] getImage:url];
    if (image) {
        return image.size.height * (width - 20) / image.size.width + 20.0f;
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
}

@end
