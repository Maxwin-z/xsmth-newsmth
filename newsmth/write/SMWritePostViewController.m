//
//  SMWritePostViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-23.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMWritePostViewController.h"
#import "SMWriteResult.h"

@interface SMWritePostViewController ()<SMWebLoaderOperationDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewForContainer;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForTitle;
@property (weak, nonatomic) IBOutlet UITextView *textViewForText;

@property (strong, nonatomic) SMWebLoaderOperation *writeOp;
@end

@implementation SMWritePostViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleBordered target:self action:@selector(doPost)];
    
    if (_post) {
        if ([_post.title hasPrefix:@"Re: "]) {
            _textFieldForTitle.text = _post.title;
        } else {
            _textFieldForTitle.text = [NSString stringWithFormat:@"Re: %@", _post.title];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textFieldForTitle becomeFirstResponder];
}

- (void)cancel
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)doPost
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding ( kCFStringEncodingMacChineseSimp );
    NSString *title = [_textFieldForTitle.text stringByAddingPercentEscapesUsingEncoding:enc];
    NSString *text = [_textViewForText.text stringByAddingPercentEscapesUsingEncoding:enc];

    NSString *postBody = [NSString stringWithFormat:@"title=%@&text=%@&signature=1", title, text];
    
    NSString *formUrl = [NSString stringWithFormat:@"http://www.newsmth.net/bbssnd.php?board=%@&reid=%d", _post.board, _post.pid];
    SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:formUrl]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
    
    _writeOp = [[SMWebLoaderOperation alloc] init];
    _writeOp.delegate = self;
    [_writeOp loadRequest:request withParser:@"bbssnd"];
}


- (void)onKeyboardWillShow:(NSNotification *)n
{
    NSDictionary* info = [n userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    CGRect frame = self.view.bounds;
    frame.size.height -= kbSize.height;
    _viewForContainer.frame = frame;
}

- (void)onKeyboardWillHide:(NSNotification *)n
{
    _viewForContainer.frame = self.view.bounds;
}

- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    SMWriteResult *result = opt.data;
    if (result.success) {
        [self toast:@"发表成功"];
    } else {
        [self toast:@"发表失败"];
    }
    [self performSelector:@selector(cancel) withObject:nil afterDelay:TOAST_DURTAION + 0.1];
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self toast:error.message];
}

@end
