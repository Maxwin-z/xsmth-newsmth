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

#import "SMBoardSearchResultViewController.h"

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

@property (weak, nonatomic) IBOutlet UITextField *textFieldForDate;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellForHasAttach;
@property (weak, nonatomic) IBOutlet UISwitch *switchForHasAttach;

@property (weak, nonatomic) IBOutlet UISwitch *switchForHasReply;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;


@property (strong, nonatomic) NSArray *cells;
@end

@implementation SMBoardSearchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChangedNotification:) name:NOTIFYCATION_THEME_CHANGED object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"SMBoardSearchViewController" owner:self options:nil];
    
    self.title = @"版面搜索";
    
    _textFieldForBoardName.text = _board.name;
    
    _cells = @[
               @(CellTypeHasAttach),
               @(CellTypeBoardName),
               @(CellTypePostTitle),
               @(CellTypePostTitleEx),
               @(CellTypeAuthor),
//               @(CellTypeDate),
//               @(CellTypeHasReply)
               ];
    
    [_textFields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITextField *textField = obj;
        [SMUtils setTextFieldStyle:textField];
        textField.delegate = self;
    }];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.wantsFullScreenLayout = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(doSearch)];
    
    [self setupTheme];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.contentInset = self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(SM_TOP_INSET, 0, 0, 0);
}

- (void)onThemeChangedNotification:(NSNotification *)n
{
    [self setupTheme];
}

- (void)setupTheme
{
    self.view.backgroundColor = [SMTheme colorForBackground];
    [self.tableView reloadData];
    
    [_textFields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITextField *textField = obj;
        textField.keyboardAppearance = [SMConfig enableDayMode] ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark;
    }];
    
    [_labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *lbl = obj;
        lbl.textColor = [SMTheme colorForPrimary];
    }];
}

- (NSString *)encodeGBKUrl:(NSString *)text
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    NSString *res = [text stringByAddingPercentEscapesUsingEncoding:enc];
    return res == nil ? @"" : res;
}

- (void)doSearch
{
    NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbsbfind.php?q=1&board=%@&title=%@&title2=%@&title3=%@&userid=%@&dt=%@&ag=%@&og=%@",
                     [self encodeGBKUrl:_textFieldForBoardName.text],
                     [self encodeGBKUrl:_textFieldForPostTitle1.text],
                     [self encodeGBKUrl:_textFieldForPostTitle2.text],
                     [self encodeGBKUrl:_textFieldForPostTitleEx.text],
                     [self encodeGBKUrl:_textForAuthor.text],
                     [self encodeGBKUrl:_textFieldForDate.text],
                     _switchForHasAttach.on ? @"on" : @"",
                     _switchForHasReply.on ? @"" : @"on"    // 参数是不含
                     ];
    SMBoardSearchResultViewController *rvc = [SMBoardSearchResultViewController new];
    rvc.url = url;
    rvc.board = _board;
    [self.navigationController pushViewController:rvc animated:YES];
    
    [SMUtils trackEventWithCategory:@"board" action:@"do_search" label:_board.name];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForType:[_cells[indexPath.row] intValue]];
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
        case CellTypeHasAttach:
            cell = _cellForHasAttach;
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cellForType:[_cells[indexPath.row] intValue]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [SMTheme colorForBackground];
    cell.textLabel.textColor = [SMTheme colorForPrimary];
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
    if (textField == _textFieldForDate) {
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
        [self doSearch];
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
