//
//  SMPostGroupHeaderCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostGroupHeaderCell.h"
#import "UIButton+Custom.h"

@interface SMPostGroupHeaderCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UIButton *buttonForAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelForIndex;
@property (weak, nonatomic) IBOutlet UILabel *labelForDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonForReply;
@end

@implementation SMPostGroupHeaderCell

+ (CGFloat)cellHeight
{
    CGFloat fontHeight = [SMConfig postFont].lineHeight;
    return fontHeight * 2 + 10.0f;
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

- (void)setItem:(SMPostItem *)item
{
    _item = item;
    SMPost *post = item.post;
    
    NSString *author = post.author;
    if (post.nick.length > 0) {
        author = [NSString stringWithFormat:@"%@(%@)", post.author, post.nick];
    }
    
    [_buttonForAuthor setTitle:author forState:UIControlStateNormal];
    
//    _labelForIndex.text = [NSString stringWithFormat:@"#%d", item.index + 1];
    
    NSString *dateStr = @"";
    if (post.date > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:post.date / 1000l]];
    }
    _labelForDate.text = [NSString stringWithFormat:@"#%d  %@", item.index + 1, dateStr];

    UIFont *font = [SMConfig postFont];
    _buttonForAuthor.titleLabel.font = font;
    _labelForDate.font = font;
    
    // use
    CGFloat fontHeight = font.lineHeight;
    CGRect frame = _buttonForAuthor.frame;
    frame.size.height = fontHeight;
    _buttonForAuthor.frame = frame;
    
    frame = _labelForDate.frame;
    frame.origin.y = CGRectGetMaxY(_buttonForAuthor.frame);
    frame.size.height = fontHeight;
    _labelForDate.frame = frame;
    
//    [_labelForIndex sizeToFit];
//    CGRect frame = _labelForDate.frame;
//    frame.origin.x = _labelForIndex.frame.origin.x + _labelForIndex.frame.size.width + 10.0f;
//    _labelForDate.frame = frame;
}

- (IBAction)onReplyButtonClick:(id)sender
{
    [_delegate postGroupHeaderCellOnReply:_item.post];
}

- (IBAction)onUsernameClick:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(postGroupHeaderCellOnUsernameClick:)]) {
        [_delegate postGroupHeaderCellOnUsernameClick:_item.post.author];
    }
}

@end
