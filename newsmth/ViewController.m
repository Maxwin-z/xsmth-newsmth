//
//  ViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "ViewController.h"
#import "XImageView.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *images;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _images = @[@"http://images-fast.digu365.com/sp/width/619/4045438b672e47b9bd7d8050b1427e7a0003.jpg?f=detail",
               @"http://images-fast.digu365.com/sp/width/619/5be51c942e384f96bbfbd67f80b4ba4c0002.jpg?f=detail",
               @"http://images-fast.digu365.com/sp/width/619/55c310f73c194f33b01f8d8712ebd23f0001.jpg?f=detail",
                @"http://images-fast.digu365.com/sp/width/222/5c1f1444121f453baffb101693b977880001.jpg",
                @"http://images-fast.digu365.com/sp/width/222/b0504380e73047838a5538ac47ac60440001.jpg",
                ];
    [_tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        XImageView *imageView = [[XImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:imageView];
        imageView.tag = 1;
    }
    
    XImageView *imageView = (XImageView *)[cell.contentView viewWithTag:1];
    imageView.url = _images[indexPath.row];
    return cell;
}

@end
