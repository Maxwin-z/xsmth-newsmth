//
//  SMPostFailCell.m
//  newsmth
//
//  Created by Maxwin on 13-7-2.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostFailCell.h"

@interface SMPostFailCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@end

@implementation SMPostFailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMPostFailCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        
        [self.contentView addSubview:_viewForCell];
        self.backgroundColor = [SMTheme colorForBackground];
    }
    return self;
}

- (IBAction)onRetryButtonClick:(id)sender
{
    if ([_delegate respondsToSelector:@selector(postFailCellOnRetry:)]) {
        [_delegate postFailCellOnRetry:self];
    }
}

@end
