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
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"站内信";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(doSend)];
    
    _imageViewForTextViewBg.image = [SMUtils stretchedImage:_imageViewForTextViewBg.image];
    
    [@[_textFieldForTitle, _textFieldForReciver] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITextField *textField = obj;
        
        textField.background = [SMUtils stretchedImage:textField.background];
        
        UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
        textField.leftView = lv;
        textField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView *rv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
        textField.rightView = rv;
        textField.rightViewMode = UITextFieldViewModeAlways;
    }];


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
                [quoteString appendFormat:@"\n: %@", line];
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

-(void)setupTheme
{
    [super setupTheme];
    _textFieldForTitle.keyboardAppearance = _textViewForContent.keyboardAppearance = _textFieldForReciver.keyboardAppearance = [SMConfig enableDayMode] ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark;

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
    NSString *formUrl = @"http://m.newsmth.net/mail/send";
    if (_mail.url.length > 0) {
        NSString *path = _mail.url;
        path = [path stringByReplacingOccurrencesOfString:@"inbox/" withString:@"inbox/send/"];
        formUrl = [NSString stringWithFormat:@"http://m.newsmth.net/%@", path];
    }
 
    NSString *title = [SMUtils encodeurl:_textFieldForTitle.text];
    NSString *receiver = [SMUtils encodeurl:_textFieldForReciver.text ];
    NSString *content = [SMUtils encodeurl:_textViewForContent.text];
    
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
    
    NSString *postBody = [NSString stringWithFormat:@"id=%@&title=%@&content=%@&backup=1", receiver, title, content];

    SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:formUrl]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
    _sendOp = [[SMWebLoaderOperation alloc] init];
    _sendOp.delegate = self;
    [self showLoading:@"正在发送..."];
    [_sendOp loadRequest:request withParser:@"mailsend,util_notice"];

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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _textFieldForReciver) {
        [self resizeReciverToWidth:200];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _textFieldForReciver) {
        [self resizeReciverToWidth:65];
    }
    return YES;
}

- (void)resizeReciverToWidth:(CGFloat)width
{
    CGRect receiverFrame = _textFieldForReciver.frame;
    CGRect titleFrame = _textFieldForTitle.frame;
    
    CGFloat delta = width - receiverFrame.size.width;
    titleFrame.size.width -= delta;
    receiverFrame.size.width = width;
    receiverFrame.origin.x -= delta;

    [UIView animateWithDuration:0.2 animations:^{
        _textFieldForTitle.frame = titleFrame;
        _textFieldForReciver.frame = receiverFrame;
    }];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    [self hideLoading]; // this->hideLoading();
    SMWriteResult *result = opt.data;
    if (result.success) {
        [self toast:@"发送成功"];

        [SMConfig resetFetchTime];

        [self performSelector:@selector(dismiss) withObject:nil afterDelay:TOAST_DURTAION + 0.1];
        [SMUtils trackEventWithCategory:@"mail" action:@"send" label:@"success"];
    } else {
        [self toast:result.message];
        [SMUtils trackEventWithCategory:@"mail" action:@"send" label:@"fail"];
    }
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self hideLoading];
    [self toast:error.message];
    [SMUtils trackEventWithCategory:@"mail" action:@"send" label:@"net_error"];
}

@end
