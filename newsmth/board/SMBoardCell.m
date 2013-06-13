//
//  SMBoardCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-13.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBoardCell.h"

static SMBoardCell *_instance;

@interface SMBoardCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelForPostTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonForAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelForReplyTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonForReplyAuthor;
@end

@implementation SMBoardCell

+ (CGFloat)cellHeight:(SMPost *)post
{
    if (_instance == nil) {
        _instance = [[SMBoardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    CGFloat heightExpectTitle = _instance.viewForCell.frame.size.height - _instance.labelForTitle.frame.size.height;
    NSString *title = [NSString stringWithFormat:@"%@(%d)", post.title, post.replyCount];
    CGFloat titleHeight = [title sizeWithFont:_instance.labelForTitle.font constrainedToSize:CGSizeMake(_instance.labelForTitle.frame.size.width, CGFLOAT_MAX) lineBreakMode:_instance.labelForTitle.lineBreakMode].height;
    return titleHeight + heightExpectTitle;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMBoardCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (void)setPost:(SMPost *)post
{
    _post = post;
    NSString *title = [NSString stringWithFormat:@"%@(%d)", _post.title, _post.replyCount];
    _labelForTitle.text = title;
    _labelForPostTime.text = [[NSDate dateWithTimeIntervalSince1970:_post.date / 1000] description];
    _labelForReplyTime.text = [[NSDate dateWithTimeIntervalSince1970:_post.replyDate / 1000] description];
    [_buttonForAuthor setTitle:_post.author forState:UIControlStateNormal];
    [_buttonForReplyAuthor setTitle:_post.replyAuthor forState:UIControlStateNormal];
}

@end
