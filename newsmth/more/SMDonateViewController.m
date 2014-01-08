//
//  SMDonateViewController.m
//  newsmth
//
//  Created by Maxwin on 14-1-4.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMDonateViewController.h"
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>
#import "SMMailComposeViewController.h"
#import "SMIPadSplitViewController.h"


@interface SMDonateViewController ()<SKProductsRequestDelegate, UITableViewDataSource, UITableViewDelegate, SKPaymentTransactionObserver, ASIHTTPRequestDelegate, UIAlertViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewForTableViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelForDonateHint;

@property (strong, nonatomic) ASIHTTPRequest *donateConfigRequest;
@property (strong, nonatomic) NSArray *productIDs;
@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) NSArray *otherChannels;

@property (strong, nonatomic) NSString *lastDonateProductID;
@end

@implementation SMDonateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"捐助";
    
    self.tableView.tableHeaderView = self.viewForTableViewHeader;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    [self loadProductIDs];
}

- (void)setupTheme
{
    [super setupTheme];
    [self.tableView reloadData];
    self.labelForDonateHint.textColor = [SMTheme colorForPrimary];
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)loadProductIDs
{
    [self showLoading:@"正在加载"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://maxwin.me/xsmth/service/donate.json"]];
    request.delegate = self;
    self.donateConfigRequest = request;

    [request startAsynchronous];
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

- (void)loadDefaultProducts
{
    self.productIDs = @[
                        @"me.maxwin.xsmth.donate1",
                        @"me.maxwin.xsmth.donate2",
                        @"me.maxwin.xsmth.donate4",
                        @"me.maxwin.xsmth.donate8"
                        ];
}

#pragma mark - ASIHttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
    NSDictionary *config = [SMUtils string2json:responseString];
    if (config && config[@"items"]) {
        self.productIDs = config[@"items"];
        self.otherChannels = config[@"others"];
        [self.tableView reloadData];
    } else {
        [self loadDefaultProducts];
        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideLoading];
    [self loadDefaultProducts];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + (self.otherChannels.count > 0 ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.products.count;
    }
    if (section == 1) {
        return self.otherChannels.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"应用内购买";
    }
    if (section == 1) {
        return @"其他渠道";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIDForProduct = @"product_cellid";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIDForProduct];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIDForProduct];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }

        cell.backgroundColor = [SMTheme colorForBackground];
        cell.textLabel.textColor = [SMTheme colorForPrimary];
        cell.detailTextLabel.textColor = [SMTheme colorForSecondary];
        
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
    
    if (indexPath.section == 1) {
        static NSString *cellIDForOthers = @"cellIDForOthers";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIDForOthers];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDForOthers];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.minimumFontSize = 8;
        }
        
        cell.textLabel.text = self.otherChannels[indexPath.row];
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SKProduct *product = self.products[indexPath.row];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
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
    [self toast:@"支付成功"];
    XLog_d(@"%@", transaction);
    XLog_d(@"购买成功 %@", transaction.payment.productIdentifier);
    
    self.lastDonateProductID = transaction.payment.productIdentifier;
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"感谢你的支持，发个邮件告诉Maxwin吧。" delegate:self cancelButtonTitle:@"深藏功与名" otherButtonTitles:@"发邮件", nil] show];
    
    [SMUtils trackEventWithCategory:@"donate" action:[NSString stringWithFormat:@"success %@", transaction.payment.productIdentifier] label:[SMAccountManager instance].name];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    [self toast:@"支付取消"];
    XLog_d(@"%@", transaction);
    XLog_d(@"购买失败 %@", transaction.payment.productIdentifier);

    [SMUtils trackEventWithCategory:@"donate" action:[NSString stringWithFormat:@"cancel %@", transaction.payment.productIdentifier] label:[SMAccountManager instance].name];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self toast:@"先前已支付"];
    XLog_d(@"%@", transaction);
    XLog_d(@"先前已支付 %@", transaction.payment.productIdentifier);
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"邮件", @"站内信", nil];
        [actionSheet showInView:self.view];
    }
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // mail
        if (![MFMailComposeViewController canSendMail]) {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备未设置邮件帐号。请至“系统设置”-“邮件”设置邮件账户" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return ;
        }
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setToRecipients:@[@"zwd2005@gmail.com"]];
        [mail setSubject:[NSString stringWithFormat:@"[xsmth v%@]Donate", [SMUtils appVersionString]]];
        [mail setMessageBody:[NSString stringWithFormat:@"我捐助了一份 %@", self.lastDonateProductID] isHTML:NO];
        mail.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:mail animated:YES];
    }
    if (buttonIndex == 1) { // 站内信
        [self doSendMail];
    }
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [SMUtils trackEventWithCategory:@"setting" action:@"feedback" label:@"cancel"];
    }
}

- (void)doSendMail
{
    if (![SMAccountManager instance].isLogin) {
        [self performSelectorAfterLogin:@selector(doSendMail)];
        return ;
    }
    SMMailComposeViewController *mailComposeViewController = [[SMMailComposeViewController alloc] init];
    SMMailItem *mail = [[SMMailItem alloc] init];
    mail.author = @"Maxwin";
    mail.title = [NSString stringWithFormat:@"[xsmth v%@]Donate", [SMUtils appVersionString]];
    mail.message = [NSString stringWithFormat:@"我捐助了一份 %@", self.lastDonateProductID];
    mailComposeViewController.mail = mail;
    
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:mailComposeViewController];
    
    if ([SMUtils isPad]) {
        [[SMIPadSplitViewController instance] presentModalViewController:nvc animated:YES];
    } else {
        [self presentModalViewController:nvc animated:YES];
    }
    
    [SMUtils trackEventWithCategory:@"setting" action:@"feedback" label:@"sm_mail"];
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // do nothing
    if (error != nil) {
        [self toast:[NSString stringWithFormat:@"%@", error.userInfo]];
    } else {
        [SMUtils trackEventWithCategory:@"setting" action:@"feedback" label:@"mail"];
    }
    [self dismissModalViewControllerAnimated:YES];
}



@end
