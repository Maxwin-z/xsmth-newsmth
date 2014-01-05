//
//  SMDonateViewController.m
//  newsmth
//
//  Created by Maxwin on 14-1-4.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMDonateViewController.h"
#import <StoreKit/StoreKit.h>

@interface SMDonateViewController ()<SKProductsRequestDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *productIDs;
@property (strong, nonatomic) NSArray *products;
@end

@implementation SMDonateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"捐助";
    [self loadProductIDs];
}

- (void)loadProductIDs
{
    [self showLoading:@"正在加载..."];
    self.productIDs = @[@"one_donate"];
}

- (void)setProductIDs:(NSArray *)productIDs
{
    _productIDs = productIDs;
    if (productIDs.count > 0) {
        [self loadProducts];
    } else {
        [self hideLoading];
        [self toast:@"暂无捐助选项"];
    }
}

- (void)loadProducts
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:self.productIDs]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    [self hideLoading];
    self.products = response.products;
    [self.tableView reloadData];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self hideLoading];
    [self toast:[NSString stringWithFormat:@"获取捐助选项失败，稍后重试"]];
    XLog_d(@"%@", error);
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    SKProduct *product = self.products[indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%@", product.price];
    return cell;
}

@end
