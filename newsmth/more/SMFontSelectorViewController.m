//
//  SMFontSelectorViewController.m
//  newsmth
//
//  Created by Maxwin on 13-10-12.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMFontSelectorViewController.h"

@interface SMFontSelectorViewController ()
@property (strong, nonatomic) NSArray *fonts;
@property (assign, nonatomic) NSInteger fontSize;
@property (strong, nonatomic) NSString *fontName;
@end

@implementation SMFontSelectorViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"选择字体";
    
    _fonts = [UIFont familyNames];
    _fontSize = 15;
    _fontName = _selectedFont.fontName;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(save)];
    
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel
{
    [self dismiss];
}

- (void)save
{
    _fontSelectedBlock(_fontName);
    [self dismiss];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fonts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSString *fontName = _fonts[indexPath.row];
    UIFont *font = [UIFont fontWithName:fontName size:_fontSize];
    cell.textLabel.font = font;
    cell.textLabel.text = [NSString stringWithFormat:@"字体预览：%@", fontName];
    
    if ([font.fontName isEqualToString:_fontName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _fontName = _fonts[indexPath.row];
    [self save];
//    [self.tableView reloadData];
}

@end
