//
//  SMBlockedAuthorsViewController.m
//  newsmth
//
//  Created by bh1cqx on 7/27/19.
//  Copyright © 2019 nju. All rights reserved.
//

#import "SMBlockedAuthorsViewController.h"

@interface SMBlockedAuthorsViewController ()
@property (nonatomic, strong) NSArray *blockedAuthors;
@end

@implementation SMBlockedAuthorsViewController
+ (instancetype)instance
{
    static SMBlockedAuthorsViewController *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [SMBlockedAuthorsViewController new];
    });
    return _instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChangedNotification:) name:NOTIFYCATION_THEME_CHANGED object:nil]; 
    [self setupTheme];

    if (@available(iOS 11.0, *)) {
        NSLog(@"%@", @(self.tableView.contentInsetAdjustmentBehavior));
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        NSLog(@"%@", @(self.tableView.contentInsetAdjustmentBehavior));
    } else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    self.tableView.contentInset = UIEdgeInsetsMake(SM_TOP_INSET, 0, 0, 0);
}

- (void)onThemeChangedNotification:(NSNotification *)n
{
    [self setupTheme];
}

- (void)setupTheme
{
    self.view.backgroundColor = [SMTheme colorForBackground];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"已屏蔽用户"]];
    self.navigationItem.titleView = sc;
    sc.selectedSegmentIndex = 0;

    [sc addTarget:self action:@selector(onTitleViewSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onRightBarButtonClick)];

    self.blockedAuthors = [SMConfig getBlockedAuthors];
    [self.tableView reloadData];
}


- (void)onRightBarButtonClick
{
    self.tableView.editing = !self.tableView.editing;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:self.tableView.editing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit target:self action:@selector(onRightBarButtonClick)];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.blockedAuthors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }

    cell.textLabel.textColor = [SMTheme colorForPrimary];
    cell.detailTextLabel.textColor = [SMTheme colorForSecondary];
    cell.contentView.backgroundColor = [SMTheme colorForBackground];
    cell.backgroundColor = [SMTheme colorForBackground];

    NSString *author = self.blockedAuthors[indexPath.row];
    cell.textLabel.text = author;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *author = self.blockedAuthors[indexPath.row];
    [SMConfig removeBlockedAuthor:author];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *blockedAuthors = [self.blockedAuthors mutableCopy];
        [blockedAuthors removeObjectAtIndex:indexPath.row];
        _blockedAuthors = blockedAuthors;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
