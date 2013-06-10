//
//  SMMainpageCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMainpageCell.h"

static SMMainpageCell *_instance;


@interface SMMainpageCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelForBoardName;
@property (weak, nonatomic) IBOutlet UILabel *labelForAuthor;
@end

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
    CGFloat titleHeight = [post.title sizeWithFont:cell.labelForTitle.font constrainedToSize:CGSizeMake(cell.labelForTitle.frame.size.width, CGFLOAT_MAX) lineBreakMode:cell.labelForTitle.lineBreakMode].height;
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
    _labelForTitle.text = post.title;
    _labelForBoardName.text = post.boardName;
    _labelForAuthor.text = post.author;
}

@end
