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
@end

@implementation SMPostGroupAttachCell

+ (CGFloat)cellHeight:(NSString *)url
{
    UIImage *image = [[XImageViewCache sharedInstance] getImage:url];
    if (image) {
        return image.size.height * 300.0f / image.size.width + 20.0f;
    }
    return 187.5f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMPostGroupAttachCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (void)setUrl:(NSString *)url
{
    _url = url;
    _imageViewForAttach.url = url;
}

@end
