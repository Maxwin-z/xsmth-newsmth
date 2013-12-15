//
//  SMBoardViewTypeSelectorView.m
//  newsmth
//
//  Created by Maxwin on 13-12-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBoardViewTypeSelectorView.h"

@interface SMBoardViewTypeSelectorView ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewForViewType;
@end

@implementation SMBoardViewTypeSelectorView

- (id)init
{
    self = [super init];
    [self commonInit];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    [[NSBundle mainBundle] loadNibNamed:@"SMBoardViewTypeSelectorView" owner:self options:nil];
    CGRect frame = self.frame;
    frame.size = _rootView.bounds.size;
    self.frame = frame;
    
    [self addSubview:_rootView];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text;
    if (indexPath.row == 0) {
        text = @"同主题，回复时间";
    } else if (indexPath.row == 1) {
        text = @"同主题，发表时间";
    } else {
        text = @"普通模式";
    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBoardViewType type;
    if (indexPath.row == 0) {
        type = SMBoardViewTypeTztSortByReply;
    } else if (indexPath.row == 1) {
        type = SMBoardViewTypeTztSortByPost;
    } else {
        type = SMBoardViewTypeNormal;
    }
    _viewType = type;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
