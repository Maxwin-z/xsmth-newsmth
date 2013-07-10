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

@property (strong, nonatomic) SMImagePickerViewController *imagePicker;
@property (strong, nonatomic) SMWebLoaderOperation *writeOp;
@property (strong, nonatomic) SMWebLoaderOperation *attachListOp;
@property (strong, nonatomic) SMImageUploader *imageUploader;

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
    
    NSMutableString *quoteString = [[NSMutableString alloc] initWithString:@"\n\n"];
    if (_post.pid != 0) {   // re
        if (_postTitle != nil) {
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
            if (![line hasPrefix:@":"]) {
                --quoteLine;
                [quoteString appendFormat:@"\n:%@", line];
            }
        }
    }
    
    // 加载上次未发表的内容
    NSString *savedContent = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEF_LAST_POST_CONTENT];
    if (savedContent != nil) {
        NSString *str = [NSString stringWithFormat:@"~~~上次未发表的内容~~~\n%@\n~~~~~~~~~~~~\n", savedContent];
        [quoteString insertString:str atIndex:0];
    }
    
    [quoteString appendString:@"\n发自xsmth (iOS版)"];
    _textViewForText.text = quoteString;
    
    // style
    _imageViewForTitle.image = [SMUtils stretchedImage:_imageViewForTitle.image];
    _imageViewForText.image = [SMUtils stretchedImage:_imageViewForText.image];
    
    // 加载已上传的文件 （上次未发表的）
    _attachListOp = [[SMWebLoaderOperation alloc] init];
    _attachListOp.delegate = self;
    [_attachListOp loadUrl:@"http://www.newsmth.net/bbsupload.php" withParser:@"upload"];
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

- (void)cancel
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:USER_DEF_LAST_POST_TITLE];
    [def removeObjectForKey:USER_DEF_LAST_POST_CONTENT];

    [self dismiss];
    
    [SMUtils trackEventWithCategory:@"write" action:@"dismiss" label:_post.board.name];
}

- (void)dismiss
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)doPost
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding ( kCFStringEncodingMacChineseSimp );
    NSString *title = [_textFieldForTitle.text stringByAddingPercentEscapesUsingEncoding:enc];
    NSString *text = [_textViewForText.text stringByAddingPercentEscapesUsingEncoding:enc];

    NSString *postBody = [NSString stringWithFormat:@"title=%@&text=%@&signature=1", title, text];
    
    NSString *formUrl = [NSString stringWithFormat:@"http://www.newsmth.net/bbssnd.php?board=%@&reid=%d", _post.board.name, _post.pid];
    SMHttpRequest *request = [[SMHttpRequest alloc] initWithURL:[NSURL URLWithString:formUrl]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setPostBody:[[postBody dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
    
    _writeOp = [[SMWebLoaderOperation alloc] init];
    _writeOp.delegate = self;
    [self showLoading:@"正在发表..."];
    [_writeOp loadRequest:request withParser:@"bbssnd"];
}

- (void)cancelLoading
{
    [super cancelLoading];
    [_writeOp cancel];
    _writeOp = nil;
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
    if (opt == _writeOp) {
        [self hideLoading]; // this->hideLoading();
        SMWriteResult *result = opt.data;
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if (result.success) {
            [self toast:@"发表成功"];
            [def removeObjectForKey:USER_DEF_LAST_POST_TITLE];
            [def removeObjectForKey:USER_DEF_LAST_POST_CONTENT];

            [SMUtils trackEventWithCategory:@"write" action:@"success" label:_post.board.name];
        } else {
            [self toast:@"发表失败，文章已保存"];
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
            NSString *hint = [NSString stringWithFormat:@" 上次已上传%d个文件，点击管理 ", uploadResult.items.count];
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
- (IBAction)onUploadButtonClick:(id)sender
{
    // 已有上传文件，查看队列
    if (_imageUploader.uploadDatas.count > 0|| _lastUploads.count > 0) {
        SMImageUploadListViewController *vc = [[SMImageUploadListViewController alloc] init];
        vc.uploader = _imageUploader;
        vc.lastUploads = _lastUploads;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        _imagePicker = [[SMImagePickerViewController alloc] init];
        _imagePicker.delegate = self;
        [self presentModalViewController:_imagePicker animated:YES];
    }
}

- (void)imagePickerViewControllerDidSelectAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

        NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:assets.count];
        
        for (int i = 0; i != assets.count; ++i) {
            ALAsset *asset = assets[i];
            NSString *filePath = [NSString stringWithFormat:@"%@/xsmth_%d.jpg", docPath, i];
            
            CGImageRef imageRef = asset.defaultRepresentation.fullResolutionImage;
            UIImage *imageOriginal = [UIImage imageWithCGImage:imageRef
                                                         scale:1.0f
                                                   orientation:(UIImageOrientation)[asset.defaultRepresentation orientation]];
            
            UIImage *imageResized = [self resizeImage:imageOriginal toMaxSize:800.0f];
            
            NSData *imageData = UIImageJPEGRepresentation(imageResized, 0.9);
            
            [imageData writeToFile:filePath atomically:YES];
            
            [files addObject:filePath];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageUploader = [[SMImageUploader alloc] init];
            _imageUploader.files = files;
            _imageUploader.delegate = self;
            [_imageUploader start];
        });
    });
}

- (UIImage *)resizeImage:(UIImage *)image toMaxSize:(CGFloat)maxSize
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat scale = 1.0f;
    if (width > height && height > maxSize) {
        scale = maxSize / height;
    }
    if (height > width && width > maxSize) {
        scale = maxSize / width;
    }
    
    XLog_d(@"scale: %f", scale);
    
    UIGraphicsBeginImageContext(CGSizeMake(width * scale, height * scale));
    [image drawInRect:CGRectMake(0, 0, width * scale, height * scale)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark - SMImageUploaderDelegate
- (void)imageUploaderOnFinish:(SMImageUploader *)uploader
{
    [self updateUploadHint:@"上传成功"];
}

- (void)imageUploaderOnProgressChange:(SMImageUploader *)uploader withProgress:(CGFloat)progress
{
    NSString *hint = [NSString stringWithFormat:@" 已上传%.2f%% (%d/%d) ", progress * 100, uploader.currentIndex, uploader.files.count];
    [self updateUploadHint:hint];
}

- (void)updateUploadHint:(NSString *)hint
{
    _buttonForUploadHint.hidden = NO;
    [_buttonForUploadHint setTitle:hint forState:UIControlStateNormal];
    [_buttonForUploadHint setTitleColor:SMRGB(0x32, 0x32, 0x32) forState:UIControlStateNormal];
    [_buttonForUploadHint sizeToFit];
}

@end
