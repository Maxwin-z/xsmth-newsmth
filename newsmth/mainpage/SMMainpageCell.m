//
//  SMMainpageCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMainpageCell.h"
#import "SMUtils.h"

static SMMainpageCell *_instance;

@implementation SMMainpageCell

+ (SMMainpageCell *)instance
{
    if (_instance == nil) {
        _instance = [[SMMainpageCell alloc] init];
    }
    return _instance;
}

+ (CGFloat)cellHeight:(SMPost *)post
{
    SMMainpageCell *cell = [self instance];
    CGFloat heightExpectTitle = cell.viewForCell.frame.size.height - cell.labelForTitle.frame.size.height;
    CGFloat titleHeight = [post.title smSizeWithFont:[SMConfig listFont] constrainedToSize:CGSizeMake(cell.labelForTitle.frame.size.width, CGFLOAT_MAX) lineBreakMode:cell.labelForTitle.lineBreakMode].height;
    
    return heightExpectTitle + titleHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMMainpageCell" owner:self options:nil];
        self.viewForCell.frame = self.contentView.bounds;
        [self.contentView addSubview:self.viewForCell];
    }
    return self;
}

- (void)setPost:(SMPost *)post
{
    _post = post;
    _labelForTitle.text = post.title;
    _labelForTitle.font = [SMConfig listFont];
    _labelForBoardName.text = post.board.cnName;
    _labelForAuthor.text = post.author;
}

@end
