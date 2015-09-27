//
//  SMWritePostViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-23.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMWritePostViewController.h"
#import "SMWriteResult.h"
#import "SMImagePickerViewController.h"
#import "SMImageUploader.h"
#import "SMImageUploadListViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define USER_DEF_LAST_POST_TITLE    @"last_post_title"
#define USER_DEF_LAST_POST_CONTENT  @"last_post_content"

@interface SMWritePostViewController ()<SMWebLoaderOperationDelegate, SMImagePickerViewDelegate, SMImageUploaderDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewForContainer;
@property (weak, nonatomic) IBOutlet UITextField *textFieldForTitle;
@property (weak, nonatomic) IBOutlet UITextView *textViewForText;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForText;
@property (weak, nonatomic) IBOutlet UIButton *buttonForUploadHint;
@property (weak, nonatomic) IBOutlet UIButton *buttonForUploadImage;

@property (strong, nonatomic) SMImagePickerViewController *imagePicker;
@property (strong, nonatomic) SMWebLoaderOperation *writeOp;
@property (strong, nonatomic) SMWebLoaderOperation *attachListOp;
@property (strong, nonatomic) SMImageUploader *imageUploader;

@property (assign, nonatomic) BOOL isUploading;
@property (assign, nonatomic) BOOL postAfterUpload;

@property (strong, nonatomic) NSArray *lastUploads;

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
    [_writeOp cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleBordered target:self action:@selector(doPost)];
    
    NSMutableString *quoteString = [[NSMutableString alloc] initWithString:@"  \n  \n"];
    if (_post.pid != 0) {   // re
        if (_postTitle != nil) {
            NSString *head = @"主题:Re: ";
            if ([_postTitle hasPrefix:head]) {
                _postTitle = [_postTitle substringFromIndex:head.length];
            }
            _textFieldForTitle.text = [NSString stringWithFormat:@"Re: %@", _postTitle];
        }
        [quoteString appendFormat:@"【 在 %@ (%@) 的大作中提到: 】", _post.author, _post.nick];
        
        NSString *content = _post.content;
        NSArray *lines = [content componentsSeparatedByString:@"\n"];
        int quoteLine = 4;
        for (int i = 0; i != lines.count && quoteLine > 0; ++i) {
            NSString *line = lines[i];
            if ([line isEqualToString:@"--"]) {   // qmd start
                break;
            }
            if (![line hasPrefix:@":"]) {   // 已是引用的文字，不再引用。
                --quoteLine;
                [quoteString appendFormat:@"\n: %@", line];
            }
        }
    }
    
    // 加载上次未发表的内容
    NSString *savedContent = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEF_LAST_POST_CONTENT];
    if (savedContent != nil) {
        NSString *str = [NSString stringWithFormat:@"~~~上次未发表的内容~~~\n%@\n~~~~~~~~~~~~\n", savedContent];
        [quoteString insertString:str atIndex:0];
    }
    
    if ([quoteString rangeOfString:@"xsmth"].length == 0 && ![SMConfig disableTail]) {
        [quoteString appendString:@"\n--\n发自xsmth (iOS版)"];
    }
    _textViewForText.text = quoteString;
    
    // 文章编辑，覆盖上面的配置。 ugly patch
    if (self.editPost) {
        _textFieldForTitle.text = self.editPost.title;
        _textViewForText.text = self.editPost.content;
    }
    
    // style
    _imageViewForTitle.image = [SMUtils stretchedImage:_imageViewForTitle.image];
    _imageViewForText.image = [SMUtils stretchedImage:_imageViewForText.image];
    
    // 加载已上传的文件 （上次未发表的）
    _attachListOp = [[SMWebLoaderOperation alloc] init];
    _attachListOp.delegate = self;
    [_attachListOp loadUrl:@"http://www.newsmth.net/bbsupload.php" withParser:@"upload"];
    
    UIImage *image = [_buttonForUploadImage imageForState:UIControlStateNormal];
    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [_buttonForUploadImage setImage:image forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_textFieldForTitle.text.length == 0) {
        [_textFieldForTitle becomeFirstResponder];
    } else {
        [_textViewForText setSelectedRange:NSMakeRange(0, 0)];
        [_textViewForText becomeFirstResponder];
    }
}

- (void)setupTheme
{
    [super setupTheme];
    _textFieldForTitle.keyboardAppearance = _textViewForText.keyboardAppearance = [SMConfig enableDayMode] ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark;
    
    self.textFieldForTitle.backgroundColor = [UIColor clearColor];
    self.textFieldForTitle.textColor = [SMTheme colorForPrimary];
    self.textViewForText.backgroundColor = [UIColor clearColor];
    self.textViewForText.textColor = [SMTheme colorForPrimary];
    
    
    self.imageViewForTitle.image = self.imageViewForText.image = nil;
    self.imageViewForTitle.layer.borderColor = self.imageViewForText.layer.borderColor = [SMTheme colorForSecondary].CGColor;
    self.imageViewForTitle.layer.borderWidth = self.imageViewForText.layer.borderWidth = 1;
    self.imageViewForTitle.layer.cornerRadius = self.imageViewForText.layer.cornerRadius = 5.0f;
}

- (void)cancel
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:USER_DEF_LAST_POST_TITLE];
    [def removeObjectForKey:USER_DEF_LAST_POST_CONTENT];

    [_imageUploader cancel];
    [self dismiss];
    
    [SMUtils trackEventWithCategory:@"write" action:@"dismiss" label:_post.board.name];
}

- (void)dismiss
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)doPost
{
    if (_isUploading) { // wait upload
        [self showLoading:@"正在上传"];
        _postAfterUpload = YES;
        return ;
    }
    
    NSString *title = [SMUtils encodeurl:_textFieldForTitle.text];
    NSString *text = [SMUtils encodeurl:_textViewForText.text];

    NSString *postBody = [NSString stringWithFormat:@"subject=%@&content=%@", title, text];
    
//    NSString *formUrl = [NSString stringWithFormat:@"http://www.newsmth.net/bbssnd.php?board=%@&reid=%d", _post.board.name, _post.pid];
    NSString *formUrl;
    if (_post.pid == 0) {
        formUrl = [NSString stringWithFormat:@"http://m.newsmth.net/article/%@/post", _post.board.name];
    } else {
        formUrl = [NSString stringWithFormat:@"http://m.newsmth.net/article/%@/post/%d", _post.board.name, _post.pid];
    }
    
    if (self.editPost) {
        formUrl = [NSString stringWithFormat:@"http://m.newsmth.net/article/%@/edit/%d", self.editPost.board.name, self.editPost.pid];
    }
    
    SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:formUrl]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
    
    _writeOp = [[SMWebLoaderOperation alloc] init];
    _writeOp.delegate = self;
    [self showLoading:@"正在发表..."];
    [_writeOp loadRequest:request withParser:@"bbssnd,util_notice"];
}

- (void)cancelLoading
{
    if (_isUploading) {
        _postAfterUpload = NO;
        [_imageUploader cancel];
    } else {
        [super cancelLoading];
        [_writeOp cancel];
        _writeOp = nil;
    }
}


- (void)onKeyboardWillShow:(NSNotification *)n
{
    NSDictionary* info = [n userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    CGFloat keyboardHeight = kbSize.height;
    if ([SMUtils isPad] && [SMUtils systemVersion] < 8 && ![SMUtils isPortrait]) {
        keyboardHeight = kbSize.width;
    }
    
    CGRect frame = self.view.bounds;
    frame.origin.y = _viewForContainer.frame.origin.y;
    frame.size.height -= (keyboardHeight + SM_TOP_INSET);
    _viewForContainer.frame = frame;
}

- (void)onKeyboardWillHide:(NSNotification *)n
{
    CGRect frame = self.view.bounds;
    frame.origin.y = SM_TOP_INSET;
    frame.size.height -= frame.origin.y;
    _viewForContainer.frame = frame;
}

- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    if (opt == _writeOp) {
        [self hideLoading]; // this->hideLoading();
        SMWriteResult *result = opt.data;
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if (result.success) {
            [self toast:@"发表成功"];
            [def removeObjectForKey:USER_DEF_LAST_POST_TITLE];
            [def removeObjectForKey:USER_DEF_LAST_POST_CONTENT];

            [SMConfig resetFetchTime];
            
            [SMUtils trackEventWithCategory:@"write" action:@"success" label:_post.board.name];
        } else {
            [self toast:result.message];
            // save post
            [def setObject:_textFieldForTitle.text forKey:USER_DEF_LAST_POST_TITLE];
            [def setObject:_textViewForText.text forKey:USER_DEF_LAST_POST_CONTENT];

            [SMUtils trackEventWithCategory:@"write" action:@"fail" label:_post.board.name];
        }
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:TOAST_DURTAION + 0.1];
    }
    
    if (opt == _attachListOp) {
        SMUpload *uploadResult = opt.data;
        if (uploadResult.items.count > 0) {
            _lastUploads = uploadResult.items;
            _buttonForUploadHint.hidden = NO;
            NSString *hint = [NSString stringWithFormat:@" 上次已上传%@个文件，点击管理 ", @(uploadResult.items.count)];
            [_buttonForUploadHint setTitle:hint forState:UIControlStateNormal];
            [_buttonForUploadHint setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [_buttonForUploadHint sizeToFit];
        } else {
            _buttonForUploadHint.hidden = YES;
        }
    }
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self hideLoading];
    [self toast:error.message];
}

#pragma mark - upload image

- (SMImageUploader *)getImageUploader
{
    if (_imageUploader == nil) {
        _imageUploader = [[SMImageUploader alloc] init];
        _imageUploader.delegate = self;
    }
    return _imageUploader;
}

- (IBAction)onUploadButtonClick:(id)sender
{
    // 已有上传文件，查看队列
    if (_imageUploader.uploadQueue.count > 0 || _lastUploads.count > 0) {
        SMImageUploadListViewController *vc = [[SMImageUploadListViewController alloc] init];
        vc.uploader = [self getImageUploader];
        vc.lastUploads = _lastUploads;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        _imagePicker = [[SMImagePickerViewController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:_imagePicker animated:YES];
    }
}

- (void)imagePickerViewControllerDidSelectAssets:(NSArray *)assets
{
    if (assets.count > 0) {
        _isUploading = YES;
        [[self getImageUploader] addAssets:assets];
    }
}

#pragma mark - SMImageUploaderDelegate
- (void)imageUploaderOnFinish:(SMImageUploader *)uploader
{
    [self updateUploadHint:@"上传成功"];
    _isUploading = NO;
    if (_postAfterUpload) {
        [self doPost];
    }
}

- (void)imageUploaderOnProgressChange:(SMImageUploader *)uploader withProgress:(CGFloat)progress
{
    if (uploader.uploadQueue.count > 0) {   // 压缩过程中，uploadQueue.count为0，暂不显示
        NSString *hint = [NSString stringWithFormat:@" 已上传第%@张%.2f%%，共%@) ", @(uploader.currentIndex + 1), progress * 100, @(uploader.uploadQueue.count)];
        [self updateUploadHint:hint];
    } else {
        [self updateUploadHint:@"正在压缩图片..."];
    }
    _isUploading = YES;
}

- (void)updateUploadHint:(NSString *)hint
{
    _buttonForUploadHint.hidden = NO;
    [_buttonForUploadHint setTitle:hint forState:UIControlStateNormal];
    [_buttonForUploadHint setTitleColor:SMRGB(0x32, 0x32, 0x32) forState:UIControlStateNormal];
    [_buttonForUploadHint sizeToFit];
}

@end
