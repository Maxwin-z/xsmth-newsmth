//
//  SMMailCell.m
//  newsmth
//
//  Created by Maxwin on 13-9-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMailCell.h"

#define HEIGHT_EXPECT_TITLE     50.0f
#define WIDTH_FOR_TITLE 290.0f

@interface SMMailCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonForAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelForDate;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForReadStatus;
@end

@implementation SMMailCell

+ (CGFloat)cellHeight:(SMMailItem *)item
{
    CGFloat titleHeight = [item.title smSizeWithFont:[SMConfig listFont] constrainedToSize:CGSizeMake(WIDTH_FOR_TITLE, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height;
    return titleHeight + HEIGHT_EXPECT_TITLE + 1;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.selectedBackgroundView = selectedBackgroundView;
        
        [[NSBundle mainBundle] loadNibNamed:@"SMMailCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        _viewForCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (IBAction)onUserClick:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(mailCellOnUserClick:)]) {
        [_delegate mailCellOnUserClick:button.titleLabel.text];
    }
}

- (void)setItem:(SMMailItem *)item
{
    _item = item;
    _labelForTitle.text = item.title;
    _labelForTitle.font = [SMConfig listFont];
    _labelForDate.text = [SMUtils formatDate:[NSDate dateWithTimeIntervalSince1970:item.date / 1000]];
    [_buttonForAuthor setTitle:item.author forState:UIControlStateNormal];
    [_buttonForAuthor sizeToFit];
    _imageViewForReadStatus.hidden = !_item.unread;
    
    self.backgroundColor = [SMTheme colorForBackground];
    _labelForTitle.textColor = [SMTheme colorForPrimary];
    _labelForDate.textColor = [SMTheme colorForSecondary];
    [_buttonForAuthor setTitleColor:[SMTheme colorForTintColor] forState:UIControlStateNormal];
    self.selectedBackgroundView.backgroundColor = [SMTheme colorForHighlightBackground];
}

@end
