//
//  SMDonateViewController.m
//  newsmth
//
//  Created by Maxwin on 14-1-4.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMDonateViewController.h"
#import <StoreKit/StoreKit.h>

@interface SMDonateViewController ()<SKProductsRequestDelegate, UITableViewDataSource, UITableViewDelegate, SKPaymentTransactionObserver>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *productIDs;
@property (strong, nonatomic) NSArray *products;
@end

@implementation SMDonateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"捐助";
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    [self loadProductIDs];
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
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
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = formattedPrice;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *product = self.products[indexPath.row];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    payment.applicationUsername = @"tester";
    [[SKPaymentQueue defaultQueue] addPayment:payment];
 
        XLog_d(@"%@", @([SKPaymentQueue canMakePayments]));
    
    XLog_d(@"%@", payment.applicationUsername);
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
        @try {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } @catch (NSException *exception) {
            XLog_d(@"%@", exception);
        } @finally {
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self toast:@"购买成功"];
    XLog_d(@"%@", transaction);
    XLog_d(@"购买成功 %@", transaction.payment.productIdentifier);
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [self toast:@"购买失败"];
    XLog_d(@"%@", transaction);
    XLog_d(@"购买失败 %@", transaction.payment.productIdentifier);
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self toast:@"先前已支付"];
    XLog_d(@"%@", transaction);
    XLog_d(@"先前已支付 %@", transaction.payment.productIdentifier);
}

@end
