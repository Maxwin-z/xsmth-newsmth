//
//  SMPostGroupContentCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostGroupContentCell.h"

static SMPostGroupContentCell *_instance;

@interface SMPostGroupContentCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (strong, nonatomic) IBOutlet UILabel *labelForContent;
@end

@implementation SMPostGroupContentCell

+ (SMPostGroupContentCell *)instance
{
    if (_instance == nil) {
        _instance = [[SMPostGroupContentCell alloc] init];
    }
    return _instance;
}

+ (CGFloat)cellHeight:(SMPost *)post
{
    SMPostGroupContentCell *cell = [self instance];
    CGFloat heightExceptContent = cell.viewForCell.frame.size.height - cell.labelForContent.frame.size.height;
    CGFloat contentHeight = [post.content sizeWithFont:cell.labelForContent.font constrainedToSize:CGSizeMake(cell.labelForContent.frame.size.width, CGFLOAT_MAX) lineBreakMode:cell.labelForContent.lineBreakMode].height;
    return heightExceptContent + contentHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMPostGroupContentCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (void)setPost:(SMPost *)post
{
    for (int i = _viewForCell.subviews.count - 1; i >= 0; --i) {
        [_viewForCell.subviews[i] removeFromSuperview];
    }

    CGFloat x = _labelForContent.frame.origin.x;
    CGFloat y = 0;
    CGFloat width = _labelForContent.bounds.size.width;
    
    NSArray *lines = [post.content componentsSeparatedByString:@"\n"];
    for (int i = 0; i != lines.count; ++i) {
        NSString *line = lines[i];
        if (line.length == 0) {  // space line
            line = @" ";
        }
        UILabel *label = [[UILabel alloc] init];
        label.font = _labelForContent.font;
        label.lineBreakMode = _labelForContent.lineBreakMode;
        label.numberOfLines = 0;
        label.text = line;
        
        if ([line hasPrefix:@":"]) {
            label.textColor = [UIColor colorWithRed:0.141 green:0.494 blue:0.635 alpha:1.000];
        } else {
            label.textColor = _labelForContent.textColor;
        }
        
        CGFloat height = [line sizeWithFont:label.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:label.lineBreakMode].height;
        CGRect frame = CGRectMake(x, y, width, height);
        label.frame = frame;
        [_viewForCell addSubview:label];
        
        y += height;
    }
}

@end
