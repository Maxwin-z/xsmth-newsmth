//
//  SMMailComposeViewController.m
//  newsmth
//
//  Created by Maxwin on 13-10-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMailComposeViewController.h"

@interface SMMailComposeViewController ()<UITextFieldDelegate, SMWebLoaderOperationDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewForContainer;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForReciver;
@property (weak, nonatomic) IBOutlet UITextView *textViewForContent;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForTextViewBg;

@property (strong, nonatomic) SMWebLoaderOperation *sendOp;

@end

@implementation SMMailComposeViewController

- (id)init
{
    self = [super initWithNibName:@"SMMailComposeViewController" bundle:nil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(doSend)];
    
    _textFieldForTitle.background = [SMUtils stretchedImage:_textFieldForTitle.background];
    _textFieldForReciver.background = [SMUtils stretchedImage:_textFieldForReciver.background];
    _imageViewForTextViewBg.image = [SMUtils stretchedImage:_imageViewForTextViewBg.image];

    _textFieldForTitle.text = _mail.title;
    _textFieldForReciver.text = _mail.author;
    
    NSMutableString *quoteString = [[NSMutableString alloc] initWithString:@"\n\n"];
    if (_mail.content.length > 0) {
        [quoteString appendFormat:@"【 在 %@ 的邮件中提到: 】", _mail.author];
        
        NSString *content = _mail.content;
        content = [content stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        content = [content stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        content = [content stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        content = [content stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        content = [content stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
        NSArray *lines = [content componentsSeparatedByString:@"\n"];
        int quoteLine = 4;
        for (int i = 0; i != lines.count && quoteLine > 0; ++i) {
            NSString *line = lines[i];
            if ([line isEqualToString:@"--"]) {   // qmd start
                break;
            }
            if (![line hasPrefix:@":"]) {
                --quoteLine;
                [quoteString appendFormat:@"\n:%@", line];
            }
        }
    }
    _textViewForContent.text = quoteString;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_textFieldForTitle.text.length == 0) {
        [_textFieldForTitle becomeFirstResponder];
    } else if (_textFieldForReciver.text.length == 0) {
        [_textFieldForReciver becomeFirstResponder];
    } else {
        [_textViewForContent setSelectedRange:NSMakeRange(0, 0)];
        [_textViewForContent becomeFirstResponder];
    }
}


- (void)cancel
{
    [self dismiss];
}

- (void)dismiss
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)doSend
{
    NSString *path = _mail.url;
    path = [path stringByReplacingOccurrencesOfString:@"inbox/" withString:@"inbox/send/"];
    NSString *formUrl = [NSString stringWithFormat:@"http://m.newsmth.net/%@", path];
 
    NSString *title = [_textFieldForTitle.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *receiver = [_textFieldForReciver.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *content = [_textViewForContent.text  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (title.length == 0) {
        [self toast:@"请输入主题"];
        [_textFieldForTitle becomeFirstResponder];
        return ;
    }
    
    if (receiver.length == 0) {
        [self toast:@"请输入收件人"];
        [_textFieldForReciver becomeFirstResponder];
        return;
    }
    
    NSString *postBody = [NSString stringWithFormat:@"id=%@&title=%@&content=%@", receiver, title, content];

    SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:formUrl]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
    _sendOp = [[SMWebLoaderOperation alloc] init];
    _sendOp.delegate = self;
    [self showLoading:@"正在发送..."];
    [_sendOp loadRequest:request withParser:@"mailsend"];

}

- (void)onKeyboardWillShow:(NSNotification *)n
{
    NSDictionary* info = [n userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect frame = self.view.bounds;
    frame.origin.y = _viewForContainer.frame.origin.y;
    frame.size.height -= (kbSize.height + SM_TOP_INSET);
    _viewForContainer.frame = frame;
}

- (void)onKeyboardWillHide:(NSNotification *)n
{
    CGRect frame = self.view.bounds;
    frame.origin.y = SM_TOP_INSET;
    frame.size.height -= frame.origin.y;
    _viewForContainer.frame = frame;
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [self hideLoading]; // this->hideLoading();
    SMWriteResult *result = opt.data;
    if (result.success) {
        [self toast:@"发送成功"];
    } else {
        [self toast:result.message];
    }
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:TOAST_DURTAION + 0.1];
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self hideLoading];
    [self toast:error.message];
}

@end
