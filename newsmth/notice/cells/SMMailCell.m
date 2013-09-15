//
//  SMMailCell.m
//  newsmth
//
//  Created by Maxwin on 13-9-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMailCell.h"

#define FONT  [UIFont systemFontOfSize:15.0f]
#define HEIGHT_EXPECT_TITLE     50.0f
#define WIDTH_FOR_TITLE 290.0f

@interface SMMailCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonForAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelForDate;
@end

@implementation SMMailCell

+ (CGFloat)cellHeight:(SMMailItem *)item
{
    CGFloat titleHeight = [item.title smSizeWithFont:FONT constrainedToSize:CGSizeMake(WIDTH_FOR_TITLE, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    return titleHeight + HEIGHT_EXPECT_TITLE;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMMailCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        _viewForCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (void)setItem:(SMMailItem *)item
{
    _item = item;
    _labelForTitle.text = item.title;
    _labelForDate.text = [SMUtils formatDate:[NSDate dateWithTimeIntervalSince1970:item.date / 1000]];
    [_buttonForAuthor setTitle:item.author forState:UIControlStateNormal];
    [_buttonForAuthor sizeToFit];
}

@end
