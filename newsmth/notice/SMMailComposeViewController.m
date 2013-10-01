//
//  SMMailComposeViewController.m
//  newsmth
//
//  Created by Maxwin on 13-10-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMailComposeViewController.h"

@interface SMMailComposeViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewForContainer;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForReciver;
@property (weak, nonatomic) IBOutlet UITextView *textViewForContent;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForTextViewBg;

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


@end
