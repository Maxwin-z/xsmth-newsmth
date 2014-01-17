//
//  SMPageCell.m
//  newsmth
//
//  Created by Maxwin on 13-10-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPageCell.h"

@interface SMPageCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UILabel *labelForPage;
@property (weak, nonatomic) IBOutlet UIButton *buttonForRetry;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SMPageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMPageCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (void)setPageItem:(SMPostPageItem *)pageItem
{
    _pageItem = pageItem;
    _labelForPage.text = [NSString stringWithFormat:@"%@", @(pageItem.pageIndex)];
    
    _activityIndicator.hidden = _buttonForRetry.hidden = YES;
    
    if (_pageItem.op && _pageItem.isLoading) {
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimating];
    }
    if (_pageItem.isLoadFail) {
        _buttonForRetry.hidden = NO;
    }
    
    self.backgroundColor = [SMTheme colorForBackground];
}

- (IBAction)onRetryButtonClick:(id)sender
{
    [_delegate pageCellDoRetry:_pageItem];
    [self setPageItem:_pageItem];
}

@end
