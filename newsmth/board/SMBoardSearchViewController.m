//
//  SMBoardSearchViewController.m
//  newsmth
//
//  Created by Maxwin on 13-12-17.
//  Copyright (c) 2013年 nju. All rights reserved.
//

typedef enum {
    CellTypeBoardName,
    CellTypePostTitle,
    CellTypePostTitleEx,
    CellTypeAuthor,
    CellTypeDate,
    CellTypeHasAttach,
    CellTypeHasReply
}CellType;

#import "SMBoardSearchViewController.h"

@interface SMBoardSearchViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableViewCell *cellForBoardName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForBoardName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForPostTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForPostTitle1;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForPostTitle2;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForPostTitleEx;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForPostTitleEx;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForAuthor;
@property (weak, nonatomic) IBOutlet UITextField *textForAuthor;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForDate;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForDate;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForHasAttach;
@property (weak, nonatomic) IBOutlet UISwitch *switchForHasAttach;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForHasReply;
@property (weak, nonatomic) IBOutlet UISwitch *switchForHasReply;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;


@property (strong, nonatomic) NSArray *cells;
@end

@implementation SMBoardSearchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cells = @[
               @(CellTypeBoardName),
               @(CellTypePostTitle),
               @(CellTypePostTitleEx),
               @(CellTypeAuthor),
               @(CellTypeDate),
               @(CellTypeHasAttach),
               @(CellTypeHasReply)
               ];
    
    [_textFields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITextField *textField = obj;
        textField.background = [SMUtils stretchedImage:textField.background];
        
        textField.delegate = self;
    }];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForType:[_cells[indexPath.row] integerValue]];
    return cell.frame.size.height;
}

- (UITableViewCell *)cellForType:(CellType)type
{
    UITableViewCell *cell;
    switch (type) {
        case CellTypeBoardName:
            cell = _cellForBoardName;
            break;
        case CellTypePostTitle:
            cell = _cellForPostTitle;
            break;
        case CellTypePostTitleEx:
            cell = _cellForPostTitleEx;
            break;
        case CellTypeAuthor:
            cell = _cellForAuthor;
            break;
        case CellTypeDate:
            cell = _cellForDate;
            break;
        case CellTypeHasAttach:
            cell = _cellForHasAttach;
            break;
        case CellTypeHasReply:
            cell = _cellForHasReply;
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForType:[_cells[indexPath.row] integerValue]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _textFieldForBoardName) {
        [_textFieldForPostTitle1 becomeFirstResponder];
    }
    if (textField == _textFieldForPostTitle1) {
        [_textFieldForPostTitle2 becomeFirstResponder];
    }
    if (textField == _textFieldForPostTitle2) {
        [_textFieldForPostTitleEx becomeFirstResponder];
    }
    if (textField == _textFieldForPostTitleEx) {
        [_textForAuthor becomeFirstResponder];
    }
    if (textField == _textForAuthor) {
        [_textFieldForDate becomeFirstResponder];
    }
    if (textField == _textFieldForDate) {
        // do search
    }
    
    return YES;
}

@end
