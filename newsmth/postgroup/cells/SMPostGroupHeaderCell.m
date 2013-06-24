//
//  SMPostGroupHeaderCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostGroupHeaderCell.h"

@interface SMPostGroupHeaderCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UIButton *buttonForAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelForDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonForReply;
@end

@implementation SMPostGroupHeaderCell

+ (CGFloat)cellHeight
{
    return 46.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMPostGroupHeaderCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (void)setPost:(SMPost *)post
{
    _post = post;
    NSString *author = [NSString stringWithFormat:@"%@(%@)", post.author, post.nick];
    [_buttonForAuthor setTitle:author forState:UIControlStateNormal];
    if (post.date > 0) {
        _labelForDate.text = [NSString stringWithFormat:@"%@", [NSDate dateWithTimeIntervalSince1970:post.date / 1000.0f]];
    }
}

- (IBAction)onReplyButtonClick:(id)sender
{
    [_delegate postGroupHeaderCellOnReply:_post];
}

@end
